// lib/features/consent/domain/consent_record.dart
// Domain model for granular officer consent records

class ConsentRecord {
  final String id;
  final String officerId;
  final String consentType; // 'biometrics', 'family_sharing', 'acr_read_context', 'public_recognition'
  final bool isGranted;
  final DateTime grantedAt;
  final DateTime? revokedAt;
  final String? scope;
  final String version;

  const ConsentRecord({
    required this.id,
    required this.officerId,
    required this.consentType,
    required this.isGranted,
    required this.grantedAt,
    this.revokedAt,
    this.scope,
    this.version = '1.0',
  });

  String get title {
    switch (consentType) {
      case 'biometrics':
        return 'Voluntary Wearable Biometrics';
      case 'family_sharing':
        return 'Family Well-Being Messaging';
      case 'acr_read_context':
        return 'Non-Clinical Context in ACR Note';
      case 'public_recognition':
        return 'Public Institutional Recognition';
      case 'research_co_design':
        return 'Anonymous Research & Co-Design';
      default:
        return consentType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get description {
    switch (consentType) {
      case 'biometrics':
        return 'Permit voluntary sync of resting heart-rate and sleep data. Can be revoked at any time with immediate purge.';
      case 'family_sharing':
        return 'Allow approved family members to send morale vault messages and receive flash supportive updates.';
      case 'acr_read_context':
        return 'Allow reporting officers to view non-clinical duty context. Strict firewall blocks any stress scores.';
      case 'public_recognition':
        return 'Authorize displaying awarded institutional commendations publicly on the bulletin board.';
      case 'research_co_design':
        return 'Contribute anonymized model metrics for ongoing bias and fairness auditing.';
      default:
        return 'Consent setting for $consentType';
    }
  }

  ConsentRecord copyWith({
    bool? isGranted,
    DateTime? revokedAt,
    DateTime? grantedAt,
  }) {
    return ConsentRecord(
      id: id,
      officerId: officerId,
      consentType: consentType,
      isGranted: isGranted ?? this.isGranted,
      grantedAt: grantedAt ?? this.grantedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      scope: scope,
      version: version,
    );
  }

  factory ConsentRecord.fromMap(Map<String, dynamic> map) {
    return ConsentRecord(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      consentType: map['consent_type'] as String,
      isGranted: map['is_granted'] as bool? ?? false,
      grantedAt: DateTime.tryParse(map['granted_at'] as String? ?? '') ?? DateTime.now(),
      revokedAt: map['revoked_at'] != null ? DateTime.tryParse(map['revoked_at'] as String) : null,
      scope: map['scope'] as String?,
      version: map['version'] as String? ?? '1.0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'consent_type': consentType,
      'is_granted': isGranted,
      'granted_at': grantedAt.toIso8601String(),
      'revoked_at': revokedAt?.toIso8601String(),
      'scope': scope,
      'version': version,
    };
  }
}
