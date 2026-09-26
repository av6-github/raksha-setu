// lib/features/consent/domain/family_consent.dart
// Domain model for granular family sharing consent

class FamilyConsent {
  final String id;
  final String officerId;
  final String familyMemberId;
  final String familyMemberName;
  final String relation;
  final bool shareFlashNotifications;
  final bool shareMoraleMessages;
  final bool shareTrainingMaterial;
  final bool emergencyContactAuthorized;
  final String? notificationWindowStart;
  final String? notificationWindowEnd;
  final bool isRevoked;
  final DateTime grantedAt;
  final DateTime? revokedAt;

  const FamilyConsent({
    required this.id,
    required this.officerId,
    required this.familyMemberId,
    required this.familyMemberName,
    required this.relation,
    this.shareFlashNotifications = false,
    this.shareMoraleMessages = true,
    this.shareTrainingMaterial = true,
    this.emergencyContactAuthorized = true,
    this.notificationWindowStart = '09:00',
    this.notificationWindowEnd = '20:00',
    this.isRevoked = false,
    required this.grantedAt,
    this.revokedAt,
  });

  FamilyConsent copyWith({
    bool? shareFlashNotifications,
    bool? shareMoraleMessages,
    bool? shareTrainingMaterial,
    bool? emergencyContactAuthorized,
    String? notificationWindowStart,
    String? notificationWindowEnd,
    bool? isRevoked,
    DateTime? revokedAt,
  }) {
    return FamilyConsent(
      id: id,
      officerId: officerId,
      familyMemberId: familyMemberId,
      familyMemberName: familyMemberName,
      relation: relation,
      shareFlashNotifications: shareFlashNotifications ?? this.shareFlashNotifications,
      shareMoraleMessages: shareMoraleMessages ?? this.shareMoraleMessages,
      shareTrainingMaterial: shareTrainingMaterial ?? this.shareTrainingMaterial,
      emergencyContactAuthorized: emergencyContactAuthorized ?? this.emergencyContactAuthorized,
      notificationWindowStart: notificationWindowStart ?? this.notificationWindowStart,
      notificationWindowEnd: notificationWindowEnd ?? this.notificationWindowEnd,
      isRevoked: isRevoked ?? this.isRevoked,
      grantedAt: grantedAt,
      revokedAt: revokedAt ?? this.revokedAt,
    );
  }

  factory FamilyConsent.fromMap(Map<String, dynamic> map) {
    return FamilyConsent(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      familyMemberId: map['family_member_id'] as String,
      familyMemberName: map['family_members'] != null
          ? '${map['family_members']['first_name']} ${map['family_members']['last_name'] ?? ''}'.trim()
          : 'Family Member',
      relation: map['family_members'] != null ? map['family_members']['relation'] as String? ?? 'Family' : 'Family',
      shareFlashNotifications: map['share_flash_notifications'] as bool? ?? false,
      shareMoraleMessages: map['share_morale_messages'] as bool? ?? true,
      shareTrainingMaterial: map['share_training_material'] as bool? ?? true,
      emergencyContactAuthorized: map['emergency_contact_authorized'] as bool? ?? true,
      notificationWindowStart: map['notification_window_start'] as String?,
      notificationWindowEnd: map['notification_window_end'] as String?,
      isRevoked: map['is_revoked'] as bool? ?? false,
      grantedAt: DateTime.tryParse(map['granted_at'] as String? ?? '') ?? DateTime.now(),
      revokedAt: map['revoked_at'] != null ? DateTime.tryParse(map['revoked_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'family_member_id': familyMemberId,
      'share_flash_notifications': shareFlashNotifications,
      'share_morale_messages': shareMoraleMessages,
      'share_training_material': shareTrainingMaterial,
      'emergency_contact_authorized': emergencyContactAuthorized,
      'notification_window_start': notificationWindowStart,
      'notification_window_end': notificationWindowEnd,
      'is_revoked': isRevoked,
      'granted_at': grantedAt.toIso8601String(),
      'revoked_at': revokedAt?.toIso8601String(),
    };
  }
}
