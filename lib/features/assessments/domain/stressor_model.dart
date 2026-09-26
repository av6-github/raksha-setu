// lib/features/assessments/domain/stressor_model.dart
// Domain model for contextual operational, personal, and family stressors

class StressorModel {
  final String? id;
  final String officerId;
  final String category; // 'family', 'financial', 'organisational', 'operational', 'health'
  final String? description;
  final int severityLevel; // 1-5
  final bool isActive;
  final DateTime reportedAt;

  const StressorModel({
    this.id,
    required this.officerId,
    required this.category,
    this.description,
    required this.severityLevel,
    this.isActive = true,
    required this.reportedAt,
  });

  String get categoryDisplay {
    switch (category) {
      case 'family':
        return 'Family & Domestic Separation';
      case 'financial':
        return 'Financial / Compensation Stress';
      case 'organisational':
        return 'Posting & Leave Friction';
      case 'operational':
        return 'High-Altitude / Border Deployment Hardship';
      case 'health':
        return 'Physical Exhaustion or Injury';
      default:
        return category.toUpperCase();
    }
  }

  Map<String, dynamic> toDbPayload() {
    return {
      'officer_id': officerId,
      'category': category,
      'description_encrypted': description,
      'severity_level': severityLevel,
      'is_active': isActive,
      'reported_at': reportedAt.toIso8601String(),
    };
  }

  factory StressorModel.fromMap(Map<String, dynamic> map) {
    return StressorModel(
      id: map['id'] as String?,
      officerId: map['officer_id'] as String,
      category: map['category'] as String,
      description: map['description_encrypted'] as String?,
      severityLevel: (map['severity_level'] as num?)?.toInt() ?? 3,
      isActive: map['is_active'] as bool? ?? true,
      reportedAt: DateTime.tryParse(map['reported_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
