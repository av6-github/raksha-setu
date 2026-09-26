// lib/features/shadow_pilot/domain/models/shadow_pilot_models.dart
// Domain models for Phase 19: Shadow Pilot, Synthetic Validation, Silent Scoring, Clinician Concordance, Error Analysis, and Go/No-Go Gate

enum ConcordanceStatus { matched, concordantTier, divergent }
enum GoNoGoDecision { goForLivePilot, conditionalGo, noGo }

class SyntheticValidationReport {
  final String datasetId;
  final int totalSyntheticRecords;
  final int edgeCaseCount;
  final double syntheticFidelityScore; // e.g. 0.945 (94.5% distribution match)
  final bool acuteFatigueEdgeCasesPassed;
  final bool chronicDepressionEdgeCasesPassed;
  final bool zeroCheckInBoundaryPassed;
  final DateTime validatedAt;

  const SyntheticValidationReport({
    required this.datasetId,
    required this.totalSyntheticRecords,
    required this.edgeCaseCount,
    required this.syntheticFidelityScore,
    required this.acuteFatigueEdgeCasesPassed,
    required this.chronicDepressionEdgeCasesPassed,
    required this.zeroCheckInBoundaryPassed,
    required this.validatedAt,
  });

  bool get isPassed =>
      acuteFatigueEdgeCasesPassed &&
      chronicDepressionEdgeCasesPassed &&
      zeroCheckInBoundaryPassed &&
      syntheticFidelityScore >= 0.90;
}

class SilentPredictionRecord {
  final String predictionId;
  final String officerToken; // Pseudonymised token only
  final DateTime timestamp;
  final double predictedRiskScore;
  final String predictedTier; // 'green', 'yellow', 'orange', 'red'
  final String clinicianGroundTruthTier;
  final ConcordanceStatus concordance;
  final bool isShadowMode; // Strictly true
  final bool acrQuarantined; // Strictly true: zero ACR or administrative linkage
  final String? clinicianAuditNotes;

  const SilentPredictionRecord({
    required this.predictionId,
    required this.officerToken,
    required this.timestamp,
    required this.predictedRiskScore,
    required this.predictedTier,
    required this.clinicianGroundTruthTier,
    required this.concordance,
    this.isShadowMode = true,
    this.acrQuarantined = true,
    this.clinicianAuditNotes,
  });
}

class CounsellorComparisonReport {
  final int totalAuditedCases;
  final int exactMatchedCases;
  final int adjacentTierCases;
  final int divergentCases;
  final double concordanceRate; // (exact + adjacent) / total. Benchmark: >= 90%
  final DateTime auditPeriodStart;
  final DateTime auditPeriodEnd;

  const CounsellorComparisonReport({
    required this.totalAuditedCases,
    required this.exactMatchedCases,
    required this.adjacentTierCases,
    required this.divergentCases,
    required this.concordanceRate,
    required this.auditPeriodStart,
    required this.auditPeriodEnd,
  });

  bool get satisfiesConcordanceBenchmark => concordanceRate >= 0.90;
}

class ErrorAnalysisReport {
  final int falsePositiveCount;
  final double falsePositiveRate;
  final String falsePositivePrimaryReason;
  final int falseNegativeCount;
  final double falseNegativeRate;
  final int criticalMissesCount; // Strictly 0 (no missed imminent suicidal crisis)
  final String mitigationStrategy;

  const ErrorAnalysisReport({
    required this.falsePositiveCount,
    required this.falsePositiveRate,
    required this.falsePositivePrimaryReason,
    required this.falseNegativeCount,
    required this.falseNegativeRate,
    required this.criticalMissesCount,
    required this.mitigationStrategy,
  });

  bool get isSafeForDeployment => criticalMissesCount == 0 && falsePositiveRate <= 0.08;
}

class TrustSurveyReport {
  final int surveyRespondents;
  final double overallTrustScore; // 0 - 100, Target: >= 75
  final double perceivedStigmaRiskPercentage; // Low is better, Target: <= 20%
  final double checkInWillingnessRate; // Target: >= 70%
  final double confidenceInWelfareFirewall; // Target: >= 80%
  final String topTroopFeedback;

  const TrustSurveyReport({
    required this.surveyRespondents,
    required this.overallTrustScore,
    required this.perceivedStigmaRiskPercentage,
    required this.checkInWillingnessRate,
    required this.confidenceInWelfareFirewall,
    required this.topTroopFeedback,
  });

  bool get satisfiesTrustThreshold =>
      overallTrustScore >= 75.0 &&
      perceivedStigmaRiskPercentage <= 20.0 &&
      confidenceInWelfareFirewall >= 80.0;
}

class KpiBaselineMetrics {
  final double avgLeaveFrictionIndex; // e.g. 0.28
  final double checkInWeeklyCompletionRate; // e.g. 82.4%
  final int medianCounsellingConnectMinutes; // e.g. 18 min
  final int avgCrisisBridgeSeconds; // e.g. 14 sec
  final int confirmedDataLeakIncidents; // Strictly 0
  final DateTime establishedDate;

  const KpiBaselineMetrics({
    required this.avgLeaveFrictionIndex,
    required this.checkInWeeklyCompletionRate,
    required this.medianCounsellingConnectMinutes,
    required this.avgCrisisBridgeSeconds,
    required this.confirmedDataLeakIncidents,
    required this.establishedDate,
  });
}

class GateCheckItem {
  final String criteria;
  final String target;
  final String actual;
  final bool isSatisfied;

  const GateCheckItem({
    required this.criteria,
    required this.target,
    required this.actual,
    required this.isSatisfied,
  });
}

class GoNoGoGateReview {
  final String modelVersion;
  final GoNoGoDecision decision;
  final List<GateCheckItem> checklist;
  final String authorizedBy;
  final DateTime evaluatedAt;
  final String committeeRemarks;

  const GoNoGoGateReview({
    required this.modelVersion,
    required this.decision,
    required this.checklist,
    required this.authorizedBy,
    required this.evaluatedAt,
    required this.committeeRemarks,
  });

  bool get isApprovedForLivePilot =>
      decision == GoNoGoDecision.goForLivePilot && checklist.every((item) => item.isSatisfied);
}
