import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/live_pilot/domain/models/live_pilot_models.dart';
import 'package:raksha_welfare/features/live_pilot/domain/services/live_pilot_engine.dart';
import 'package:raksha_welfare/features/live_pilot/data/live_pilot_repository.dart';
import 'package:raksha_welfare/features/live_pilot/presentation/live_pilot_view_model.dart';

void main() {
  group('LivePilotEngine Unit Tests', () {
    test('computeRelativeImprovement calculates correctly for lowerIsBetter and higherIsBetter', () {
      // Lower is better (e.g. friction reduced from 10 to 6 -> (10-6)/10 * 100 = 40%)
      final lowerImprovement = LivePilotEngine.computeRelativeImprovement(
        pilotValue: 6.0,
        controlValue: 10.0,
        lowerIsBetter: true,
      );
      expect(lowerImprovement, closeTo(40.0, 0.001));

      // Higher is better (e.g. detection increased from 2 to 10 -> (10-2)/2 * 100 = 400%)
      final higherImprovement = LivePilotEngine.computeRelativeImprovement(
        pilotValue: 10.0,
        controlValue: 2.0,
        lowerIsBetter: false,
      );
      expect(higherImprovement, closeTo(400.0, 0.001));

      // Control value zero edge case
      expect(LivePilotEngine.computeRelativeImprovement(pilotValue: 5, controlValue: 0), 0.0);
    });

    test('assertFirewallZeroBreach passes when dataEnteredAcr is false and throws when true', () {
      expect(() => LivePilotEngine.assertFirewallZeroBreach(dataEnteredAcr: false), returnsNormally);

      expect(
        () => LivePilotEngine.assertFirewallZeroBreach(dataEnteredAcr: true),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Critical Firewall Violation'),
        )),
      );
    });

    test('verifyCrisisHumanRouting passes on 100% human compliance and returns false on violation', () {
      final validIncidents = [
        LiveIncidentLog(
          incidentId: 'inc-1',
          timestamp: DateTime.now(),
          unitName: '42 Bn BSF',
          incidentType: IncidentType.crisisIntercept,
          severity: IncidentSeverity.high,
          summary: 'Safety intercept engaged',
          humanResponder: 'Dr. Maj Sharma',
          zeroAiVerified: true,
          isResolved: true,
        ),
      ];
      expect(LivePilotEngine.verifyCrisisHumanRouting(validIncidents), isTrue);

      final aiViolationIncidents = [
        LiveIncidentLog(
          incidentId: 'inc-2',
          timestamp: DateTime.now(),
          unitName: '42 Bn BSF',
          incidentType: IncidentType.crisisIntercept,
          severity: IncidentSeverity.high,
          summary: 'AI auto-responder',
          humanResponder: '',
          zeroAiVerified: false,
          isResolved: false,
        ),
      ];
      expect(LivePilotEngine.verifyCrisisHumanRouting(aiViolationIncidents), isFalse);
    });

    test('evaluateScaleCertification requires all criteria to be satisfied', () {
      final certified = LivePilotEngine.evaluateScaleCertification(
        certificationId: 'CERT-001',
        clinicalConcordanceRate: 0.932,
        leaveFrictionReduction: 44.1,
        totalTroopsProtected: 3180,
        acrFirewallZeroBreach: true,
        crisisZeroAiCompliant: true,
        clinicalChairpersonSignoff: 'Lt. Gen. Dr. A. Sengupta',
        defenceOmbudsmanSignoff: 'Justice S. Kaul',
        directorGeneralSignoff: 'Director General',
        remarks: 'All verified',
      );
      expect(certified.isApprovedForScale, isTrue);
      expect(certified.status, LivePilotStatus.certifiedForScale);

      // Fails if concordance rate < 0.90
      final nonCertified = LivePilotEngine.evaluateScaleCertification(
        certificationId: 'CERT-002',
        clinicalConcordanceRate: 0.85,
        leaveFrictionReduction: 44.1,
        totalTroopsProtected: 3180,
        acrFirewallZeroBreach: true,
        crisisZeroAiCompliant: true,
        clinicalChairpersonSignoff: 'Lt. Gen. Dr. A. Sengupta',
        defenceOmbudsmanSignoff: 'Justice S. Kaul',
        directorGeneralSignoff: 'Director General',
        remarks: 'Concordance low',
      );
      expect(nonCertified.isApprovedForScale, isFalse);
      expect(nonCertified.status, LivePilotStatus.reviewRequired);
    });
  });

  group('LivePilotRepository & ViewModel Tests', () {
    late LivePilotRepository repository;
    late LivePilotViewModel viewModel;

    setUp(() {
      repository = LivePilotRepository();
      viewModel = LivePilotViewModel(repository: repository);
    });

    test('repository returns mock data for all Phase 20 models', () async {
      final units = await repository.getBattalionUnits();
      expect(units.length, 6);
      expect(units.where((u) => u.isPilotUnit).length, 3);
      expect(units.where((u) => !u.isPilotUnit).length, 3);

      final comparisons = await repository.getPilotVsControlComparison();
      expect(comparisons.metrics.length, 5);
      final trustComparison = comparisons.metrics.firstWhere((c) => c.metricName.contains('Trust'));
      expect(trustComparison.pilotValueDisplay, '89.2%');

      final incidents = await repository.getLiveIncidents();
      expect(incidents.length, 3);

      final trustMeasurements = await repository.getTrustMeasurements();
      expect(trustMeasurements.length, 3);

      final cert = await repository.getScaleCertification();
      expect(cert.isApprovedForScale, isTrue);
      expect(cert.clinicalChairpersonSignoff, contains('Lt. Gen.'));
    });

    test('viewModel loads metrics and handles incident resolution', () async {
      expect(viewModel.isLoading, isFalse);
      await viewModel.loadMetrics();
      expect(viewModel.units.length, 6);
      expect(viewModel.comparison?.metrics.length, 5);
      expect(viewModel.incidents.length, 3);
      expect(viewModel.certification?.isApprovedForScale, isTrue);

      // Test incident resolution
      final openIncident = viewModel.incidents.firstWhere((i) => !i.isResolved);
      await viewModel.resolveIncident(openIncident.incidentId, 'Immediate hardware router replacement verified');
      final updated = viewModel.incidents.firstWhere((i) => i.incidentId == openIncident.incidentId);
      expect(updated.isResolved, isTrue);
      expect(updated.resolutionNotes, contains('Immediate hardware'));
    });
  });
}
