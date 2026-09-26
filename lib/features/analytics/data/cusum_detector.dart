// lib/features/analytics/data/cusum_detector.dart
// Algorithmic two-sided Cumulative Sum (CUSUM) change-point detector

import 'dart:math';
import '../domain/deviation_event.dart';

class CusumDetector {
  final double slackFactor; // k: reference value, typically 0.5 (half of the shift to detect in sigma units)
  final double decisionThreshold; // h: control limit, typically 3.0 to 4.5 sigma units

  const CusumDetector({
    this.slackFactor = 0.5,
    this.decisionThreshold = 3.5,
  });

  /// Evaluates a time series against a personal baseline using two-sided CUSUM.
  /// Returns a [DeviationEvent] if cumulative deviations breach the decision threshold [decisionThreshold].
  DeviationEvent? evaluateSeries({
    required String officerId,
    required String feature,
    required double baselineMean,
    required double baselineStd,
    required List<double> recentObservations,
    required String operationalContext,
  }) {
    if (recentObservations.isEmpty || baselineStd <= 0.001) return null;

    double sPos = 0.0;
    double sNeg = 0.0;
    int posStreak = 0;
    int negStreak = 0;

    for (final x in recentObservations) {
      // Standardized z-score
      final z = (x - baselineMean) / baselineStd;

      // Positive CUSUM (detect upward shift, e.g. duty hours or distress score surge)
      sPos = max(0.0, sPos + z - slackFactor);
      if (sPos > 0) {
        posStreak++;
      } else {
        posStreak = 0;
      }

      // Negative CUSUM (detect downward shift, e.g. sleep duration drop)
      sNeg = max(0.0, sNeg - z - slackFactor);
      if (sNeg > 0) {
        negStreak++;
      } else {
        negStreak = 0;
      }
    }

    final latestValue = recentObservations.last;
    final latestZ = (latestValue - baselineMean) / baselineStd;

    if (sPos >= decisionThreshold) {
      final confidence = (sPos / (decisionThreshold * 1.5)).clamp(0.70, 0.99);
      return DeviationEvent(
        id: 'cusum-pos-${DateTime.now().millisecondsSinceEpoch}',
        officerId: officerId,
        feature: feature,
        baselineValue: baselineMean,
        currentValue: latestValue,
        direction: 'elevated',
        magnitude: latestZ,
        durationDays: max(posStreak, 1),
        confidence: confidence,
        context: operationalContext.isNotEmpty
            ? operationalContext
            : 'Sustained elevation detected by CUSUM (statistic ${sPos.toStringAsFixed(2)} >= threshold $decisionThreshold)',
        detectedAt: DateTime.now(),
      );
    }

    if (sNeg >= decisionThreshold) {
      final confidence = (sNeg / (decisionThreshold * 1.5)).clamp(0.70, 0.99);
      return DeviationEvent(
        id: 'cusum-neg-${DateTime.now().millisecondsSinceEpoch}',
        officerId: officerId,
        feature: feature,
        baselineValue: baselineMean,
        currentValue: latestValue,
        direction: 'depressed',
        magnitude: latestZ.abs(),
        durationDays: max(negStreak, 1),
        confidence: confidence,
        context: operationalContext.isNotEmpty
            ? operationalContext
            : 'Sustained reduction detected by CUSUM (statistic ${sNeg.toStringAsFixed(2)} >= threshold $decisionThreshold)',
        detectedAt: DateTime.now(),
      );
    }

    return null;
  }
}
