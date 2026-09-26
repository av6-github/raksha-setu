import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/expansion/domain/models/expansion_models.dart';
import 'package:raksha_welfare/features/expansion/domain/services/expansion_engine.dart';
import 'package:raksha_welfare/features/expansion/data/expansion_repository.dart';
import 'package:raksha_welfare/features/expansion/presentation/expansion_view_model.dart';

void main() {
  group('SectorAdapterEngine Unit Tests', () {
    test('assertUniversalFirewall validates presence of ACR/service book statutory quarantine', () {
      const validProfile = SectorProfile(
        sector: ExpansionSector.statePolice,
        title: 'State Police',
        description: 'Police force',
        iconKey: 'police',
        operationalStressors: ['shifts', 'crowds', 'backlogs'],
        hierarchyRanks: ['DGP', 'SP', 'Constable'],
        welfareSchemes: ['Police Fund'],
        crisisHotline: '112',
        firewallStatutoryRule: 'Section 42-B: Stress metrics excluded from ACR and promotions.',
        projectedPersonnel: 10000,
        isPlugAndPlay: true,
        readinessScore: 95.0,
      );
      expect(() => SectorAdapterEngine.assertUniversalFirewall(validProfile), returnsNormally);

      const invalidProfile = SectorProfile(
        sector: ExpansionSector.statePolice,
        title: 'Weak Police',
        description: 'Police force',
        iconKey: 'police',
        operationalStressors: ['shifts', 'crowds', 'backlogs'],
        hierarchyRanks: ['DGP', 'SP', 'Constable'],
        welfareSchemes: ['Police Fund'],
        crisisHotline: '112',
        firewallStatutoryRule: 'General welfare policy without legal teeth.',
        projectedPersonnel: 10000,
        isPlugAndPlay: true,
        readinessScore: 95.0,
      );
      expect(
        () => SectorAdapterEngine.assertUniversalFirewall(invalidProfile),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Firewall Inadequacy'),
        )),
      );
    });

    test('validateSectorProfile validates structural completeness across stressors, ranks, schemes', () {
      const completeProfile = SectorProfile(
        sector: ExpansionSector.disasterResponse,
        title: 'NDRF',
        description: 'Disaster force',
        iconKey: 'rescue',
        operationalStressors: ['floods', 'trauma', 'separation'],
        hierarchyRanks: ['Commandant', '2IC', 'Technician'],
        welfareSchemes: ['Relief Fund'],
        crisisHotline: '1078',
        firewallStatutoryRule: 'DM Act 2005: Operational trauma excluded from Annual Appraisal.',
        projectedPersonnel: 45000,
        isPlugAndPlay: true,
        readinessScore: 92.0,
      );
      expect(SectorAdapterEngine.validateSectorProfile(completeProfile), isTrue);
    });
  });

  group('ExpansionRepository & ExpansionViewModel Tests', () {
    late ExpansionRepository repository;
    late ExpansionViewModel viewModel;

    setUp(() {
      repository = ExpansionRepository();
      viewModel = ExpansionViewModel(repository: repository);
    });

    test('repository returns 6 fully adapted sector profiles and audit report', () async {
      final profiles = await repository.getSectorProfiles();
      expect(profiles.length, 6);
      expect(profiles.every((p) => p.isPlugAndPlay), isTrue);
      expect(profiles.every((p) => p.readinessScore >= 80.0), isTrue);

      final audit = await repository.getSectorReadinessAudit();
      expect(audit.totalSectorsCataloged, 6);
      expect(audit.fullyAdaptedSectors, 6);
      expect(audit.aggregateWorkforceReach, 645000);
      expect(audit.universalFirewallGuaranteed, isTrue);

      final active = await repository.getActiveSector();
      expect(active.sector, ExpansionSector.statePolice);
    });

    test('viewModel loads metrics and handles active sector selection', () async {
      await viewModel.loadMetrics();
      expect(viewModel.profiles.length, 6);
      expect(viewModel.audit?.aggregateWorkforceReach, 645000);
      expect(viewModel.activeProfile?.sector, ExpansionSector.statePolice);

      // Select NDRF
      await viewModel.selectSector(ExpansionSector.disasterResponse);
      expect(viewModel.activeProfile?.sector, ExpansionSector.disasterResponse);
      expect(viewModel.activeProfile?.title, contains('NDRF'));
    });
  });
}
