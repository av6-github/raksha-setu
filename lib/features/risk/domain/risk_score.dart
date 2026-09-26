// lib/features/risk/domain/risk_score.dart
// Calibrated risk prediction domain model with SHAP explanations and clinical label rules

import 'package:flutter/material.dart';
import 'risk_explanation.dart';

enum RiskTier {
  green,
  yellow,
  orange,
  red;

  static RiskTier fromString(String tier) {
    switch (tier.toLowerCase()) {
      case 'yellow':
        return RiskTier.yellow;
      case 'orange':
        return RiskTier.orange;
      case 'red':
        return RiskTier.red;
      default:
        return RiskTier.green;
    }
  }

  static RiskTier fromProbability(double p) {
    if (p >= 0.75) return RiskTier.red;
    if (p >= 0.50) return RiskTier.orange;
    if (p >= 0.25) return RiskTier.yellow;
    return RiskTier.green;
  }

  String get dbValue => name;

  String get displayName {
    switch (this) {
      case RiskTier.green:
        return 'Routine Baseline';
      case RiskTier.yellow:
        return 'Mild Elevation';
      case RiskTier.orange:
        return 'Moderate Elevation';
      case RiskTier.red:
        return 'High Elevation';
    }
  }

  Color get color {
    switch (this) {
      case RiskTier.green:
        return Colors.green;
      case RiskTier.yellow:
        return Colors.amber.shade800;
      case RiskTier.orange:
        return Colors.orange.shade800;
      case RiskTier.red:
        return Colors.red.shade700;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case RiskTier.green:
        return Colors.green.shade50;
      case RiskTier.yellow:
        return Colors.amber.shade50;
      case RiskTier.orange:
        return Colors.orange.shade50;
      case RiskTier.red:
        return Colors.red.shade50;
    }
  }
}

class RiskScore {
  final String id;
  final String officerId;
  final DateTime scoreDate;
  final double riskProbability; // 0.0000 to 1.0000
  final RiskTier riskTier;
  final String modelVersion;
  final int predictionWindowDays; // 30 or 60
  final double confidenceIntervalLow;
  final double confidenceIntervalHigh;
  final List<RiskExplanation> explanations;

  const RiskScore({
    required this.id,
    required this.officerId,
    required this.scoreDate,
    required this.riskProbability,
    required this.riskTier,
    required this.modelVersion,
    this.predictionWindowDays = 60,
    required this.confidenceIntervalLow,
    required this.confidenceIntervalHigh,
    this.explanations = const [],
  });

  /// Evaluates clinical ground-truth label according to validated criteria:
  /// - PHQ-9 >= 10 (moderate depression)
  /// - GAD-7 >= 10 (moderate anxiety)
  /// - PCL-5 >= 33 (clinically significant PTSD threshold)
  /// - Counsellor-confirmed case
  static bool evaluateGroundTruthLabel({
    int? phq9Score,
    int? gad7Score,
    int? pcl5Score,
    bool counsellorConfirmed = false,
  }) {
    if (counsellorConfirmed) return true;
    if (phq9Score != null && phq9Score >= 10) return true;
    if (gad7Score != null && gad7Score >= 10) return true;
    if (pcl5Score != null && pcl5Score >= 33) return true;
    return false;
  }

  String get recommendedSupportAction {
    switch (riskTier) {
      case RiskTier.green:
        return 'Standard routine check-ins and access to preventive wellness modules.';
      case RiskTier.yellow:
        return 'Proactive self-care recommendation, sleep hygiene guidance, and informal buddy-pair contact.';
      case RiskTier.orange:
        return 'Recommended voluntary consultation with regimental welfare counsellor and workload rotation review.';
      case RiskTier.red:
        return 'High-priority confidential clinical support offer. Direct access to specialist counselling.';
    }
  }

  factory RiskScore.fromMap(Map<String, dynamic> map, {List<RiskExplanation> explanations = const []}) {
    final p = (map['risk_probability'] as num?)?.toDouble() ?? 0.05;
    final tierStr = map['risk_tier'] as String? ?? 'green';

    return RiskScore(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      scoreDate: DateTime.tryParse(map['score_date'] as String? ?? '') ?? DateTime.now(),
      riskProbability: p,
      riskTier: RiskTier.fromString(tierStr),
      modelVersion: map['model_version'] as String? ?? 'v1.4.2-calibrated',
      predictionWindowDays: (map['prediction_window_days'] as num?)?.toInt() ?? 60,
      confidenceIntervalLow: (map['confidence_interval_low'] as num?)?.toDouble() ?? (p * 0.8).clamp(0.0, 1.0),
      confidenceIntervalHigh: (map['confidence_interval_high'] as num?)?.toDouble() ?? (p * 1.2).clamp(0.0, 1.0),
      explanations: explanations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'score_date': scoreDate.toIso8601String(),
      'risk_probability': riskProbability,
      'risk_tier': riskTier.dbValue,
      'model_version': modelVersion,
      'prediction_window_days': predictionWindowDays,
      'confidence_interval_low': confidenceIntervalLow,
      'confidence_interval_high': confidenceIntervalHigh,
    };
  }
}
