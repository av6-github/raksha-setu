// lib/features/family/domain/family_consent.dart
// Granular, revocable consent for family communications and quiet hour windows

class FamilyConsent {
  final String id;
  final String officerId;
  final String familyMemberId;
  final bool shareFlashNotifications;
  final bool shareMoraleMessages;
  final bool shareTrainingMaterial;
  final bool emergencyContactAuthorized;
  final int notificationWindowStartHour; // e.g. 18 (6:00 PM)
  final int notificationWindowEndHour; // e.g. 21 (9:00 PM)
  final bool isRevoked;
  final DateTime grantedAt;
  final DateTime? revokedAt;

  const FamilyConsent({
    required this.id,
    required this.officerId,
    required this.familyMemberId,
    this.shareFlashNotifications = true,
    this.shareMoraleMessages = true,
    this.shareTrainingMaterial = true,
    this.emergencyContactAuthorized = true,
    this.notificationWindowStartHour = 18,
    this.notificationWindowEndHour = 21,
    this.isRevoked = false,
    required this.grantedAt,
    this.revokedAt,
  });

  /// Validates whether a notification can be delivered at the specified timestamp.
  /// Strictly blocks delivery if consent is revoked or if the current hour is outside
  /// the officer's defined quiet window, preventing operational duty schedule leakage.
  bool isNotificationAllowedAt(DateTime timestamp) {
    if (isRevoked || !shareFlashNotifications) return false;

    final hour = timestamp.hour;
    if (notificationWindowStartHour <= notificationWindowEndHour) {
      return hour >= notificationWindowStartHour && hour < notificationWindowEndHour;
    } else {
      // Overnight window (e.g. 20 to 2)
      return hour >= notificationWindowStartHour || hour < notificationWindowEndHour;
    }
  }

  void assertActiveConsent({String purpose = 'Family communication'}) {
    if (isRevoked) {
      throw StateError('Access denied: Officer has revoked consent for $purpose with this family member.');
    }
  }

  FamilyConsent copyWith({
    bool? shareFlashNotifications,
    bool? shareMoraleMessages,
    bool? shareTrainingMaterial,
    bool? emergencyContactAuthorized,
    int? notificationWindowStartHour,
    int? notificationWindowEndHour,
    bool? isRevoked,
    DateTime? revokedAt,
  }) {
    return FamilyConsent(
      id: id,
      officerId: officerId,
      familyMemberId: familyMemberId,
      shareFlashNotifications: shareFlashNotifications ?? this.shareFlashNotifications,
      shareMoraleMessages: shareMoraleMessages ?? this.shareMoraleMessages,
      shareTrainingMaterial: shareTrainingMaterial ?? this.shareTrainingMaterial,
      emergencyContactAuthorized: emergencyContactAuthorized ?? this.emergencyContactAuthorized,
      notificationWindowStartHour: notificationWindowStartHour ?? this.notificationWindowStartHour,
      notificationWindowEndHour: notificationWindowEndHour ?? this.notificationWindowEndHour,
      isRevoked: isRevoked ?? this.isRevoked,
      grantedAt: grantedAt,
      revokedAt: revokedAt ?? this.revokedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'officer_id': officerId,
        'family_member_id': familyMemberId,
        'share_flash_notifications': shareFlashNotifications,
        'share_morale_messages': shareMoraleMessages,
        'share_training_material': shareTrainingMaterial,
        'emergency_contact_authorized': emergencyContactAuthorized,
        'notification_window_start_hour': notificationWindowStartHour,
        'notification_window_end_hour': notificationWindowEndHour,
        'is_revoked': isRevoked,
        'granted_at': grantedAt.toIso8601String(),
        'revoked_at': revokedAt?.toIso8601String(),
      };

  factory FamilyConsent.fromJson(Map<String, dynamic> json) {
    return FamilyConsent(
      id: json['id'] as String,
      officerId: json['officer_id'] as String,
      familyMemberId: json['family_member_id'] as String,
      shareFlashNotifications: json['share_flash_notifications'] as bool? ?? true,
      shareMoraleMessages: json['share_morale_messages'] as bool? ?? true,
      shareTrainingMaterial: json['share_training_material'] as bool? ?? true,
      emergencyContactAuthorized: json['emergency_contact_authorized'] as bool? ?? true,
      notificationWindowStartHour: json['notification_window_start_hour'] as int? ?? 18,
      notificationWindowEndHour: json['notification_window_end_hour'] as int? ?? 21,
      isRevoked: json['is_revoked'] as bool? ?? false,
      grantedAt: DateTime.parse(json['granted_at'] as String),
      revokedAt: json['revoked_at'] != null ? DateTime.parse(json['revoked_at'] as String) : null,
    );
  }
}
