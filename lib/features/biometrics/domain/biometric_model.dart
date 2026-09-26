// lib/features/biometrics/domain/biometric_model.dart
// Domain model for voluntary wearable biometric telemetry

class BiometricModel {
  final String? id;
  final String officerId;
  final DateTime recordedDate;
  final double? sleepHours;
  final double? hrvRmssd;
  final int? restingHeartRate;
  final int? activitySteps;
  final String deviceSource; // 'fitbit', 'apple_health', 'garmin', 'manual'
  final bool consentVerified;

  const BiometricModel({
    this.id,
    required this.officerId,
    required this.recordedDate,
    this.sleepHours,
    this.hrvRmssd,
    this.restingHeartRate,
    this.activitySteps,
    this.deviceSource = 'manual',
    this.consentVerified = true,
  });

  Map<String, dynamic> toDbPayload() {
    return {
      'officer_id': officerId,
      'recorded_date': recordedDate.toIso8601String().split('T').first,
      'sleep_hours': sleepHours,
      'hrv_rmssd': hrvRmssd,
      'resting_heart_rate': restingHeartRate,
      'activity_steps': activitySteps,
      'device_source': deviceSource,
      'consent_verified': consentVerified,
    };
  }

  factory BiometricModel.fromMap(Map<String, dynamic> map) {
    return BiometricModel(
      id: map['id'] as String?,
      officerId: map['officer_id'] as String,
      recordedDate: DateTime.tryParse(map['recorded_date'] as String? ?? '') ?? DateTime.now(),
      sleepHours: (map['sleep_hours'] as num?)?.toDouble(),
      hrvRmssd: (map['hrv_rmssd'] as num?)?.toDouble(),
      restingHeartRate: (map['resting_heart_rate'] as num?)?.toInt(),
      activitySteps: (map['activity_steps'] as num?)?.toInt(),
      deviceSource: map['device_source'] as String? ?? 'manual',
      consentVerified: map['consent_verified'] as bool? ?? false,
    );
  }
}
