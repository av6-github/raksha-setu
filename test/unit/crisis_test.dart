// test/unit/crisis_test.dart
// Unit tests for Phase 8: Emergency Crisis Flow, C-SSRS Screener, Safety Plan, and Break-Glass Consent Bypass

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/errors/app_exceptions.dart';
import 'package:raksha_welfare/features/crisis/data/crisis_repository.dart';
import 'package:raksha_welfare/features/crisis/domain/consent_bypass.dart';
import 'package:raksha_welfare/features/crisis/domain/cssrs_screener.dart';
import 'package:raksha_welfare/features/crisis/presentation/crisis_view_model.dart';

void main() {
  group('Phase 8 — Crisis System & Human Escalation Tests', () {
    const testOfficerId = 'mock-officer-uuid-001';
    late CrisisRepository repository;

    setUp(() {
      repository = CrisisRepository(client: null);
    });

    test('C-SSRS clinical screener accurately categorizes suicidal risk severity', () {
      // 1. All negative -> low
      expect(CssrsScreener.evaluateSeverity({}), equals('low'));
      expect(CssrsScreener.evaluateSeverity({1: false, 2: false}), equals('low'));

      // 2. Passive or active ideation -> moderate
      expect(CssrsScreener.evaluateSeverity({1: true}), equals('moderate'));
      expect(CssrsScreener.evaluateSeverity({2: true}), equals('moderate'));

      // 3. Suicidal thoughts with methods -> high
      expect(CssrsScreener.evaluateSeverity({1: true, 3: true}), equals('high'));

      // 4. Intent with specific plan or past behavior -> imminent
      expect(CssrsScreener.evaluateSeverity({4: true}), equals('imminent'));
      expect(CssrsScreener.evaluateSeverity({5: true}), equals('imminent'));
      expect(CssrsScreener.evaluateSeverity({6: true}), equals('imminent'));
    });

    test('Emergency break-glass consent bypass strictly rejects non-emergency justifications', () {
      // 1. Valid imminent threat rationale passes
      final validBypass = EmergencyConsentBypass(
        id: 'bg-valid',
        officerId: testOfficerId,
        responderId: 'responder-doctor-01',
        imminentThreatRationale: 'Imminent suicide risk disclosure under C-SSRS Tier 5 evaluation',
        emergencyContactsNotified: const ['Spouse', 'Regimental MO'],
        timestamp: DateTime(2026, 9, 25),
      );
      expect(() => validBypass.validateEmergencyJustification(), returnsNormally);

      // 2. Administrative, disciplinary, or performance inquiry throws FirewallViolationException
      final invalidBypass = EmergencyConsentBypass(
        id: 'bg-invalid',
        officerId: testOfficerId,
        responderId: 'co-investigator-01',
        imminentThreatRationale: 'Annual Confidential Report performance audit inquiry',
        emergencyContactsNotified: const [],
        timestamp: DateTime(2026, 9, 25),
      );
      expect(
        () => invalidBypass.validateEmergencyJustification(),
        throwsA(isA<FirewallViolationException>().having(
          (e) => e.message,
          'message',
          contains('Consent Bypass Rejected'),
        )),
      );
    });

    test('CrisisRepository triggers human escalation and enforces zero-AI guarantee', () async {
      expect(() => repository.assertZeroAiInCrisisFlow(), returnsNormally);

      final event = await repository.triggerCrisisAlert(
        officerId: testOfficerId,
        source: 'direct_disclosure',
        severity: 'high',
      );

      expect(event.officerId, equals(testOfficerId));
      expect(event.status, equals('escalated'));
      expect(event.counselorNotifiedAt, isNotNull);
    });

    test('SafetyPlan loads default template with tactical coping, contacts, and armory steps', () async {
      final plan = await repository.getSafetyPlan(testOfficerId);

      expect(plan.officerId, equals(testOfficerId));
      expect(plan.warningSigns, isNotEmpty);
      expect(plan.internalCopingStrategies, isNotEmpty);
      expect(plan.internalCopingStrategies.first, contains('box breathing'));
      expect(plan.trustedContacts, isNotEmpty);
      expect(plan.professionalContacts.any((c) => c['phone'] == '14416'), isTrue);
      expect(plan.environmentalSafetySteps.any((s) => s.contains('armory')), isTrue);
    });

    test('CrisisViewModel triggers direct alert and evaluates C-SSRS screener', () async {
      final vm = CrisisViewModel(repository: repository, officerId: testOfficerId);

      expect(vm.isLoading, isTrue);
      await vm.loadSafetyPlan();
      expect(vm.isLoading, isFalse);
      expect(vm.isAlertSent, isFalse);

      // Trigger direct safety alert
      await vm.triggerDirectSafetyAlert(severity: 'imminent');
      expect(vm.isAlertSent, isTrue);
      expect(vm.activeAlertSeverity, equals('imminent'));

      // Submit C-SSRS screener with affirmative plan
      final severity = await vm.submitCssrs({1: true, 5: true});
      expect(severity, equals('imminent'));
    });
  });
}
