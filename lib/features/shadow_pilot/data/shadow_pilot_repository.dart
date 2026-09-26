// lib/features/shadow_pilot/data/shadow_pilot_repository.dart
// Repository for Phase 19 Shadow Pilot telemetry, silent scoring audit logs, error analysis, and Go/No-Go gate

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/shadow_pilot_models.dart';
import '../domain/services/shadow_pilot_engine.dart';
import '../../trust/domain/governance_models.dart';

abstract class IShadowPilotRepository {
  Future<SyntheticValidationReport> getSyntheticValidationReport();
  Future<List<SilentPredictionRecord>> getSilentPredictions();
  Future<CounsellorComparisonReport> getCounsellorComparison();
  Future<ErrorAnalysisReport> getErrorAnalysis();
  Future<TrustSurveyReport> getTrustSurvey();
  Future<KpiBaselineMetrics> getKpiBaseline();
  Future<GoNoGoGateReview> getGoNoGoGate();
  Future<List<CoDesignFeedback>> getCoDesignFeedbacks();
  Future<void> submitCoDesignFeedback(CoDesignFeedback feedback);
}

class ShadowPilotRepository implements IShadowPilotRepository {
  final SupabaseClient? supabase;

  final List<CoDesignFeedback> _coDesignFeedbacks = [
    CoDesignFeedback(
      id: 'fb-001',
      officerRankDisplay: 'Sub-Inspector, 42 Bn BSF',
      unit: 'Sector HQ Kupwara',
      topic: 'SMS Fallback Token Verification',
      feedbackText: 'SMS check-in format tested at forward outpost. 17-character token was easy to copy and submit via standard keypad phone.',
      actionStatus: 'implemented',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CoDesignFeedback(
      id: 'fb-002',
      officerRankDisplay: 'Head Constable, 114 Bn CRPF',
      unit: 'Anantnag Detachment',
      topic: 'Welfare-HR Firewall Clarity',
      feedbackText: 'Troops were reassured after reading the physical banner in the mess explaining that wellness tiers have zero link to ACR or promotion.',
      actionStatus: 'implemented',
      submittedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    CoDesignFeedback(
      id: 'fb-003',
      officerRankDisplay: 'Havildar, Assam Rifles',
      unit: '26 Sector AR, Moreh',
      topic: 'Tele-MANAS IVR Local Dialect',
      feedbackText: 'Suggest adding Meitei and Nagamese audio prompts to the toll-free 14416 interactive voice bridge for Northeast battalions.',
      actionStatus: 'under_review',
      submittedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  final List<SilentPredictionRecord> _silentPredictions = [
    SilentPredictionRecord(
      predictionId: 'pred-8491',
      officerToken: 'TK-8492-4102-9912',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      predictedRiskScore: 0.18,
      predictedTier: 'green',
      clinicianGroundTruthTier: 'green',
      concordance: ConcordanceStatus.matched,
      isShadowMode: true,
      acrQuarantined: true,
      clinicianAuditNotes: 'Confirmed healthy routine. Sleep 7.2h, baseline normal.',
    ),
    SilentPredictionRecord(
      predictionId: 'pred-8492',
      officerToken: 'TK-3921-9941-2041',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      predictedRiskScore: 0.54,
      predictedTier: 'yellow',
      clinicianGroundTruthTier: 'yellow',
      concordance: ConcordanceStatus.matched,
      isShadowMode: true,
      acrQuarantined: true,
      clinicianAuditNotes: 'Mild fatigue due to double night duty watch. Recommended shift rotation.',
    ),
    SilentPredictionRecord(
      predictionId: 'pred-8493',
      officerToken: 'TK-7741-2019-3382',
      timestamp: DateTime.now().subtract(const Duration(hours: 9)),
      predictedRiskScore: 0.72,
      predictedTier: 'orange',
      clinicianGroundTruthTier: 'orange',
      concordance: ConcordanceStatus.matched,
      isShadowMode: true,
      acrQuarantined: true,
      clinicianAuditNotes: 'Sustained sleep compression & leave friction. Outreach initiated by Welfare Officer.',
    ),
    SilentPredictionRecord(
      predictionId: 'pred-8494',
      officerToken: 'TK-1192-5502-8841',
      timestamp: DateTime.now().subtract(const Duration(hours: 14)),
      predictedRiskScore: 0.68,
      predictedTier: 'orange',
      clinicianGroundTruthTier: 'yellow',
      concordance: ConcordanceStatus.concordantTier,
      isShadowMode: true,
      acrQuarantined: true,
      clinicianAuditNotes: 'Model predicted Orange due to 14-day leave denial streak; clinician classified as Yellow due to strong buddy support.',
    ),
    SilentPredictionRecord(
      predictionId: 'pred-8495',
      officerToken: 'TK-6623-1102-7749',
      timestamp: DateTime.now().subtract(const Duration(hours: 20)),
      predictedRiskScore: 0.88,
      predictedTier: 'red',
      clinicianGroundTruthTier: 'red',
      concordance: ConcordanceStatus.matched,
      isShadowMode: true,
      acrQuarantined: true,
      clinicianAuditNotes: 'Severe operational strain. Clinical case opened under Dr. Major Sharma.',
    ),
  ];

  ShadowPilotRepository({this.supabase});

  @override
  Future<SyntheticValidationReport> getSyntheticValidationReport() async {
    return SyntheticValidationReport(
      datasetId: 'SYNTH-COHORT-2026-V3',
      totalSyntheticRecords: 5000,
      edgeCaseCount: 420,
      syntheticFidelityScore: 0.945,
      acuteFatigueEdgeCasesPassed: true,
      chronicDepressionEdgeCasesPassed: true,
      zeroCheckInBoundaryPassed: true,
      validatedAt: DateTime.now().subtract(const Duration(days: 5)),
    );
  }

  @override
  Future<List<SilentPredictionRecord>> getSilentPredictions() async {
    return List.unmodifiable(_silentPredictions);
  }

  @override
  Future<CounsellorComparisonReport> getCounsellorComparison() async {
    final now = DateTime.now();
    return ShadowPilotEngine.evaluateCounsellorComparison(
      predictions: _silentPredictions,
      periodStart: now.subtract(const Duration(days: 30)),
      periodEnd: now,
    );
  }

  @override
  Future<ErrorAnalysisReport> getErrorAnalysis() async {
    return const ErrorAnalysisReport(
      falsePositiveCount: 18,
      falsePositiveRate: 0.036, // 3.6% (Target <= 8%)
      falsePositivePrimaryReason: 'Acute physical exhaustion after 36h counter-insurgency sweep misclassified as depression.',
      falseNegativeCount: 8,
      falseNegativeRate: 0.016, // 1.6%
      criticalMissesCount: 0, // Zero missed suicidal crisis
      mitigationStrategy: 'Item 9 immediate human intercept acts as mandatory hard fail-safe overriding model weights.',
    );
  }

  @override
  Future<TrustSurveyReport> getTrustSurvey() async {
    return const TrustSurveyReport(
      surveyRespondents: 1250,
      overallTrustScore: 88.4, // Benchmark: >= 75
      perceivedStigmaRiskPercentage: 12.1, // Benchmark: <= 20%
      checkInWillingnessRate: 84.6, // Benchmark: >= 70%
      confidenceInWelfareFirewall: 92.5, // Benchmark: >= 80%
      topTroopFeedback: 'Guaranteed anonymity and lack of ACR visibility are the most cited drivers of adoption.',
    );
  }

  @override
  Future<KpiBaselineMetrics> getKpiBaseline() async {
    return KpiBaselineMetrics(
      avgLeaveFrictionIndex: 0.28,
      checkInWeeklyCompletionRate: 82.4,
      medianCounsellingConnectMinutes: 18,
      avgCrisisBridgeSeconds: 14,
      confirmedDataLeakIncidents: 0,
      establishedDate: DateTime.now().subtract(const Duration(days: 7)),
    );
  }

  @override
  Future<GoNoGoGateReview> getGoNoGoGate() async {
    final comparison = await getCounsellorComparison();
    final errorAnalysis = await getErrorAnalysis();
    final trustSurvey = await getTrustSurvey();

    return ShadowPilotEngine.evaluateGoNoGoGate(
      modelVersion: 'v1.4.2-lightgbm',
      comparison: comparison,
      errorAnalysis: errorAnalysis,
      brierScore: 0.082,
      minDisparity: 0.885, // Posting Hardship disparity
      zeroAiViolations: 0,
      trustSurvey: trustSurvey,
      authorizedBy: 'Joint Oversight Committee (DG Health & Defence Ethics Ombudsman)',
    );
  }

  @override
  Future<List<CoDesignFeedback>> getCoDesignFeedbacks() async {
    return List.unmodifiable(_coDesignFeedbacks);
  }

  @override
  Future<void> submitCoDesignFeedback(CoDesignFeedback feedback) async {
    _coDesignFeedbacks.insert(0, feedback);
  }
}
