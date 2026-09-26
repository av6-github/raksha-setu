// lib/features/hrms/data/hrms_mock_service.dart
// Deterministic personnel service with profile-specific deployments, hardship tracking, and dynamic leave submission

import '../domain/deployment_record.dart';
import '../domain/duty_record.dart';
import '../domain/leave_record.dart';

class HrmsMockService {
  final Map<String, List<LeaveRecord>> _officerLeaves = {};

  void addLeave(LeaveRecord record) {
    final list = _officerLeaves.putIfAbsent(record.officerId, () => getMockLeaves(record.officerId));
    list.insert(0, record);
  }

  List<LeaveRecord> getMockLeaves(String officerId) {
    if (_officerLeaves.containsKey(officerId)) {
      return List.unmodifiable(_officerLeaves[officerId]!);
    }

    final now = DateTime.now();
    final leaves = <LeaveRecord>[];

    final isOfficer2 = officerId.contains('10ff6159') || officerId.contains('officer2') || officerId.contains('4421');
    final isOfficer3 = officerId.contains('9ba7cd91') || officerId.contains('officer3') || officerId.contains('9932');

    if (isOfficer3) {
      // Officer 3 (Arjun Thakur - High Friction / Operational Strain)
      leaves.addAll([
        LeaveRecord(
          id: 'leave-03-01',
          officerId: officerId,
          leaveType: 'Medical Rest & Recuperation',
          startDate: now.add(const Duration(days: 3)),
          endDate: now.add(const Duration(days: 10)),
          status: 'applied',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        LeaveRecord(
          id: 'leave-03-02',
          officerId: officerId,
          leaveType: 'Casual Leave (Family Emergency)',
          startDate: now.subtract(const Duration(days: 20)),
          endDate: now.subtract(const Duration(days: 14)),
          status: 'rejected',
          rejectionReason: 'Sub-zero LoC border operational standoff (mandatory freeze on exits)',
          isOperationalRejection: true,
          createdAt: now.subtract(const Duration(days: 25)),
        ),
        LeaveRecord(
          id: 'leave-03-03',
          officerId: officerId,
          leaveType: 'Annual Earned Leave',
          startDate: now.subtract(const Duration(days: 90)),
          endDate: now.subtract(const Duration(days: 75)),
          status: 'rejected',
          rejectionReason: 'Critical staffing deficit during Counter-Infiltration sweep',
          isOperationalRejection: true,
          createdAt: now.subtract(const Duration(days: 105)),
        ),
      ]);
    } else if (isOfficer2) {
      // Officer 2 (Priya Nair - Low Friction / Routine Rotations)
      leaves.addAll([
        LeaveRecord(
          id: 'leave-02-01',
          officerId: officerId,
          leaveType: 'Casual Leave',
          startDate: now.subtract(const Duration(days: 10)),
          endDate: now.subtract(const Duration(days: 7)),
          status: 'approved',
          createdAt: now.subtract(const Duration(days: 20)),
        ),
        LeaveRecord(
          id: 'leave-02-02',
          officerId: officerId,
          leaveType: 'Annual Earned Leave',
          startDate: now.subtract(const Duration(days: 60)),
          endDate: now.subtract(const Duration(days: 45)),
          status: 'approved',
          createdAt: now.subtract(const Duration(days: 80)),
        ),
      ]);
    } else {
      // Officer 1 (Subedar Vikram Singh - Balanced Operational Baseline)
      leaves.addAll([
        LeaveRecord(
          id: 'leave-01-01',
          officerId: officerId,
          leaveType: 'Earned Leave (Family Function)',
          startDate: now.subtract(const Duration(days: 45)),
          endDate: now.subtract(const Duration(days: 35)),
          status: 'approved',
          createdAt: now.subtract(const Duration(days: 60)),
        ),
        LeaveRecord(
          id: 'leave-01-02',
          officerId: officerId,
          leaveType: 'Casual Leave',
          startDate: now.subtract(const Duration(days: 18)),
          endDate: now.subtract(const Duration(days: 12)),
          status: 'rejected',
          rejectionReason: 'Emergency law-and-order mobilization (non-blame operational denial)',
          isOperationalRejection: true,
          createdAt: now.subtract(const Duration(days: 22)),
        ),
        LeaveRecord(
          id: 'leave-01-03',
          officerId: officerId,
          leaveType: 'Festival Recess Leave',
          startDate: now.add(const Duration(days: 15)),
          endDate: now.add(const Duration(days: 25)),
          status: 'applied',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      ]);
    }

    _officerLeaves[officerId] = leaves;
    return List.unmodifiable(leaves);
  }

  List<DeploymentRecord> getMockDeployments(String officerId) {
    final now = DateTime.now();

    final isOfficer2 = officerId.contains('10ff6159') || officerId.contains('officer2') || officerId.contains('4421');
    final isOfficer3 = officerId.contains('9ba7cd91') || officerId.contains('officer3') || officerId.contains('9932');

    if (isOfficer3) {
      // Officer 3 (Inspector Arjun Thakur, 45 BN BSF)
      return [
        DeploymentRecord(
          id: 'dep-03-01',
          officerId: officerId,
          location: 'Forward Sub-Zero Ridge (Siachen Sector 4,600m)',
          operationName: 'Operation Meghdoot Perimeter Defense',
          startDate: now.subtract(const Duration(days: 420)),
          endDate: null,
          isHighHazard: true,
          hardshipScore: 10,
          isActive: true,
        ),
        DeploymentRecord(
          id: 'dep-03-02',
          officerId: officerId,
          location: 'Baramulla Sector Line of Control Outpost',
          operationName: 'Counter-Infiltration Special Detachment',
          startDate: now.subtract(const Duration(days: 720)),
          endDate: now.subtract(const Duration(days: 420)),
          isHighHazard: true,
          hardshipScore: 9,
          isActive: false,
        ),
      ];
    } else if (isOfficer2) {
      // Officer 2 (Head Constable Priya Nair, 12 BN CRPF)
      return [
        DeploymentRecord(
          id: 'dep-02-01',
          officerId: officerId,
          location: 'Tactical Signal Grid Hub (Rajasthan Border)',
          operationName: 'Operation Desert Vigil Secure Comms',
          startDate: now.subtract(const Duration(days: 240)),
          endDate: null,
          isHighHazard: false,
          hardshipScore: 4,
          isActive: true,
        ),
        DeploymentRecord(
          id: 'dep-02-02',
          officerId: officerId,
          location: 'Central Academy Kadarpur (Training Wing)',
          operationName: 'Instructor & Comms Modernization Roster',
          startDate: now.subtract(const Duration(days: 720)),
          endDate: now.subtract(const Duration(days: 240)),
          isHighHazard: false,
          hardshipScore: 1,
          isActive: false,
        ),
      ];
    } else {
      // Officer 1 (Subedar Vikram Singh, 12 BN CRPF)
      return [
        DeploymentRecord(
          id: 'dep-01-01',
          officerId: officerId,
          location: 'High-Altitude Forward Operational Base (3,800m)',
          operationName: 'Operation Rakshak Perimeter Defense',
          startDate: now.subtract(const Duration(days: 360)),
          endDate: null,
          isHighHazard: true,
          hardshipScore: 8,
          isActive: true,
        ),
        DeploymentRecord(
          id: 'dep-01-02',
          officerId: officerId,
          location: 'Sector Headquarters 12 BN CRPF (Rajasthan)',
          operationName: 'Unit Administration & Roster Coordination',
          startDate: now.subtract(const Duration(days: 720)),
          endDate: now.subtract(const Duration(days: 360)),
          isHighHazard: false,
          hardshipScore: 2,
          isActive: false,
        ),
      ];
    }
  }

  List<DutyRecord> getMockDutyRecords(String officerId) {
    final now = DateTime.now();
    final isOfficer3 = officerId.contains('9ba7cd91') || officerId.contains('officer3') || officerId.contains('9932');
    final isOfficer2 = officerId.contains('10ff6159') || officerId.contains('officer2') || officerId.contains('4421');

    if (isOfficer3) {
      // Intense continuous duty
      return [
        DutyRecord(
          id: 'duty-03-01',
          officerId: officerId,
          date: now,
          shiftName: 'Sub-Zero Forward Observation Post',
          isNightShift: true,
          consecutiveDaysOnDuty: 21,
          overtimeHours: 4.5,
        ),
        DutyRecord(
          id: 'duty-03-02',
          officerId: officerId,
          date: now.subtract(const Duration(days: 1)),
          shiftName: 'Sub-Zero Forward Observation Post',
          isNightShift: true,
          consecutiveDaysOnDuty: 20,
          overtimeHours: 4.0,
        ),
        DutyRecord(
          id: 'duty-03-03',
          officerId: officerId,
          date: now.subtract(const Duration(days: 2)),
          shiftName: 'LoC Ambush Patrol',
          isNightShift: true,
          consecutiveDaysOnDuty: 19,
          overtimeHours: 3.5,
        ),
      ];
    } else if (isOfficer2) {
      // Regular comms duty
      return [
        DutyRecord(
          id: 'duty-02-01',
          officerId: officerId,
          date: now,
          shiftName: 'Comms Grid Day Watch',
          isNightShift: false,
          consecutiveDaysOnDuty: 5,
          overtimeHours: 0.5,
        ),
        DutyRecord(
          id: 'duty-02-02',
          officerId: officerId,
          date: now.subtract(const Duration(days: 1)),
          shiftName: 'Comms Grid Day Watch',
          isNightShift: false,
          consecutiveDaysOnDuty: 4,
          overtimeHours: 0.0,
        ),
      ];
    }

    return [
      DutyRecord(
        id: 'duty-01',
        officerId: officerId,
        date: now,
        shiftName: 'Perimeter Night Patrol',
        isNightShift: true,
        consecutiveDaysOnDuty: 14,
        overtimeHours: 2.5,
      ),
      DutyRecord(
        id: 'duty-02',
        officerId: officerId,
        date: now.subtract(const Duration(days: 1)),
        shiftName: 'Perimeter Night Patrol',
        isNightShift: true,
        consecutiveDaysOnDuty: 13,
        overtimeHours: 2.0,
      ),
      DutyRecord(
        id: 'duty-03',
        officerId: officerId,
        date: now.subtract(const Duration(days: 2)),
        shiftName: 'Sector Day Escort',
        isNightShift: false,
        consecutiveDaysOnDuty: 12,
        overtimeHours: 0.0,
      ),
    ];
  }
}
