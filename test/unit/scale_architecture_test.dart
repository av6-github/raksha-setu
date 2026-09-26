import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/localization/app_localizations.dart';
import 'package:raksha_welfare/features/scale/domain/models/scale_models.dart';
import 'package:raksha_welfare/features/scale/domain/services/scale_engine.dart';
import 'package:raksha_welfare/features/scale/data/scale_repository.dart';
import 'package:raksha_welfare/features/scale/presentation/scale_view_model.dart';

void main() {
  group('ScaleEngine Unit Tests', () {
    test('TenantIsolationEngine enforces strict same-tenant access', () {
      expect(
        () => TenantIsolationEngine.assertTenantIsolation(requestForceId: 'bsf', targetForceId: 'bsf'),
        returnsNormally,
      );

      expect(
        () => TenantIsolationEngine.assertTenantIsolation(requestForceId: 'bsf', targetForceId: 'crpf'),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Critical Tenant Isolation Breach'),
        )),
      );
    });

    test('TenantIsolationEngine generates valid RLS SQL predicate', () {
      final filter = TenantIsolationEngine.generateRlsPolicyFilter('bsf');
      expect(filter, contains("force_id = 'bsf'"));
      expect(filter, contains("current_setting('app.current_force_id', true)"));
    });

    test('FederatedLearningEngine executes FedAvg mathematical aggregation accurately', () {
      // Client 1: 100 samples, weight = 2.0
      // Client 2: 300 samples, weight = 4.0
      // Expected FedAvg = (100/400)*2.0 + (300/400)*4.0 = 0.5 + 3.0 = 3.5
      final clientDeltas = [
        {'w_sleep_deficit': 2.0, 'w_shift_fatigue': 1.0},
        {'w_sleep_deficit': 4.0, 'w_shift_fatigue': 5.0},
      ];
      final clientSampleCounts = [100, 300];

      final aggregated = FederatedLearningEngine.aggregateFedAvg(
        clientWeightDeltas: clientDeltas,
        clientSampleCounts: clientSampleCounts,
      );

      expect(aggregated['w_sleep_deficit'], closeTo(3.5, 0.0001));
      // (100*1 + 300*5) / 400 = 1600 / 400 = 4.0
      expect(aggregated['w_shift_fatigue'], closeTo(4.0, 0.0001));
    });

    test('FederatedLearningEngine applies Differential Privacy noise without NaN or infinity', () {
      final weights = {'w_sleep_deficit': 1.5, 'w_shift_fatigue': 2.5};
      final noisy = FederatedLearningEngine.applyDifferentialPrivacyNoise(
        weights: weights,
        epsilon: 1.20,
        delta: 1e-5,
      );

      expect(noisy.containsKey('w_sleep_deficit'), isTrue);
      expect(noisy.containsKey('w_shift_fatigue'), isTrue);
      expect(noisy['w_sleep_deficit']!.isFinite, isTrue);
      expect(noisy['w_shift_fatigue']!.isFinite, isTrue);
    });

    test('FederatedLearningEngine strictly rejects raw telemetry fields in payload', () {
      final cleanPayload = {
        'model_weights_delta': [0.1, -0.2],
        'client_sample_count': 500,
      };
      expect(() => FederatedLearningEngine.assertZeroRawDataTransmission(cleanPayload), returnsNormally);

      final leakPayload = {
        'model_weights_delta': [0.1, -0.2],
        'phq9_answers': [2, 3, 1],
      };
      expect(
        () => FederatedLearningEngine.assertZeroRawDataTransmission(leakPayload),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Federated Privacy Breach'),
        )),
      );
    });

    test('GovCloudMigrationEngine validates sovereign cloud compliance criteria', () {
      const compliantStatus = GovCloudMigrationStatus(
        targetCloudProvider: 'NIC MeghRaj Cloud / C-DAC',
        dataSovereigntyZone: 'IN-WEST-1 (Delhi NCR)',
        meityEmpanelled: true,
        airGappedHsmReady: true,
        stqcSecurityClearance: true,
        zeroCrossBorderTransitVerified: true,
        readiness: MigrationReadiness.migrationCompleted,
        certifiedTroopCapacity: 150000,
        clearanceCertificateId: 'STQC-9812A',
      );
      expect(GovCloudMigrationEngine.evaluateGovCloudCompliance(compliantStatus), isTrue);

      const nonCompliantStatus = GovCloudMigrationStatus(
        targetCloudProvider: 'Commercial Cloud',
        dataSovereigntyZone: 'EU-CENTRAL-1',
        meityEmpanelled: false,
        airGappedHsmReady: false,
        stqcSecurityClearance: false,
        zeroCrossBorderTransitVerified: false,
        readiness: MigrationReadiness.pendingAudit,
        certifiedTroopCapacity: 5000,
        clearanceCertificateId: 'N/A',
      );
      expect(GovCloudMigrationEngine.evaluateGovCloudCompliance(nonCompliantStatus), isFalse);
    });
  });

  group('Multilingual Support Unit Tests (8 Languages)', () {
    test('AppLocalizations contains valid translations for all 8 supported languages', () {
      const languages = ['en', 'hi', 'pa', 'bn', 'as', 'ta', 'te', 'mr'];

      for (final lang in languages) {
        final loc = AppLocalizations(Locale(lang));
        expect(loc.translate('app_title').isNotEmpty, isTrue, reason: 'Failed for lang: $lang');
        expect(loc.translate('crisis_support').isNotEmpty, isTrue, reason: 'Failed for lang: $lang');
        expect(loc.translate('welfare_firewall').isNotEmpty, isTrue, reason: 'Failed for lang: $lang');
      }

      // Check delegate support
      const delegate = AppLocalizationsDelegate();
      for (final lang in languages) {
        expect(delegate.isSupported(Locale(lang)), isTrue);
      }
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });
  });

  group('ScaleRepository & ScaleViewModel Tests', () {
    late ScaleRepository repository;
    late ScaleViewModel viewModel;

    setUp(() {
      repository = ScaleRepository();
      viewModel = ScaleViewModel(repository: repository);
    });

    test('repository returns 7 forces and 7 staged battalions', () async {
      final forces = await repository.getForceTenants();
      expect(forces.length, 7);
      expect(forces.any((f) => f.acronym == 'BSF'), isTrue);
      expect(forces.any((f) => f.acronym == 'CRPF'), isTrue);
      expect(forces.any((f) => f.acronym == 'NSG'), isTrue);

      final battalions = await repository.getMultiBattalions();
      expect(battalions.length, 7);
      expect(battalions.every((b) => b.edgeNodeActive), isTrue);

      final rounds = await repository.getFederatedLearningRounds();
      expect(rounds.length, 2);

      final migration = await repository.getGovCloudMigrationStatus();
      expect(migration.isFullyCompliant, isTrue);

      final capacity = await repository.getCapacityScalingMetrics();
      expect(capacity.maxTroopCapacity, 150000);
    });

    test('viewModel loads metrics, filters battalions, triggers federated round, and switches languages', () async {
      await viewModel.loadMetrics();
      expect(viewModel.forces.length, 7);
      expect(viewModel.battalions.length, 7);

      // Force filter
      viewModel.setForceFilter('bsf');
      expect(viewModel.forceFilter, 'bsf');
      expect(viewModel.battalions.length, 1);
      expect(viewModel.battalions.first.forceId, 'bsf');

      viewModel.setForceFilter('ALL');
      expect(viewModel.battalions.length, 7);

      // Trigger federated round
      final initialRounds = viewModel.rounds.length;
      await viewModel.triggerFederatedRound('global-distress-detector-v2.2');
      expect(viewModel.rounds.length, initialRounds + 1);
      expect(viewModel.rounds.first.targetGlobalModel, 'global-distress-detector-v2.2');

      // Change language
      viewModel.setSelectedLanguage('pa');
      expect(viewModel.selectedLanguageCode, 'pa');
    });
  });
}
