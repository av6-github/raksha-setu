// lib/features/checkins/domain/check_in_model.dart
// PHQ-2, GAD-2, sleep, and workload check-in domain model with offline support

class CheckInModel {
  final String? id;
  final String officerId;
  final int phq2Score;
  final int gad2Score;
  final int sleepQualityScore;
  final int workloadScore;
  final String? freeTextEncrypted;
  final bool isOfflineSubmission;
  final DateTime checkInDate;

  const CheckInModel({
    this.id,
    required this.officerId,
    required this.phq2Score,
    required this.gad2Score,
    required this.sleepQualityScore,
    required this.workloadScore,
    this.freeTextEncrypted,
    this.isOfflineSubmission = false,
    required this.checkInDate,
  });

  /// Composite PHQ-2 + GAD-2 score for preliminary screening
  int get combinedScore => phq2Score + gad2Score;

  /// Elevated flag — triggers full assessment referral
  bool get isElevated => combinedScore >= 3;

  Map<String, dynamic> toDbPayload() {
    return {
      'officer_id': officerId,
      'phq2_score': phq2Score,
      'gad2_score': gad2Score,
      'sleep_quality_score': sleepQualityScore,
      'workload_score': workloadScore,
      'free_text_encrypted': freeTextEncrypted,
      'is_offline_submission': isOfflineSubmission,
      'check_in_date': checkInDate.toIso8601String(),
    };
  }

  factory CheckInModel.fromMap(Map<String, dynamic> map) {
    return CheckInModel(
      id: map['id'] as String?,
      officerId: map['officer_id'] as String,
      phq2Score: (map['phq2_score'] as num?)?.toInt() ?? 0,
      gad2Score: (map['gad2_score'] as num?)?.toInt() ?? 0,
      sleepQualityScore: (map['sleep_quality_score'] as num?)?.toInt() ?? 3,
      workloadScore: (map['workload_score'] as num?)?.toInt() ?? 3,
      freeTextEncrypted: map['free_text_encrypted'] as String?,
      isOfflineSubmission: map['is_offline_submission'] as bool? ?? false,
      checkInDate: DateTime.parse(map['check_in_date'] as String),
    );
  }
}
