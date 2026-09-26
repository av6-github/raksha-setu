// test/unit/risk_model_test.dart
// Unit tests for Phase 6: Risk Prediction, Clinical Ground Truth Labels, SHAP Explanations, and Model Calibration

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/analytics/domain/deviation_event.dart';
import 'package:raksha_welfare/features/analytics/domain/personal_baseline.dart';
import 'package:raksha_welfare/features/hrms/domain/organisational_signal.dart';
import 'package:raksha_welfare/features/risk/data/risk_engine.dart';
import 'package:raksha_welfare/features/risk/data/risk_repository.dart';
import 'package:raksha_welfare/features/risk/domain/model_metrics.dart';
import 'package:raksha_welfare/features/risk/domain/risk_score.dart';
import 'package:raksha_welfare/features/risk/presentation/risk_view_model.dart';

void main() {
  group('Phase 6 — Risk Model and Explainability Tests', () {
    const testOfficerId = 'officer-test-risk-p6';

    test('Ground-truth label generator correctly triggers on validated clinical thresholds', () {
      // 1. Normal scores -> false
      expect(
        RiskScore.evaluateGroundTruthLabel(phq9Score: 4, gad7Score: 3, pcl5Score: 12),
        isFalse,
      );

      // 2. PHQ-9 >= 10 -> true (Moderate depression)
      expect(
        RiskScore.evaluateGroundTruthLabel(phq9Score: 10, gad7Score: 2),
        isTrue,
      );

      // 3. GAD-7 >= 10 -> true (Moderate anxiety)
      expect(
        RiskScore.evaluateGroundTruthLabel(phq9Score: 3, gad7Score: 11),
        isTrue,
      );

      // 4. PCL-5 >= 33 -> true (Provisional PTSD cutoff)
      expect(
        RiskScore.evaluateGroundTruthLabel(pcl5Score: 34),
        isTrue,
      );

      // 5. Counsellor-confirmed case -> true regardless of questionnaire score
      expect(
        RiskScore.evaluateGroundTruthLabel(phq9Score: 2, counsellorConfirmed: true),
        isTrue,
      );
    });

    test('RiskEngine computes calibrated probability and SHAP explanations matching inputs', () {
      final engine = RiskEngine();

      final baseline = PersonalBaseline(
        officerId: testOfficerId,
        version: 1,
        sampleCount: 30,
        isColdStart: false,
        sleepMean: 7.0,
        sleepStd: 1.0,
        dutyHoursMean: 8.5,
        dutyHoursStd: 1.5,
        checkInDistressMean: 1.0,
        checkInDistressStd: 0.8,
        calibratedAt: DateTime.now(),
      );

      // Deviations: sleep depressed by 2.2 sigma, duty elevated by 2.5 sigma
      final deviations = [
        DeviationEvent(
          id: 'dev-sleep',
          officerId: testOfficerId,
          feature: 'sleep_hours',
          baselineValue: 7.0,
          currentValue: 4.8,
          direction: 'depressed',
          magnitude: 2.2,
          durationDays: 6,
          confidence: 0.90,
          context: 'Sleep compression',
          detectedAt: DateTime.now(),
        ),
        DeviationEvent(
          id: 'dev-duty',
          officerId: testOfficerId,
          feature: 'workload_hours',
          baselineValue: 8.5,
          currentValue: 12.5,
          direction: 'elevated',
          magnitude: 2.5,
          durationDays: 6,
          confidence: 0.88,
          context: 'Workload surge',
          detectedAt: DateTime.now(),
        ),
      ];

      const signal = OrganisationalSignal(
        officerId: testOfficerId,
        leaveApplicationsCount: 4,
        operationalLeaveDenials: 2,
        currentConsecutiveDutyDays: 16,
        highHardshipMonths: 14,
        frictionIndex: 0.85,
        contributingFactors: ['2 operational leave denials', '16 consecutive duty days'],
      );

      final score = engine.evaluate(
        officerId: testOfficerId,
        baseline: baseline,
        deviations: deviations,
        organisationalSignal: signal,
      );

      expect(score.modelVersion, equals(RiskEngine.currentModelVersion));
      expect(score.riskProbability, greaterThan(0.50));
      expect(score.riskTier, anyOf(RiskTier.orange, RiskTier.red));
      expect(score.confidenceIntervalLow, lessThan(score.riskProbability));
      expect(score.confidenceIntervalHigh, greaterThan(score.riskProbability));

      // Verify SHAP explanations
      expect(score.explanations, isNotEmpty);
      final features = score.explanations.map((e) => e.featureName).toSet();
      expect(features, contains('sleep_hours_depression'));
      expect(features, contains('duty_workload_surge'));
      expect(features, contains('consecutive_duty_fatigue'));
      expect(features, contains('operational_leave_denials'));
      expect(features, contains('active_checkin_engagement'));

      // Check protective factor has negative SHAP
      final protective = score.explanations.firstWhere((e) => e.featureName == 'active_checkin_engagement');
      expect(protective.shapValue, lessThan(0.0));
      expect(protective.direction, equals('decreases_risk'));

      // Check rank ordering: rankOrder starts at 1 and increases sequentially
      for (int i = 0; i < score.explanations.length; i++) {
        expect(score.explanations[i].rankOrder, equals(i + 1));
      }
    });

    test('ModelMetrics maintains calibration benchmarks, bias parity, and zero drift', () {
      final metrics = ModelMetrics.verifiedProductionCandidate();

      expect(metrics.brierScore, lessThan(0.10)); // Good calibration
      expect(metrics.prAuc, greaterThan(0.80)); // High precision-recall AUC
      expect(metrics.highRiskRecall, greaterThan(0.90)); // > 90% recall on high risk

      // Subgroup parity audit
      expect(metrics.subgroupAudits, isNotEmpty);
      for (final audit in metrics.subgroupAudits) {
        expect(audit.isParityMaintained, isTrue);
        expect(audit.falsePositiveRate, lessThan(0.06));
      }

      // Drift monitoring
      expect(metrics.driftMetrics, isNotEmpty);
      for (final drift in metrics.driftMetrics) {
        expect(drift.psiScore, lessThan(0.10)); // PSI < 0.10: no drift
        expect(drift.driftDetected, isFalse);
      }
    });

    test('RiskViewModel loads risk score and triggers re-evaluation', () async {
      final repository = RiskRepository(client: null);
      final vm = RiskViewModel(repository: repository, officerId: testOfficerId);

      expect(vm.isLoading, isTrue);
      await vm.loadData();

      expect(vm.isLoading, isFalse);
      expect(vm.riskScore, isNotNull);
      expect(vm.metrics, isNotNull);
      expect(vm.errorMessage, isNull);

      final initialScoreId = vm.riskScore!.id;

      final baseline = PersonalBaseline(
        officerId: testOfficerId,
        version: 1,
        sampleCount: 14,
        isColdStart: true,
        sleepMean: 7.0,
        sleepStd: 1.0,
        dutyHoursMean: 8.0,
        dutyHoursStd: 1.0,
        checkInDistressMean: 1.0,
        checkInDistressStd: 0.5,
        calibratedAt: DateTime.now(),
      );

      const signal = OrganisationalSignal(
        officerId: testOfficerId,
        leaveApplicationsCount: 1,
        operationalLeaveDenials: 0,
        currentConsecutiveDutyDays: 3,
        highHardshipMonths: 0,
        frictionIndex: 0.1,
        contributingFactors: [],
      );

      await vm.reevaluate(
        baseline: baseline,
        deviations: [],
        signal: signal,
      );

      expect(vm.riskScore!.id, isNot(equals(initialScoreId)));
      expect(vm.riskScore!.riskTier, equals(RiskTier.green));
    });
  });
}
