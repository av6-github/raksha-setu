// lib/features/commander_dashboard/domain/roster_recommendation.dart
// Algorithmic operational roster recommendations to alleviate unit-level systemic fatigue

enum RecommendationPriority {
  routine,
  advisory,
  urgent;

  String get displayName => name.toUpperCase();
}

class RosterRecommendation {
  final String id;
  final String unitCode;
  final String title;
  final String rationale;
  final RecommendationPriority priority;
  final int affectedPersonnelCount;
  final String suggestedAction;
  final bool isAcknowledged;

  const RosterRecommendation({
    required this.id,
    required this.unitCode,
    required this.title,
    required this.rationale,
    required this.priority,
    required this.affectedPersonnelCount,
    required this.suggestedAction,
    this.isAcknowledged = false,
  });

  RosterRecommendation copyWith({bool? isAcknowledged}) {
    return RosterRecommendation(
      id: id,
      unitCode: unitCode,
      title: title,
      rationale: rationale,
      priority: priority,
      affectedPersonnelCount: affectedPersonnelCount,
      suggestedAction: suggestedAction,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unit_code': unitCode,
        'title': title,
        'rationale': rationale,
        'priority': priority.name,
        'affected_personnel_count': affectedPersonnelCount,
        'suggested_action': suggestedAction,
        'is_acknowledged': isAcknowledged,
      };
}
