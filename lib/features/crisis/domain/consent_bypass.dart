// lib/features/crisis/domain/consent_bypass.dart
// Emergency break-glass consent bypass for imminent life threat with immutable audit logging

import '../../../core/errors/app_exceptions.dart';

class EmergencyConsentBypass {
  final String id;
  final String officerId;
  final String responderId;
  final String imminentThreatRationale;
  final List<String> emergencyContactsNotified;
  final DateTime timestamp;

  const EmergencyConsentBypass({
    required this.id,
    required this.officerId,
    required this.responderId,
    required this.imminentThreatRationale,
    required this.emergencyContactsNotified,
    required this.timestamp,
  });

  /// Validates that consent bypass is strictly invoked for imminent life threat.
  /// Any attempt to bypass consent for administrative, routine, or disciplinary reasons is legally void.
  void validateEmergencyJustification() {
    final lower = imminentThreatRationale.toLowerCase();
    final isValid = lower.contains('imminent') ||
        lower.contains('suicide') ||
        lower.contains('self-harm') ||
        lower.contains('life threat') ||
        lower.contains('emergency') ||
        lower.contains('c-ssrs');

    if (!isValid || imminentThreatRationale.trim().length < 15) {
      throw const FirewallViolationException(
        'Consent Bypass Rejected: Break-glass emergency protocol can ONLY be invoked for substantiated, '
        'imminent life-threat crises. Administrative or non-emergency usage is strictly prohibited.',
      );
    }
  }

  factory EmergencyConsentBypass.fromMap(Map<String, dynamic> map) {
    return EmergencyConsentBypass(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      responderId: map['responder_id'] as String? ?? 'system_emergency_trigger',
      imminentThreatRationale: map['imminent_threat_rationale'] as String? ?? '',
      emergencyContactsNotified: (map['emergency_contacts_notified'] as List? ?? []).map((e) => e.toString()).toList(),
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    validateEmergencyJustification();
    return {
      'id': id,
      'officer_id': officerId,
      'responder_id': responderId,
      'imminent_threat_rationale': imminentThreatRationale,
      'emergency_contacts_notified': emergencyContactsNotified,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
