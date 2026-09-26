// lib/features/risk/domain/risk_explanation.dart
// SHAP feature attributions and plain-language explanation templates

class RiskExplanation {
  final String id;
  final String riskScoreId;
  final String featureName;
  final double shapValue; // Local SHAP value (contribution to log-odds)
  final double? featureValue; // Observed feature value
  final String direction; // 'increases_risk', 'decreases_risk'
  final String plainLanguageExplanation;
  final int rankOrder;

  const RiskExplanation({
    required this.id,
    required this.riskScoreId,
    required this.featureName,
    required this.shapValue,
    this.featureValue,
    required this.direction,
    required this.plainLanguageExplanation,
    required this.rankOrder,
  });

  bool get isRiskIncreasing => direction == 'increases_risk' || shapValue > 0;

  factory RiskExplanation.fromMap(Map<String, dynamic> map) {
    return RiskExplanation(
      id: map['id'] as String,
      riskScoreId: map['risk_score_id'] as String,
      featureName: map['feature_name'] as String,
      shapValue: (map['shap_value'] as num?)?.toDouble() ?? 0.0,
      featureValue: (map['feature_value'] as num?)?.toDouble(),
      direction: map['direction'] as String? ?? 'increases_risk',
      plainLanguageExplanation: map['plain_language_explanation'] as String? ?? '',
      rankOrder: (map['rank_order'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'risk_score_id': riskScoreId,
      'feature_name': featureName,
      'shap_value': shapValue,
      'feature_value': featureValue,
      'direction': direction,
      'plain_language_explanation': plainLanguageExplanation,
      'rank_order': rankOrder,
    };
  }
}
