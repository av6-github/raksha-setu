// lib/features/performance/domain/progress_update.dart
// Non-clinical status updates visible to commanders

class ProgressUpdate {
  final String id;
  final String officerId;
  final String? updatedByIdentityId;
  final String statusIndicator; // 'improving', 'stable', 'requires_support'
  final String? publicContextNote;
  final bool acrSynced;
  final DateTime createdAt;

  const ProgressUpdate({
    required this.id,
    required this.officerId,
    this.updatedByIdentityId,
    this.statusIndicator = 'stable',
    this.publicContextNote,
    this.acrSynced = false,
    required this.createdAt,
  });

  ProgressUpdate copyWith({
    String? statusIndicator,
    String? publicContextNote,
    bool? acrSynced,
  }) {
    return ProgressUpdate(
      id: id,
      officerId: officerId,
      updatedByIdentityId: updatedByIdentityId,
      statusIndicator: statusIndicator ?? this.statusIndicator,
      publicContextNote: publicContextNote ?? this.publicContextNote,
      acrSynced: acrSynced ?? this.acrSynced,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'officer_id': officerId,
        'updated_by_identity_id': updatedByIdentityId,
        'status_indicator': statusIndicator,
        'public_context_note': publicContextNote,
        'acr_synced': acrSynced,
        'created_at': createdAt.toIso8601String(),
      };

  factory ProgressUpdate.fromJson(Map<String, dynamic> json) {
    return ProgressUpdate(
      id: json['id'] as String,
      officerId: json['officer_id'] as String,
      updatedByIdentityId: json['updated_by_identity_id'] as String?,
      statusIndicator: json['status_indicator'] as String? ?? 'stable',
      publicContextNote: json['public_context_note'] as String?,
      acrSynced: json['acr_synced'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
