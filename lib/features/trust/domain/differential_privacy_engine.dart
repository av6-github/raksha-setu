// lib/features/trust/domain/differential_privacy_engine.dart
// Privacy-Preserving Analytics: K-Anonymity (k >= 10) & Laplace Differential Privacy Engine

import 'dart:math';

class PrivacyPreservationException implements Exception {
  final String message;
  PrivacyPreservationException(this.message);

  @override
  String toString() => 'PrivacyPreservationException: $message';
}

/// Differential Privacy & Anonymity Engine for Commander Aggregate Metrics
class DifferentialPrivacyEngine {
  static const int kAnonymityThreshold = 10;
  static const double defaultEpsilon = 1.0; // Standard privacy budget

  /// Verifies k-anonymity: aggregates are suppressed if cohort count < 10
  static void assertKAnonymity(int cohortSize) {
    if (cohortSize < kAnonymityThreshold) {
      throw PrivacyPreservationException(
        'K-Anonymity Suppression: Cohort size ($cohortSize) is below the mandatory threshold of $kAnonymityThreshold. Individual identity re-identification risk detected. Aggregate metrics are strictly suppressed.',
      );
    }
  }

  /// Verifies that no individual stress ranking or sorting by stress is performed
  static void assertNoIndividualStressRanking(List<String> sortKeys) {
    for (final key in sortKeys) {
      final lower = key.toLowerCase();
      if (lower.contains('stress') || lower.contains('risk') || lower.contains('phq') || lower.contains('gad')) {
        throw PrivacyPreservationException(
          'Privacy Violation: Sorting or ranking named officers by stress/risk score ("$key") is strictly prohibited.',
        );
      }
    }
  }

  /// Adds calibrated Laplace noise: Noise ~ Laplace(0, sensitivity / epsilon)
  /// For an average metric with bounded range [min, max], sensitivity = (max - min) / n
  static double addLaplaceNoise({
    required double trueValue,
    required double minValue,
    required double maxValue,
    required int cohortSize,
    double epsilon = defaultEpsilon,
    Random? rng,
  }) {
    if (cohortSize <= 0) return trueValue;

    final random = rng ?? Random();
    final sensitivity = (maxValue - minValue) / cohortSize;
    final scale = sensitivity / epsilon;

    // Generate Laplace random variable via inverse transform sampling:
    // U ~ Uniform(-0.5, 0.5)
    // X = -scale * sgn(U) * ln(1 - 2*|U|)
    final u = random.nextDouble() - 0.5;
    final sign = u < 0 ? -1.0 : (u > 0 ? 1.0 : 0.0);
    final noise = -scale * sign * log(1.0 - 2.0 * u.abs());

    final noisyValue = trueValue + noise;
    // Clamp to valid domain range
    return noisyValue.clamp(minValue, maxValue);
  }

  /// Generates a privacy-safe aggregate summary for commander dashboards
  static Map<String, dynamic> generateDifferentiallyPrivateSummary({
    required String unitName,
    required int cohortSize,
    required double averageSleepHours,
    required double averageWorkloadHours,
    required double checkInCompletionRate,
    double epsilon = defaultEpsilon,
    Random? rng,
  }) {
    // 1. Enforce k-anonymity
    if (cohortSize < kAnonymityThreshold) {
      return {
        'unit_name': unitName,
        'cohort_size': cohortSize,
        'is_suppressed': true,
        'suppression_reason': 'Cohort size $cohortSize < $kAnonymityThreshold (k-anonymity policy)',
        'dp_applied': false,
      };
    }

    // 2. Apply Laplace noise to each aggregated dimension
    final privateSleep = addLaplaceNoise(
      trueValue: averageSleepHours,
      minValue: 3.0,
      maxValue: 10.0,
      cohortSize: cohortSize,
      epsilon: epsilon,
      rng: rng,
    );

    final privateWorkload = addLaplaceNoise(
      trueValue: averageWorkloadHours,
      minValue: 4.0,
      maxValue: 18.0,
      cohortSize: cohortSize,
      epsilon: epsilon,
      rng: rng,
    );

    final privateCheckInRate = addLaplaceNoise(
      trueValue: checkInCompletionRate,
      minValue: 0.0,
      maxValue: 1.0,
      cohortSize: cohortSize,
      epsilon: epsilon,
      rng: rng,
    );

    return {
      'unit_name': unitName,
      'cohort_size': cohortSize,
      'is_suppressed': false,
      'dp_applied': true,
      'epsilon': epsilon,
      'average_sleep_hours': double.parse(privateSleep.toStringAsFixed(1)),
      'average_workload_hours': double.parse(privateWorkload.toStringAsFixed(1)),
      'check_in_completion_rate': double.parse(privateCheckInRate.toStringAsFixed(2)),
    };
  }
}
