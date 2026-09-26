// lib/features/hrms/domain/leave_record.dart
// Domain model for HRMS leave records with non-blaming operational rejection semantics

class LeaveRecord {
  final String id;
  final String officerId;
  final String leaveType; // 'earned', 'casual', 'medical', 'emergency'
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'applied', 'approved', 'rejected', 'cancelled'
  final String? rejectionReason;
  final bool isOperationalRejection;
  final DateTime createdAt;

  const LeaveRecord({
    required this.id,
    required this.officerId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.rejectionReason,
    this.isOperationalRejection = false,
    required this.createdAt,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return isOperationalRejection ? 'Operational Denial' : 'Rejected';
      case 'applied':
        return 'Under Review';
      default:
        return status.toUpperCase();
    }
  }

  factory LeaveRecord.fromMap(Map<String, dynamic> map) {
    return LeaveRecord(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      leaveType: map['leave_type'] as String,
      startDate: DateTime.tryParse(map['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['end_date'] as String? ?? '') ?? DateTime.now(),
      status: map['status'] as String? ?? 'applied',
      rejectionReason: map['rejection_reason'] as String?,
      isOperationalRejection: map['is_operational_rejection'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'leave_type': leaveType,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'status': status,
      'rejection_reason': rejectionReason,
      'is_operational_rejection': isOperationalRejection,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
