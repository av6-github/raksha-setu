// lib/features/crisis/domain/crisis_event.dart
// Domain model for emergency crisis events and human escalation triggers

class CrisisEvent {
  final String id;
  final String officerId;
  final String triggerSource; // 'phq9_item9', 'cssrs', 'direct_disclosure', 'hotline_call'
  final String status; // 'active', 'escalated', 'counselor_engaged', 'resolved'
  final String severityLevel; // 'moderate', 'high', 'imminent'
  final DateTime triggeredAt;
  final DateTime? counselorNotifiedAt;
  final DateTime? officerReachedAt;
  final DateTime? resolvedAt;
  final bool safetyPlanCreated;

  const CrisisEvent({
    required this.id,
    required this.officerId,
    required this.triggerSource,
    this.status = 'active',
    this.severityLevel = 'high',
    required this.triggeredAt,
    this.counselorNotifiedAt,
    this.officerReachedAt,
    this.resolvedAt,
    this.safetyPlanCreated = false,
  });

  bool get isImminentThreat => severityLevel == 'imminent';

  factory CrisisEvent.fromMap(Map<String, dynamic> map) {
    return CrisisEvent(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      triggerSource: map['trigger_source'] as String? ?? 'direct_disclosure',
      status: map['status'] as String? ?? 'active',
      severityLevel: map['severity_level'] as String? ?? 'high',
      triggeredAt: DateTime.tryParse(map['triggered_at'] as String? ?? '') ?? DateTime.now(),
      counselorNotifiedAt: map['counselor_notified_at'] != null
          ? DateTime.tryParse(map['counselor_notified_at'] as String)
          : null,
      officerReachedAt: map['officer_reached_at'] != null
          ? DateTime.tryParse(map['officer_reached_at'] as String)
          : null,
      resolvedAt: map['resolved_at'] != null
          ? DateTime.tryParse(map['resolved_at'] as String)
          : null,
      safetyPlanCreated: map['safety_plan_created'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'trigger_source': triggerSource,
      'status': status,
      'severity_level': severityLevel,
      'triggered_at': triggeredAt.toIso8601String(),
      'counselor_notified_at': counselorNotifiedAt?.toIso8601String(),
      'officer_reached_at': officerReachedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'safety_plan_created': safetyPlanCreated,
    };
  }

  Map<String, dynamic> toDbPayload() {
    return {
      'officer_id': officerId,
      'trigger_source': triggerSource,
      'status': status,
      'desk_routed': 'force_tele_counselling',
      'triggered_at': triggeredAt.toIso8601String(),
    };
  }
}
