// lib/features/analytics/domain/deviation_event.dart
// Change-point / deviation detection event structure

class DeviationEvent {
  final String id;
  final String officerId;
  final String feature; // 'sleep_hours', 'workload_hours', 'checkin_distress', 'consecutive_duty'
  final double baselineValue;
  final double currentValue;
  final String direction; // 'elevated', 'depressed', 'sustained'
  final double magnitude; // Z-score or shift relative to standard deviation
  final int durationDays;
  final double confidence; // 0.0 to 1.0 based on CUSUM decision boundary ratio
  final String context;
  final DateTime detectedAt;

  const DeviationEvent({
    required this.id,
    required this.officerId,
    required this.feature,
    required this.baselineValue,
    required this.currentValue,
    required this.direction,
    required this.magnitude,
    required this.durationDays,
    required this.confidence,
    required this.context,
    required this.detectedAt,
  });

  String get featureDisplayName {
    switch (feature) {
      case 'sleep_hours':
        return 'Sleep Duration';
      case 'workload_hours':
        return 'Duty Workload';
      case 'checkin_distress':
        return 'Check-In Self-Reported Distress';
      case 'consecutive_duty':
        return 'Continuous Duty Streak';
      default:
        return feature.replaceAll('_', ' ').toUpperCase();
    }
  }

  factory DeviationEvent.fromMap(Map<String, dynamic> map) {
    return DeviationEvent(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      feature: map['feature'] as String,
      baselineValue: (map['baseline_value'] as num?)?.toDouble() ?? 0.0,
      currentValue: (map['current_value'] as num?)?.toDouble() ?? 0.0,
      direction: map['direction'] as String? ?? 'elevated',
      magnitude: (map['magnitude'] as num?)?.toDouble() ?? 0.0,
      durationDays: (map['duration_days'] as num?)?.toInt() ?? 1,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.8,
      context: map['context'] as String? ?? 'Automated change-point detection trigger',
      detectedAt: DateTime.tryParse(map['detected_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'feature': feature,
      'baseline_value': baselineValue,
      'current_value': currentValue,
      'direction': direction,
      'magnitude': magnitude,
      'duration_days': durationDays,
      'confidence': confidence,
      'context': context,
      'detected_at': detectedAt.toIso8601String(),
    };
  }
}
