// lib/features/family/domain/family_training_module.dart
// Psychoeducational resilience modules and Tele-MANAS guides for military families

class FamilyTrainingModule {
  final String id;
  final String title;
  final String description;
  final String contentType; // 'resilience_guide', 'video_module', 'article'
  final int durationMinutes;
  final String targetAudience; // 'spouse', 'parents', 'all'
  final String? resourceLink;

  const FamilyTrainingModule({
    required this.id,
    required this.title,
    required this.description,
    required this.contentType,
    required this.durationMinutes,
    this.targetAudience = 'all',
    this.resourceLink,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'content_type': contentType,
        'duration_minutes': durationMinutes,
        'target_audience': targetAudience,
        'resource_link': resourceLink,
      };

  factory FamilyTrainingModule.fromJson(Map<String, dynamic> json) {
    return FamilyTrainingModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      contentType: json['content_type'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 10,
      targetAudience: json['target_audience'] as String? ?? 'all',
      resourceLink: json['resource_link'] as String?,
    );
  }
}
