// lib/features/interventions/domain/support_intervention.dart
// Voluntary, non-punitive human welfare interventions and officer support choices

enum InterventionType {
  workloadAdjustment,
  leaveGranted,
  shiftChange,
  lightDuty,
  counselling,
  temporaryOffDuty;

  String get dbValue {
    switch (this) {
      case InterventionType.workloadAdjustment:
        return 'workload_adjustment';
      case InterventionType.leaveGranted:
        return 'leave_granted';
      case InterventionType.shiftChange:
        return 'shift_change';
      case InterventionType.lightDuty:
        return 'light_duty';
      case InterventionType.counselling:
        return 'counselling';
      case InterventionType.temporaryOffDuty:
        return 'temporary_off_duty';
    }
  }

  static InterventionType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'workload_adjustment':
        return InterventionType.workloadAdjustment;
      case 'leave_granted':
        return InterventionType.leaveGranted;
      case 'shift_change':
        return InterventionType.shiftChange;
      case 'light_duty':
        return InterventionType.lightDuty;
      case 'temporary_off_duty':
        return InterventionType.temporaryOffDuty;
      default:
        return InterventionType.counselling;
    }
  }

  String get displayName {
    switch (this) {
      case InterventionType.workloadAdjustment:
        return 'Workload Balancing & Pacing';
      case InterventionType.leaveGranted:
        return 'Operational Respite Leave';
      case InterventionType.shiftChange:
        return 'Shift Schedule Rotation';
      case InterventionType.lightDuty:
        return 'Light Duty Temporary Assignment';
      case InterventionType.counselling:
        return 'Confidential Counselling Session';
      case InterventionType.temporaryOffDuty:
        return 'Clinician-Recommended Medical Rest';
    }
  }
}

enum InterventionStatus {
  proposed,
  accepted,
  inProgress,
  completed,
  declined;

  String get dbValue {
    switch (this) {
      case InterventionStatus.proposed:
        return 'proposed';
      case InterventionStatus.accepted:
        return 'accepted';
      case InterventionStatus.inProgress:
        return 'in_progress';
      case InterventionStatus.completed:
        return 'completed';
      case InterventionStatus.declined:
        return 'declined';
    }
  }

  static InterventionStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'accepted':
        return InterventionStatus.accepted;
      case 'in_progress':
        return InterventionStatus.inProgress;
      case 'completed':
        return InterventionStatus.completed;
      case 'declined':
        return InterventionStatus.declined;
      default:
        return InterventionStatus.proposed;
    }
  }

  String get displayName {
    switch (this) {
      case InterventionStatus.proposed:
        return 'Offered (Awaiting Choice)';
      case InterventionStatus.accepted:
        return 'Accepted by Officer';
      case InterventionStatus.inProgress:
        return 'In Progress';
      case InterventionStatus.completed:
        return 'Completed';
      case InterventionStatus.declined:
        return 'Declined by Officer';
    }
  }
}

class SupportIntervention {
  final String id;
  final String officerId;
  final String recommendedByType; // 'welfare_officer', 'clinician', 'system_tier'
  final InterventionType interventionType;
  final InterventionStatus status;
  final DateTime proposedAt;
  final DateTime? actionedAt;
  final String? notes;

  const SupportIntervention({
    required this.id,
    required this.officerId,
    required this.recommendedByType,
    required this.interventionType,
    required this.status,
    required this.proposedAt,
    this.actionedAt,
    this.notes,
  });

  bool get isAutomatedOnly => recommendedByType == 'system_tier';

  factory SupportIntervention.fromMap(Map<String, dynamic> map) {
    return SupportIntervention(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      recommendedByType: map['recommended_by_type'] as String? ?? 'welfare_officer',
      interventionType: InterventionType.fromString(map['intervention_type'] as String? ?? 'counselling'),
      status: InterventionStatus.fromString(map['status'] as String? ?? 'proposed'),
      proposedAt: DateTime.tryParse(map['proposed_at'] as String? ?? '') ?? DateTime.now(),
      actionedAt: map['actioned_at'] != null ? DateTime.tryParse(map['actioned_at'] as String) : null,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'recommended_by_type': recommendedByType,
      'intervention_type': interventionType.dbValue,
      'status': status.dbValue,
      'proposed_at': proposedAt.toIso8601String(),
      'actioned_at': actionedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
