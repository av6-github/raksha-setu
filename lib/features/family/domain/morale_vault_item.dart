// lib/features/family/domain/morale_vault_item.dart
// Audio and video media uploaded to bolster officer morale, subject to OPSEC reviews

enum MoraleMediaSecurityStatus {
  safe,
  pendingReview,
  autoFlagged,
  humanApproved,
  rejected;

  static MoraleMediaSecurityStatus fromString(String val) {
    return MoraleMediaSecurityStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() ||
             e.name.replaceAll(RegExp(r'([A-Z])'), r'_$1').toLowerCase() == val.toLowerCase(),
      orElse: () => MoraleMediaSecurityStatus.pendingReview,
    );
  }

  String get displayName {
    switch (this) {
      case MoraleMediaSecurityStatus.safe:
      case MoraleMediaSecurityStatus.humanApproved:
        return 'Approved';
      case MoraleMediaSecurityStatus.autoFlagged:
        return 'Quarantined (OPSEC Review)';
      case MoraleMediaSecurityStatus.pendingReview:
        return 'Under Security Review';
      case MoraleMediaSecurityStatus.rejected:
        return 'Rejected (Security Policy)';
    }
  }
}

class MoraleVaultItem {
  final String id;
  final String officerId;
  final String familyMemberId;
  final String familyMemberName;
  final String mediaUrl;
  final String mediaType; // 'audio', 'video', 'image'
  final MoraleMediaSecurityStatus securityStatus;
  final String transcriptOrCaption;
  final List<String> opsecFlags;
  final DateTime uploadedAt;
  final DateTime? reviewedAt;
  final String? reviewerNotes;

  const MoraleVaultItem({
    required this.id,
    required this.officerId,
    required this.familyMemberId,
    required this.familyMemberName,
    required this.mediaUrl,
    required this.mediaType,
    required this.securityStatus,
    required this.transcriptOrCaption,
    this.opsecFlags = const [],
    required this.uploadedAt,
    this.reviewedAt,
    this.reviewerNotes,
  });

  /// HARD SECURITY RULE: An officer can ONLY access media if it has been cleared as safe or human-approved.
  /// Quarantined or flagged media is strictly quarantined and inaccessible.
  bool get isAvailableToOfficer =>
      securityStatus == MoraleMediaSecurityStatus.safe ||
      securityStatus == MoraleMediaSecurityStatus.humanApproved;

  MoraleVaultItem copyWith({
    MoraleMediaSecurityStatus? securityStatus,
    List<String>? opsecFlags,
    DateTime? reviewedAt,
    String? reviewerNotes,
  }) {
    return MoraleVaultItem(
      id: id,
      officerId: officerId,
      familyMemberId: familyMemberId,
      familyMemberName: familyMemberName,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      securityStatus: securityStatus ?? this.securityStatus,
      transcriptOrCaption: transcriptOrCaption,
      opsecFlags: opsecFlags ?? this.opsecFlags,
      uploadedAt: uploadedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'officer_id': officerId,
        'family_member_id': familyMemberId,
        'family_member_name': familyMemberName,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'security_status': securityStatus.name,
        'transcript_or_caption': transcriptOrCaption,
        'opsec_flags': opsecFlags,
        'uploaded_at': uploadedAt.toIso8601String(),
        'reviewed_at': reviewedAt?.toIso8601String(),
        'reviewer_notes': reviewerNotes,
      };
}
