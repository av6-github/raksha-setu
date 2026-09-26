// test/unit/interventions_test.dart
// Unit tests for Phase 7: Voluntary Support Options, Human Clinician Gate, Minimum Necessary Commander Disclosure, and RTD Plans

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/errors/app_exceptions.dart';
import 'package:raksha_welfare/features/interventions/data/intervention_repository.dart';
import 'package:raksha_welfare/features/interventions/domain/return_to_duty_plan.dart';
import 'package:raksha_welfare/features/interventions/domain/support_intervention.dart';
import 'package:raksha_welfare/features/interventions/presentation/intervention_view_model.dart';

void main() {
  group('Phase 7 — Risk Tiers and Human Intervention Tests', () {
    const testOfficerId = 'mock-officer-uuid-001';
    late InterventionRepository repository;

    setUp(() {
      repository = InterventionRepository(client: null);
    });

    test('Off-duty status strictly requires human clinician authorization (algorithms cannot ground officers)', () {
      // 1. Automated algorithm attempting off-duty assignment throws FirewallViolationException
      expect(
        () => ReturnToDutyPlan.assertHumanClinicianAuthorized('system_tier'),
        throwsA(isA<FirewallViolationException>().having(
          (e) => e.message,
          'message',
          contains('Human Intervention Gate Violation'),
        )),
      );

      // 2. Human clinician recommendation is authorized
      expect(
        () => ReturnToDutyPlan.assertHumanClinicianAuthorized('clinician'),
        returnsNormally,
      );
    });

    test('Commander disclosure strictly enforces minimum necessary operational status', () {
      // 1. Valid minimal status passes
      final validPlan = ReturnToDutyPlan(
        id: 'rtd-valid',
        officerId: testOfficerId,
        clinicianName: 'Dr. R. Sharma',
        offDutyStart: DateTime(2026, 9, 20),
        expectedReturnDate: DateTime(2026, 10, 5),
        gradedSteps: const ['Step 1: Clinical decompression'],
        commanderStatusDisclosed: 'medically_unavailable',
      );
      expect(() => validPlan.assertMinimumNecessaryCommanderDisclosure(), returnsNormally);

      // 2. Leaking diagnostic or risk score in commander status throws FirewallViolationException
      final leakedPlan = ReturnToDutyPlan(
        id: 'rtd-leaked',
        officerId: testOfficerId,
        clinicianName: 'Dr. R. Sharma',
        offDutyStart: DateTime(2026, 9, 20),
        expectedReturnDate: DateTime(2026, 10, 5),
        gradedSteps: const ['Step 1: Clinical decompression'],
        commanderStatusDisclosed: 'High Risk PHQ-9 16 Depressive Episode',
      );
      expect(
        () => leakedPlan.assertMinimumNecessaryCommanderDisclosure(),
        throwsA(isA<FirewallViolationException>().having(
          (e) => e.message,
          'message',
          contains('Firewall Breach: Commander disclosed status must strictly be "medically_unavailable"'),
        )),
      );
    });

    test('Officer can voluntarily accept or decline proposed support options without punishment', () async {
      final interventions = await repository.getOfficerInterventions(testOfficerId);
      final proposed = interventions.firstWhere((i) => i.status == InterventionStatus.proposed);

      // 1. Accept intervention
      final accepted = await repository.acceptIntervention(proposed.id);
      expect(accepted.status, equals(InterventionStatus.accepted));
      expect(accepted.actionedAt, isNotNull);

      // 2. Decline another proposed intervention
      final remainingProposed = (await repository.getOfficerInterventions(testOfficerId))
          .firstWhere((i) => i.status == InterventionStatus.proposed);
      final declined = await repository.declineIntervention(remainingProposed.id);
      expect(declined.status, equals(InterventionStatus.declined));
      expect(declined.actionedAt, isNotNull);
    });

    test('Officer can schedule confidential human counselling session', () async {
      final initialBookings = await repository.getCounsellingBookings(testOfficerId);

      final newBooking = await repository.scheduleCounselling(
        officerId: testOfficerId,
        sessionDate: DateTime(2026, 9, 28, 14, 0),
        sessionType: 'tele_counselling',
        isTeleCounselling: true,
      );

      expect(newBooking.status, equals('scheduled'));
      expect(newBooking.isTeleCounselling, isTrue);

      final updatedBookings = await repository.getCounsellingBookings(testOfficerId);
      expect(updatedBookings.length, equals(initialBookings.length + 1));
    });

    test('InterventionViewModel loads support data, actions choices, and checks commander status', () async {
      final vm = InterventionViewModel(repository: repository, officerId: testOfficerId);

      expect(vm.isLoading, isTrue);
      await vm.loadData();

      expect(vm.isLoading, isFalse);
      expect(vm.interventions, isNotEmpty);
      expect(vm.bookings, isNotEmpty);
      expect(vm.rtdPlan, isNotNull);
      expect(vm.commanderDisclosedStatus, equals('medically_unavailable'));
      expect(vm.errorMessage, isNull);
    });
  });
}
