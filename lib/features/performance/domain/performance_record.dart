// lib/features/performance/domain/performance_record.dart
// Operational performance metrics and developmental areas (strictly non-clinical)

class PerformanceRecord {
  final String id;
  final String officerId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double overallPerformanceScore;
  final Map<String, double> evaluatedAreas; // Non-clinical: weapon drill, navigation, endurance
  final String? improvementSuggestions;
  final String? evaluatedByIdentityId;
  final DateTime createdAt;

  const PerformanceRecord({
    required this.id,
    required this.officerId,
    required this.periodStart,
    required this.periodEnd,
    required this.overallPerformanceScore,
    required this.evaluatedAreas,
    this.improvementSuggestions,
    this.evaluatedByIdentityId,
    required this.createdAt,
  });

  PerformanceRecord copyWith({
    double? overallPerformanceScore,
    Map<String, double>? evaluatedAreas,
    String? improvementSuggestions,
  }) {
    return PerformanceRecord(
      id: id,
      officerId: officerId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      overallPerformanceScore: overallPerformanceScore ?? this.overallPerformanceScore,
      evaluatedAreas: evaluatedAreas ?? this.evaluatedAreas,
      improvementSuggestions: improvementSuggestions ?? this.improvementSuggestions,
      evaluatedByIdentityId: evaluatedByIdentityId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'officer_id': officerId,
        'period_start': periodStart.toIso8601String().split('T').first,
        'period_end': periodEnd.toIso8601String().split('T').first,
        'overall_performance_score': overallPerformanceScore,
        'evaluated_areas': evaluatedAreas,
        'improvement_suggestions': improvementSuggestions,
        'evaluated_by_identity_id': evaluatedByIdentityId,
        'created_at': createdAt.toIso8601String(),
      };

  factory PerformanceRecord.fromJson(Map<String, dynamic> json) {
    final rawAreas = json['evaluated_areas'];
    final Map<String, double> parsedAreas = {};
    if (rawAreas is Map) {
      rawAreas.forEach((k, v) {
        parsedAreas[k.toString()] = (v as num).toDouble();
      });
    }

    return PerformanceRecord(
      id: json['id'] as String,
      officerId: json['officer_id'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      overallPerformanceScore: (json['overall_performance_score'] as num?)?.toDouble() ?? 0.0,
      evaluatedAreas: parsedAreas,
      improvementSuggestions: json['improvement_suggestions'] as String?,
      evaluatedByIdentityId: json['evaluated_by_identity_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
