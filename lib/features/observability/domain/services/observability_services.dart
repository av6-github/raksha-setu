// lib/features/observability/domain/services/observability_services.dart
// PSI calculation, Brier score calibration tracking, and zero-sensitive-leak log sanitizer

import 'dart:math';
import '../models/observability_models.dart';

class SensitiveDataLeakException implements Exception {
  final String message;
  SensitiveDataLeakException(this.message);

  @override
  String toString() => 'SensitiveDataLeakException: $message';
}

class ObservabilitySanitizer {
  // Regex patterns detecting sensitive PII and operational or clinical markers
  static final RegExp _aadhaarPattern = RegExp(r'\b\d{4}\s\d{4}\s\d{4}\b');
  static final RegExp _phonePattern = RegExp(r'\b(?:\+?91[\s-]?)?[6-9]\d{9}\b');
  static final RegExp _forceIdPattern = RegExp(
    r'\b(?:CRPF|BSF|CISF|ITBP|SSB|AR|NSG)[-\s]?\d{6,8}\b',
    caseSensitive: false,
  );
  static final RegExp _clinicalDiagnosticsPattern = RegExp(
    r'\b(PHQ-9 score:\s*\d+|GAD-7 score:\s*\d+|Item 9 self-harm|suicidal ideation|clinical depression|schizophrenia|bipolar disorder)\b',
    caseSensitive: false,
  );

  /// Asserts that a log, alert, or metric message contains strictly zero sensitive personal, clinical, or operational identifiers.
  static void assertNoSensitiveContent(String message) {
    if (_aadhaarPattern.hasMatch(message)) {
      throw SensitiveDataLeakException('Log entry contains Aadhaar number pattern.');
    }
    if (_phonePattern.hasMatch(message)) {
      throw SensitiveDataLeakException('Log entry contains personal phone number pattern.');
    }
    if (_forceIdPattern.hasMatch(message)) {
      throw SensitiveDataLeakException('Log entry contains raw military/force service number.');
    }
    if (_clinicalDiagnosticsPattern.hasMatch(message)) {
      throw SensitiveDataLeakException('Log entry contains raw clinical diagnostic or psychometric score leakage.');
    }
  }

  /// Sanitizes text by redacting sensitive tokens
  static String sanitize(String input) {
    var result = input;
    result = result.replaceAll(_aadhaarPattern, '[REDACTED_AADHAAR]');
    result = result.replaceAll(_phonePattern, '[REDACTED_PHONE]');
    result = result.replaceAll(_forceIdPattern, '[REDACTED_FORCE_ID]');
    result = result.replaceAll(_clinicalDiagnosticsPattern, '[REDACTED_CLINICAL_DATA]');
    return result;
  }
}

class DriftCalculationEngine {
  /// Calculates Population Stability Index (PSI) between baseline expected distribution and actual distribution
  /// PSI = sum((Actual% - Expected%) * ln(Actual% / Expected%))
  static double calculatePsi({
    required List<double> expectedFrequencies,
    required List<double> actualFrequencies,
  }) {
    if (expectedFrequencies.isEmpty || actualFrequencies.isEmpty) return 0.0;
    if (expectedFrequencies.length != actualFrequencies.length) {
      throw ArgumentError('Expected and actual frequency distributions must have the same bin count.');
    }

    final totalExpected = expectedFrequencies.reduce((a, b) => a + b);
    final totalActual = actualFrequencies.reduce((a, b) => a + b);

    if (totalExpected <= 0 || totalActual <= 0) return 0.0;

    double psi = 0.0;
    const double epsilon = 1e-4; // Smoothing factor to prevent ln(0) or division by zero

    for (int i = 0; i < expectedFrequencies.length; i++) {
      double expectedPct = expectedFrequencies[i] / totalExpected;
      double actualPct = actualFrequencies[i] / totalActual;

      if (expectedPct <= 0) expectedPct = epsilon;
      if (actualPct <= 0) actualPct = epsilon;

      final diff = actualPct - expectedPct;
      final logRatio = log(actualPct / expectedPct);
      psi += diff * logRatio;
    }

    return max(0.0, double.parse(psi.toStringAsFixed(4)));
  }

  /// Classifies drift severity according to regulatory ML benchmarks
  static DriftLevel classifyDrift(double psiScore) {
    if (psiScore < 0.10) {
      return DriftLevel.stable;
    } else if (psiScore <= 0.25) {
      return DriftLevel.moderateDrift;
    } else {
      return DriftLevel.severeDrift;
    }
  }

  /// Computes Brier Score: Mean Squared Error between predicted probabilities and binary ground truth labels
  /// Brier = (1/N) * sum((p_i - y_i)^2). Target for calibrated wellness models: < 0.10
  static double calculateBrierScore({
    required List<double> predictedProbabilities,
    required List<int> groundTruthLabels,
  }) {
    if (predictedProbabilities.isEmpty || groundTruthLabels.isEmpty) return 0.0;
    if (predictedProbabilities.length != groundTruthLabels.length) {
      throw ArgumentError('Predicted probabilities and ground truth labels must have identical lengths.');
    }

    double sumSqError = 0.0;
    for (int i = 0; i < predictedProbabilities.length; i++) {
      final p = predictedProbabilities[i].clamp(0.0, 1.0);
      final y = groundTruthLabels[i] > 0 ? 1.0 : 0.0;
      sumSqError += pow(p - y, 2);
    }

    final brier = sumSqError / predictedProbabilities.length;
    return double.parse(brier.toStringAsFixed(4));
  }

  /// Computes four-fifths (80%) rule disparity metric for subgroup fairness audits
  /// Disparity = minorityRate / majorityRate. Compliant if >= 0.80
  static double calculateDisparityMetric({
    required double minorityMetric,
    required double majorityMetric,
  }) {
    if (majorityMetric <= 0) return 1.0;
    final disparity = minorityMetric / majorityMetric;
    return double.parse(disparity.toStringAsFixed(3));
  }
}
