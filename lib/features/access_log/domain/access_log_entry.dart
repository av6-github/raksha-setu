// lib/features/access_log/domain/access_log_entry.dart
// Domain model for transparent officer access audit trail

class AccessLogEntry {
  final String id;
  final String action;
  final String actorRole;
  final String resourceType;
  final String resourceId;
  final DateTime timestamp;
  final String? reason;

  const AccessLogEntry({
    required this.id,
    required this.action,
    required this.actorRole,
    required this.resourceType,
    required this.resourceId,
    required this.timestamp,
    this.reason,
  });

  String get actionDisplay {
    switch (action) {
      case 'READ_CLINICAL':
        return 'Confidential Clinical Review';
      case 'READ_PROFILE':
        return 'Profile Identity Viewed';
      case 'UPDATE_RISK':
        return 'Predictive Risk Calculation';
      case 'BREAK_GLASS':
        return 'Emergency Break-Glass Access';
      case 'SUBMIT_CHECKIN':
        return 'Biweekly Check-In Submitted';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  factory AccessLogEntry.fromMap(Map<String, dynamic> map) {
    return AccessLogEntry(
      id: map['id'] as String,
      action: map['action'] as String,
      actorRole: map['actor_role'] as String? ?? 'Authorized Officer',
      resourceType: map['resource_type'] as String,
      resourceId: map['resource_id'] as String,
      timestamp: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      reason: map['metadata'] != null ? map['metadata']['reason'] as String? : null,
    );
  }
}
