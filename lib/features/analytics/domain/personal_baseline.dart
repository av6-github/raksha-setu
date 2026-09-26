// lib/features/analytics/domain/personal_baseline.dart
// 4-6 week personal baseline with Bayesian shrinkage toward cohort priors

import 'dart:math';
import 'cohort_prior.dart';

class PersonalBaseline {
  final String officerId;
  final int version;
  final int sampleCount; // Number of days of observation
  final bool isColdStart; // True if < 28 days of personal data
  final double sleepMean;
  final double sleepStd;
  final double dutyHoursMean;
  final double dutyHoursStd;
  final double checkInDistressMean;
  final double checkInDistressStd;
  final DateTime calibratedAt;

  const PersonalBaseline({
    required this.officerId,
    required this.version,
    required this.sampleCount,
    required this.isColdStart,
    required this.sleepMean,
    required this.sleepStd,
    required this.dutyHoursMean,
    required this.dutyHoursStd,
    required this.checkInDistressMean,
    required this.checkInDistressStd,
    required this.calibratedAt,
  });

  /// Calibrates an individual baseline applying Bayesian shrinkage.
  /// For new joiners (n < 28), estimates are shrunk smoothly toward cohort priors.
  /// When n >= 28, the officer's empirical data dominates.
  factory PersonalBaseline.calibrate({
    required String officerId,
    required List<double> sleepObservations,
    required List<double> dutyObservations,
    required List<double> distressObservations,
    required CohortPrior cohortPrior,
    int version = 1,
  }) {
    final n = max(sleepObservations.length, max(dutyObservations.length, distressObservations.length));
    final n0 = cohortPrior.pseudoCount;
    final isColdStart = n < 28;

    // Helper: compute shrunk mean
    double shrinkMean(List<double> obs, double priorMean) {
      if (obs.isEmpty) return priorMean;
      final empiricalMean = obs.reduce((a, b) => a + b) / obs.length;
      final count = obs.length;
      return ((count * empiricalMean) + (n0 * priorMean)) / (count + n0);
    }

    // Helper: compute shrunk standard deviation
    double shrinkStd(List<double> obs, double priorStd, double computedMean) {
      if (obs.length < 2) return priorStd;
      final variance = obs.map((x) => pow(x - computedMean, 2)).reduce((a, b) => a + b) / obs.length;
      final empiricalStd = sqrt(variance);
      final count = obs.length;
      final shrunkVariance = ((count * pow(empiricalStd, 2)) + (n0 * pow(priorStd, 2))) / (count + n0);
      return sqrt(shrunkVariance);
    }

    final sleepM = shrinkMean(sleepObservations, cohortPrior.sleepHoursMean);
    final sleepS = shrinkStd(sleepObservations, cohortPrior.sleepHoursStd, sleepM);

    final dutyM = shrinkMean(dutyObservations, cohortPrior.dutyHoursMean);
    final dutyS = shrinkStd(dutyObservations, cohortPrior.dutyHoursStd, dutyM);

    final distressM = shrinkMean(distressObservations, cohortPrior.checkInDistressMean);
    final distressS = shrinkStd(distressObservations, cohortPrior.checkInDistressStd, distressM);

    return PersonalBaseline(
      officerId: officerId,
      version: version,
      sampleCount: n,
      isColdStart: isColdStart,
      sleepMean: sleepM,
      sleepStd: max(sleepS, 0.3), // avoid zero-division in CUSUM
      dutyHoursMean: dutyM,
      dutyHoursStd: max(dutyS, 0.5),
      checkInDistressMean: distressM,
      checkInDistressStd: max(distressS, 0.3),
      calibratedAt: DateTime.now(),
    );
  }

  factory PersonalBaseline.fromMap(Map<String, dynamic> map) {
    return PersonalBaseline(
      officerId: map['officer_id'] as String,
      version: (map['version'] as num?)?.toInt() ?? 1,
      sampleCount: (map['sample_count'] as num?)?.toInt() ?? 0,
      isColdStart: map['is_cold_start'] as bool? ?? true,
      sleepMean: (map['sleep_mean'] as num?)?.toDouble() ?? 7.0,
      sleepStd: (map['sleep_std'] as num?)?.toDouble() ?? 1.0,
      dutyHoursMean: (map['duty_hours_mean'] as num?)?.toDouble() ?? 8.0,
      dutyHoursStd: (map['duty_hours_std'] as num?)?.toDouble() ?? 1.5,
      checkInDistressMean: (map['checkin_distress_mean'] as num?)?.toDouble() ?? 1.5,
      checkInDistressStd: (map['checkin_distress_std'] as num?)?.toDouble() ?? 1.0,
      calibratedAt: DateTime.tryParse(map['calibrated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'officer_id': officerId,
      'version': version,
      'sample_count': sampleCount,
      'is_cold_start': isColdStart,
      'sleep_mean': sleepMean,
      'sleep_std': sleepStd,
      'duty_hours_mean': dutyHoursMean,
      'duty_hours_std': dutyHoursStd,
      'checkin_distress_mean': checkInDistressMean,
      'checkin_distress_std': checkInDistressStd,
      'calibrated_at': calibratedAt.toIso8601String(),
    };
  }
}
