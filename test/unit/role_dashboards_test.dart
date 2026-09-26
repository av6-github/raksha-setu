// test/unit/role_dashboards_test.dart
// Unit tests for Welfare, Counsellor, and Commander repositories and ViewModels (Phase 9)

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/security/rbac_guard.dart';
import 'package:raksha_welfare/features/risk/domain/risk_score.dart';
import 'package:raksha_welfare/features/welfare_dashboard/data/welfare_repository.dart';
import 'package:raksha_welfare/features/welfare_dashboard/domain/welfare_escalation.dart';
import 'package:raksha_welfare/features/welfare_dashboard/presentation/welfare_view_model.dart';
import 'package:raksha_welfare/features/counsellor_dashboard/data/counsellor_repository.dart';
import 'package:raksha_welfare/features/counsellor_dashboard/presentation/counsellor_view_model.dart';
import 'package:raksha_welfare/features/commander_dashboard/data/commander_repository.dart';
import 'package:raksha_welfare/features/commander_dashboard/presentation/commander_view_model.dart';

void main() {
  group('Phase 9 — Role-Based Dashboards Unit Tests', () {
    test('WelfareRepository & WelfareViewModel manage pseudonymised tiers and escalations', () async {
      final repository = WelfareRepository();
      final vm = WelfareViewModel(repository: repository);

      await vm.loadAll();
      expect(vm.isLoading, isFalse);
      expect(vm.officers.length, greaterThanOrEqualTo(3));
      expect(vm.escalations.length, greaterThanOrEqualTo(2));
      expect(vm.familyItems.length, greaterThanOrEqualTo(2));

      // Check pseudonymity
      final unconsented = vm.officers.firstWhere((o) => !o.consentToDiscloseName);
      expect(unconsented.realName, isNull);
      expect(unconsented.displayIdentifier, contains('Officer P-'));

      // Filter by Red Tier
      await vm.filterByTier(RiskTier.red);
      expect(vm.selectedTierFilter, equals(RiskTier.red));
      expect(vm.officers.every((o) => o.currentTier == RiskTier.red), isTrue);

      // Log Outreach action
      final pendingEsc = vm.escalations.firstWhere((e) => e.status == OutreachStatus.pending);
      await vm.logOutreach(
        escalationId: pendingEsc.id,
        status: OutreachStatus.contacted,
        notes: 'Spoke with unit Subedar-Major; outreach underway.',
      );
      final updatedEsc = vm.escalations.firstWhere((e) => e.id == pendingEsc.id);
      expect(updatedEsc.status, equals(OutreachStatus.contacted));
      expect(updatedEsc.actionLogNotes, contains('Subedar-Major'));

      // Update Family item status
      final familyItem = vm.familyItems.first;
      await vm.updateFamilyStatus(itemId: familyItem.id, newStatus: 'verified');
      final updatedFamilyItem = vm.familyItems.firstWhere((f) => f.id == familyItem.id);
      expect(updatedFamilyItem.status, equals('verified'));
    });

    test('CounsellorRepository & CounsellorViewModel manage clinical cases, notes, and safety plans', () async {
      final repository = CounsellorRepository();
      final vm = CounsellorViewModel(repository: repository, counsellorId: 'counsellor-001');

      await vm.loadCases();
      expect(vm.isLoading, isFalse);
      expect(vm.cases.isNotEmpty, isTrue);
      expect(vm.selectedCase, isNotNull);

      final initialCase = vm.selectedCase!;
      expect(initialCase.lastPhq9Score, greaterThan(0));
      expect(initialCase.hasActiveSafetyPlan, isTrue);

      // Verify Safety Plan template retrieval
      expect(vm.currentSafetyPlan, isNotNull);
      expect(vm.currentSafetyPlan!.internalCopingStrategies.first, contains('box breathing'));

      // Add clinical follow-up note
      await vm.addFollowUpNote(
        caseId: initialCase.caseId,
        note: 'Officer completed 7 days of sleep logging. Daytime alertness improved.',
        rtdRecommendation: 'Cleared for standard shift duty; restrict continuous watch >16h.',
      );

      expect(vm.selectedCase!.clinicalNotes.last, contains('sleep logging'));
      expect(vm.followUps.last.rtdRecommendation, contains('standard shift duty'));

      // Trigger audited emergency break-glass
      await vm.triggerEmergencyBreakGlass(
        targetOfficerId: initialCase.officerId,
        reasonCode: 'imminent_danger',
        justification: 'Officer voiced severe explicit intention; immediate hospitalization required.',
      );

      expect(vm.lastBreakGlassEvent, isNotNull);
      expect(vm.lastBreakGlassEvent!.requesterRole.name, equals('counsellor'));
      expect(vm.lastBreakGlassEvent!.targetOfficerId, equals(initialCase.officerId));
    });

    test('CommanderRepository & CommanderViewModel enforce k-anonymity and shield clinical data', () async {
      final repository = CommanderRepository();
      final vm = CommanderViewModel(repository: repository, defaultUnitCode: '12-BN-CHARLIE');

      await vm.loadUnitData('12-BN-CHARLIE');
      expect(vm.isLoading, isFalse);
      expect(vm.metrics, isNotNull);

      // Charlie Company has 84 personnel (>= 10) -> NOT suppressed
      expect(vm.metrics!.totalPersonnel, equals(84));
      expect(vm.metrics!.isSuppressed, isFalse);
      expect(vm.metrics!.aggregateReadinessScore, greaterThan(80.0));
      expect(vm.recommendations.isNotEmpty, isTrue);

      // Acknowledge Roster Recommendation
      final rec = vm.recommendations.first;
      await vm.acknowledgeRecommendation(rec.id);
      expect(vm.recommendations.firstWhere((r) => r.id == rec.id).isAcknowledged, isTrue);

      // Operational availability roster must strictly be binary
      expect(vm.availabilityRoster.isNotEmpty, isTrue);
      final allowedValues = {'available', 'medically_unavailable'};
      for (final status in vm.availabilityRoster.values) {
        expect(allowedValues.contains(status), isTrue);
      }

      // Small unit (< 10 personnel) must be suppressed for privacy protection
      await vm.loadUnitData('FORWARD-DET-SMALL');
      expect(vm.metrics!.totalPersonnel, equals(6));
      expect(vm.metrics!.isSuppressed, isTrue);
      expect(vm.metrics!.highFatigueRosterPercent, equals(0.0)); // Suppressed

      // Commander attempting forbidden clinical inspection throws ForbiddenAccessException
      expect(
        () => vm.attemptForbiddenClinicalInspection('mock-officer-uuid-001'),
        throwsA(isA<ForbiddenAccessException>()),
      );
    });
  });
}
