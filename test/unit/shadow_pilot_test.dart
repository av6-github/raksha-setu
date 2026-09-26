// test/unit/shadow_pilot_test.dart
// Unit tests for Phase 19: Shadow Pilot, Synthetic Validation, Silent Scoring, Clinician Concordance, Error Analysis, and Go/No-Go Gate

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/shadow_pilot/data/shadow_pilot_repository.dart';
import 'package:raksha_welfare/features/shadow_pilot/domain/models/shadow_pilot_models.dart';
import 'package:raksha_welfare/features/shadow_pilot/domain/services/shadow_pilot_engine.dart';
import 'package:raksha_welfare/features/trust/domain/governance_models.dart';

void main() {
  group('Phase 19: ShadowPilotEngine Concordance & Quarantine Tests', () {
    test('Correctly categorizes concordance between model tier and clinician tier', () {
      expect(
        ShadowPilotEngine.categorizeConcordance('green', 'green'),
        ConcordanceStatus.matched,
      );
      expect(
        ShadowPilotEngine.categorizeConcordance('orange', 'yellow'),
        ConcordanceStatus.concordantTier,
      );
      expect(
        ShadowPilotEngine.categorizeConcordance('yellow', 'green'),
        ConcordanceStatus.concordantTier,
      );
      expect(
        ShadowPilotEngine.categorizeConcordance('red', 'green'),
        ConcordanceStatus.divergent,
      );
      expect(
        ShadowPilotEngine.categorizeConcordance('red', 'yellow'),
        ConcordanceStatus.divergent,
      );
    });

    test('Computes overall concordance rate and satisfies >= 90% benchmark', () {
      final now = DateTime.now();
      final predictions = [
        SilentPredictionRecord(
          predictionId: 'p1',
          officerToken: 'TK-001',
          timestamp: now,
          predictedRiskScore: 0.15,
          predictedTier: 'green',
          clinicianGroundTruthTier: 'green',
          concordance: ConcordanceStatus.matched,
          isShadowMode: true,
          acrQuarantined: true,
        ),
        SilentPredictionRecord(
          predictionId: 'p2',
          officerToken: 'TK-002',
          timestamp: now,
          predictedRiskScore: 0.45,
          predictedTier: 'yellow',
          clinicianGroundTruthTier: 'yellow',
          concordance: ConcordanceStatus.matched,
          isShadowMode: true,
          acrQuarantined: true,
        ),
        SilentPredictionRecord(
          predictionId: 'p3',
          officerToken: 'TK-003',
          timestamp: now,
          predictedRiskScore: 0.65,
          predictedTier: 'orange',
          clinicianGroundTruthTier: 'yellow',
          concordance: ConcordanceStatus.concordantTier,
          isShadowMode: true,
          acrQuarantined: true,
        ),
        SilentPredictionRecord(
          predictionId: 'p4',
          officerToken: 'TK-004',
          timestamp: now,
          predictedRiskScore: 0.90,
          predictedTier: 'red',
          clinicianGroundTruthTier: 'red',
          concordance: ConcordanceStatus.matched,
          isShadowMode: true,
          acrQuarantined: true,
        ),
      ];

      final report = ShadowPilotEngine.evaluateCounsellorComparison(
        predictions: predictions,
        periodStart: now.subtract(const Duration(days: 30)),
        periodEnd: now,
      );

      expect(report.totalAuditedCases, 4);
      expect(report.exactMatchedCases, 3);
      expect(report.adjacentTierCases, 1);
      expect(report.divergentCases, 0);
      expect(report.concordanceRate, 1.0); // 100% >= 90%
      expect(report.satisfiesConcordanceBenchmark, isTrue);
    });

    test('Strictly enforces ACR quarantine throwing StateError if leaked outside shadow mode', () {
      final unquarantinedRecord = SilentPredictionRecord(
        predictionId: 'p-leak',
        officerToken: 'TK-LEAK',
        timestamp: DateTime.now(),
        predictedRiskScore: 0.75,
        predictedTier: 'orange',
        clinicianGroundTruthTier: 'orange',
        concordance: ConcordanceStatus.matched,
        isShadowMode: true,
        acrQuarantined: false, // Breach!
      );

      expect(
        () => ShadowPilotEngine.assertAcrQuarantine(unquarantinedRecord),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Phase 19: Go/No-Go Gate Decision Logic Tests', () {
    test('Issues GO_FOR_LIVE_PILOT when all 6 gatekeeper benchmarks are satisfied', () {
      final now = DateTime.now();
      final comparison = CounsellorComparisonReport(
        totalAuditedCases: 100,
        exactMatchedCases: 85,
        adjacentTierCases: 10,
        divergentCases: 5,
        concordanceRate: 0.95, // >= 90%
        auditPeriodStart: now.subtract(const Duration(days: 30)),
        auditPeriodEnd: now,
      );

      const errorAnalysis = ErrorAnalysisReport(
        falsePositiveCount: 4,
        falsePositiveRate: 0.04, // <= 8%
        falsePositivePrimaryReason: 'Post-patrol fatigue',
        falseNegativeCount: 1,
        falseNegativeRate: 0.01,
        criticalMissesCount: 0, // Zero critical misses
        mitigationStrategy: 'Item 9 human override',
      );

      const trustSurvey = TrustSurveyReport(
        surveyRespondents: 1000,
        overallTrustScore: 88.0, // >= 75
        perceivedStigmaRiskPercentage: 14.0, // <= 20%
        checkInWillingnessRate: 85.0,
        confidenceInWelfareFirewall: 92.0, // >= 80%
        topTroopFeedback: 'Troops trust firewall',
      );

      final review = ShadowPilotEngine.evaluateGoNoGoGate(
        modelVersion: 'v1.4.2-lightgbm',
        comparison: comparison,
        errorAnalysis: errorAnalysis,
        brierScore: 0.082, // < 0.10
        minDisparity: 0.885, // >= 0.80
        zeroAiViolations: 0, // Zero AI
        trustSurvey: trustSurvey,
        authorizedBy: 'Joint Oversight Committee',
      );

      expect(review.decision, GoNoGoDecision.goForLivePilot);
      expect(review.isApprovedForLivePilot, isTrue);
      expect(review.checklist.every((c) => c.isSatisfied), isTrue);
    });

    test('Issues NO_GO when critical misses occur or concordance fails benchmark', () {
      final now = DateTime.now();
      final failingComparison = CounsellorComparisonReport(
        totalAuditedCases: 100,
        exactMatchedCases: 60,
        adjacentTierCases: 15,
        divergentCases: 25,
        concordanceRate: 0.75, // < 90% (Fails)
        auditPeriodStart: now.subtract(const Duration(days: 30)),
        auditPeriodEnd: now,
      );

      const failingErrorAnalysis = ErrorAnalysisReport(
        falsePositiveCount: 15,
        falsePositiveRate: 0.15, // > 8% (Fails)
        falsePositivePrimaryReason: 'High noise',
        falseNegativeCount: 5,
        falseNegativeRate: 0.05,
        criticalMissesCount: 2, // Fails! Critical misses > 0
        mitigationStrategy: 'None',
      );

      const trustSurvey = TrustSurveyReport(
        surveyRespondents: 500,
        overallTrustScore: 65.0, // < 75 (Fails)
        perceivedStigmaRiskPercentage: 35.0, // > 20% (Fails)
        checkInWillingnessRate: 50.0,
        confidenceInWelfareFirewall: 60.0,
        topTroopFeedback: 'Concerns about ACR leakage',
      );

      final review = ShadowPilotEngine.evaluateGoNoGoGate(
        modelVersion: 'v1.4.2-lightgbm',
        comparison: failingComparison,
        errorAnalysis: failingErrorAnalysis,
        brierScore: 0.145, // > 0.10 (Fails)
        minDisparity: 0.650, // < 0.80 (Fails)
        zeroAiViolations: 1, // Fails!
        trustSurvey: trustSurvey,
        authorizedBy: 'Joint Oversight Committee',
      );

      expect(review.decision, GoNoGoDecision.noGo);
      expect(review.isApprovedForLivePilot, isFalse);
    });
  });

  group('Phase 19: ShadowPilotRepository Telemetry & Feedback', () {
    late ShadowPilotRepository repository;

    setUp(() {
      repository = ShadowPilotRepository();
    });

    test('Returns validated synthetic cohort report with high fidelity', () async {
      final report = await repository.getSyntheticValidationReport();
      expect(report.totalSyntheticRecords, 5000);
      expect(report.syntheticFidelityScore, greaterThanOrEqualTo(0.90));
      expect(report.acuteFatigueEdgeCasesPassed, isTrue);
      expect(report.chronicDepressionEdgeCasesPassed, isTrue);
      expect(report.zeroCheckInBoundaryPassed, isTrue);
      expect(report.isPassed, isTrue);
    });

    test('Silent predictions are strictly shadow-mode and ACR-quarantined', () async {
      final predictions = await repository.getSilentPredictions();
      expect(predictions.isNotEmpty, isTrue);
      for (final p in predictions) {
        expect(p.isShadowMode, isTrue);
        expect(p.acrQuarantined, isTrue);
        expect(p.officerToken.startsWith('TK-'), isTrue);
      }
    });

    test('Error analysis validates zero critical misses and safe deployment bounds', () async {
      final err = await repository.getErrorAnalysis();
      expect(err.criticalMissesCount, 0);
      expect(err.falsePositiveRate, lessThanOrEqualTo(0.08));
      expect(err.isSafeForDeployment, isTrue);
    });

    test('Trust survey satisfies troop adoption threshold', () async {
      final survey = await repository.getTrustSurvey();
      expect(survey.overallTrustScore, greaterThanOrEqualTo(75.0));
      expect(survey.perceivedStigmaRiskPercentage, lessThanOrEqualTo(20.0));
      expect(survey.confidenceInWelfareFirewall, greaterThanOrEqualTo(80.0));
      expect(survey.satisfiesTrustThreshold, isTrue);
    });

    test('Returns baseline operational KPIs for pre-live comparison', () async {
      final kpi = await repository.getKpiBaseline();
      expect(kpi.avgLeaveFrictionIndex, greaterThan(0));
      expect(kpi.checkInWeeklyCompletionRate, greaterThan(70.0));
      expect(kpi.confirmedDataLeakIncidents, 0);
    });

    test('Successfully submits and retrieves troop co-design feedback', () async {
      final initialFeedbacks = await repository.getCoDesignFeedbacks();
      final initialCount = initialFeedbacks.length;

      final feedback = CoDesignFeedback(
        id: 'test-fb-99',
        officerRankDisplay: 'Naib Subedar, ITBP',
        unit: 'Laddakh Sector HQ',
        topic: 'Thermal Battery Calibration',
        feedbackText: 'Cold weather battery draining at sub-zero posts requires cached offline session persistence.',
        actionStatus: 'under_review',
        submittedAt: DateTime.now(),
      );

      await repository.submitCoDesignFeedback(feedback);
      final updatedFeedbacks = await repository.getCoDesignFeedbacks();
      expect(updatedFeedbacks.length, initialCount + 1);
      expect(updatedFeedbacks.first.id, 'test-fb-99');
    });
  });
}
