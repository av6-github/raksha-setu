// test/unit/hrms_test.dart
// Unit tests for Phase 4: HRMS Integration, Read-Only Firewall, and Organisational Friction Calculation

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/errors/app_exceptions.dart';
import 'package:raksha_welfare/features/hrms/data/hrms_repository.dart';
import 'package:raksha_welfare/features/hrms/domain/deployment_record.dart';
import 'package:raksha_welfare/features/hrms/domain/duty_record.dart';
import 'package:raksha_welfare/features/hrms/domain/leave_record.dart';
import 'package:raksha_welfare/features/hrms/domain/organisational_signal.dart';
import 'package:raksha_welfare/features/hrms/presentation/hrms_view_model.dart';

void main() {
  group('Phase 4 — HRMS Integration and Firewall Tests', () {
    const testOfficerId = 'officer-test-phase4';
    late HrmsRepository repository;

    setUp(() {
      repository = HrmsRepository(client: null);
    });

    test('Welfare-HR Firewall strictly prevents any write operations back to HRMS', () {
      expect(
        () => repository.assertReadOnly(),
        throwsA(isA<FirewallViolationException>().having(
          (e) => e.message,
          'message',
          contains('strictly read-only'),
        )),
      );
    });

    test('getLeaveRecords returns leave history and detects non-blame operational rejections', () async {
      final leaves = await repository.getLeaveRecords(testOfficerId);

      expect(leaves, isNotEmpty);
      final operationalRejections = leaves.where((l) => l.isOperationalRejection).toList();
      expect(operationalRejections, isNotEmpty);

      final opDenial = operationalRejections.first;
      expect(opDenial.status, equals('rejected'));
      expect(opDenial.statusDisplay, contains('Operational Denial'));
      expect(opDenial.rejectionReason, contains('operational'));
    });

    test('getDeploymentRecords returns hardship scores and high-hazard deployments', () async {
      final deployments = await repository.getDeploymentRecords(testOfficerId);

      expect(deployments, isNotEmpty);
      final highHazard = deployments.where((d) => d.isHighHazard).toList();
      expect(highHazard, isNotEmpty);
      expect(highHazard.first.hardshipScore, greaterThanOrEqualTo(7));
    });

    test('getDutyRecords returns shift information and consecutive duty tracking', () async {
      final duties = await repository.getDutyRecords(testOfficerId);

      expect(duties, isNotEmpty);
      expect(duties.first.consecutiveDaysOnDuty, greaterThan(0));
    });

    test('OrganisationalSignal computes systemic friction index without blaming officer', () {
      final testLeaves = [
        LeaveRecord(
          id: 'l1',
          officerId: testOfficerId,
          leaveType: 'Annual Leave',
          startDate: DateTime(2026, 8, 1),
          endDate: DateTime(2026, 8, 15),
          status: 'rejected',
          isOperationalRejection: true,
          rejectionReason: 'Denied due to high alert operational requirements',
          createdAt: DateTime(2026, 8, 1),
        ),
      ];

      final testDeployments = [
        DeploymentRecord(
          id: 'd1',
          officerId: testOfficerId,
          location: 'Kupwara Sector',
          hardshipScore: 9,
          startDate: DateTime(2025, 1, 1),
          endDate: DateTime(2026, 2, 1),
          isHighHazard: true,
          operationName: 'Counter-Terrorism Grid',
        ),
      ];

      final testDuties = [
        DutyRecord(
          id: 'dt1',
          officerId: testOfficerId,
          date: DateTime(2026, 9, 20),
          overtimeHours: 4.0,
          consecutiveDaysOnDuty: 16,
          shiftName: 'Night Stand-to',
          isNightShift: true,
        ),
      ];

      final signal = OrganisationalSignal.compute(
        officerId: testOfficerId,
        leaves: testLeaves,
        deployments: testDeployments,
        dutyRecords: testDuties,
      );

      // Baseline 0.1 + 0.25 (operational denial) + 0.35 (consecutive days >= 14) + 0.25 (hardship >= 12 months) = 0.95
      expect(signal.frictionIndex, closeTo(0.95, 0.01));
      expect(signal.operationalLeaveDenials, equals(1));
      expect(signal.currentConsecutiveDutyDays, equals(16));
      expect(signal.highHardshipMonths, greaterThanOrEqualTo(12));
      expect(signal.contributingFactors.length, equals(3));
      expect(signal.contributingFactors[0], contains('operational leave rejection'));
      expect(signal.contributingFactors[1], contains('consecutive days on duty'));
      expect(signal.contributingFactors[2], contains('months sustained in high-hazard'));
    });

    test('HrmsViewModel successfully loads signal, leaves, and deployments', () async {
      final vm = HrmsViewModel(repository: repository, officerId: testOfficerId);
      expect(vm.isLoading, isTrue);

      await vm.loadData();

      expect(vm.isLoading, isFalse);
      expect(vm.signal, isNotNull);
      expect(vm.leaves, isNotEmpty);
      expect(vm.deployments, isNotEmpty);
      expect(vm.dutyRecords, isNotEmpty);
      expect(vm.errorMessage, isNull);
    });

    test('HrmsViewModel applyLeave successfully adds new leave record', () async {
      final vm = HrmsViewModel(repository: repository, officerId: testOfficerId);
      await vm.loadData();
      final initialCount = vm.leaves.length;

      final result = await vm.applyLeave(
        leaveType: 'Casual Leave (CL)',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        reason: 'Family welfare visit',
      );

      expect(result, isTrue);
      expect(vm.leaves.length, equals(initialCount + 1));
      expect(vm.leaves.first.leaveType, equals('Casual Leave (CL)'));
      expect(vm.leaves.first.status, equals('applied'));
      expect(vm.leaves.first.durationDays, equals(5));
    });
  });
}
