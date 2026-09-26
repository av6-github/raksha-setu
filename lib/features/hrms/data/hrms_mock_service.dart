// lib/features/hrms/data/hrms_mock_service.dart
// Deterministic read-only mock personnel service for prototype demonstrations

import '../domain/deployment_record.dart';
import '../domain/duty_record.dart';
import '../domain/leave_record.dart';

class HrmsMockService {
  List<LeaveRecord> getMockLeaves(String officerId) {
    final now = DateTime.now();
    return [
      LeaveRecord(
        id: 'leave-01',
        officerId: officerId,
        leaveType: 'Earned Leave (Family Function)',
        startDate: now.subtract(const Duration(days: 45)),
        endDate: now.subtract(const Duration(days: 35)),
        status: 'approved',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      LeaveRecord(
        id: 'leave-02',
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
        id: 'leave-03',
        officerId: officerId,
        leaveType: 'Festival Recess Leave',
        startDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 25)),
        status: 'applied',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<DeploymentRecord> getMockDeployments(String officerId) {
    final now = DateTime.now();
    return [
      DeploymentRecord(
        id: 'dep-01',
        officerId: officerId,
        location: 'Sector Headquarters (Plain Area)',
        operationName: 'Peace Posting / Logistics Roster',
        startDate: now.subtract(const Duration(days: 720)),
        endDate: now.subtract(const Duration(days: 360)),
        isHighHazard: false,
        hardshipScore: 2,
        isActive: false,
      ),
      DeploymentRecord(
        id: 'dep-02',
        officerId: officerId,
        location: 'High-Altitude Forward Operational Base (3,800m)',
        operationName: 'Operation Rakshak Perimeter',
        startDate: now.subtract(const Duration(days: 360)),
        endDate: null,
        isHighHazard: true,
        hardshipScore: 8,
        isActive: true,
      ),
    ];
  }

  List<DutyRecord> getMockDutyRecords(String officerId) {
    final now = DateTime.now();
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
