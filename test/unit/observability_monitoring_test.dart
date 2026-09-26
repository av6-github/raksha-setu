// test/unit/observability_monitoring_test.dart
// Unit tests for Phase 18: Observability, ML Monitoring, PSI Drift, Calibration, Bias, and Sanitized Alerting

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/observability/data/observability_repository.dart';
import 'package:raksha_welfare/features/observability/domain/models/observability_models.dart';
import 'package:raksha_welfare/features/observability/domain/services/observability_services.dart';

void main() {
  group('Phase 18: DriftCalculationEngine & PSI Metrics', () {
    test('Calculates zero or near-zero PSI for identical frequency distributions', () {
      final baseline = [100.0, 200.0, 300.0, 200.0, 100.0];
      final current = [100.0, 200.0, 300.0, 200.0, 100.0];

      final psi = DriftCalculationEngine.calculatePsi(
        expectedFrequencies: baseline,
        actualFrequencies: current,
      );

      expect(psi, 0.0);
      expect(DriftCalculationEngine.classifyDrift(psi), DriftLevel.stable);
    });

    test('Detects moderate and severe drift as distribution diverges', () {
      final baseline = [100.0, 200.0, 300.0, 200.0, 100.0];
      // Shift toward higher bins
      final moderateShift = [80.0, 150.0, 280.0, 260.0, 180.0];
      final severeShift = [20.0, 50.0, 120.0, 400.0, 500.0];

      final psiMod = DriftCalculationEngine.calculatePsi(
        expectedFrequencies: baseline,
        actualFrequencies: moderateShift,
      );
      final psiSev = DriftCalculationEngine.calculatePsi(
        expectedFrequencies: baseline,
        actualFrequencies: severeShift,
      );

      expect(psiMod, greaterThan(0.05));
      expect(psiSev, greaterThan(0.25));
      expect(DriftCalculationEngine.classifyDrift(psiSev), DriftLevel.severeDrift);
    });

    test('Calculates Brier Score and enforces target calibration < 0.10', () {
      final probs = [0.10, 0.15, 0.85, 0.90, 0.05];
      final labels = [0, 0, 1, 1, 0];

      final brier = DriftCalculationEngine.calculateBrierScore(
        predictedProbabilities: probs,
        groundTruthLabels: labels,
      );

      // (0.01 + 0.0225 + 0.0225 + 0.01 + 0.0025) / 5 = 0.0675 / 5 = 0.0135
      expect(brier, lessThan(0.10));
    });

    test('Calculates four-fifths rule disparity metric for subgroup fairness', () {
      // 85% vs 90% compliance
      final disparity = DriftCalculationEngine.calculateDisparityMetric(
        minorityMetric: 0.85,
        majorityMetric: 0.90,
      );
      expect(disparity, closeTo(0.944, 0.01));
      expect(disparity >= 0.80, isTrue);

      // Disparity violation: 60% vs 90% = 0.667 (< 0.80)
      final nonCompliantDisparity = DriftCalculationEngine.calculateDisparityMetric(
        minorityMetric: 0.60,
        majorityMetric: 0.90,
      );
      expect(nonCompliantDisparity, closeTo(0.667, 0.01));
      expect(nonCompliantDisparity >= 0.80, isFalse);
    });
  });

  group('Phase 18: ObservabilitySanitizer & Zero Sensitive Content Guardrail', () {
    test('Permits clean operational telemetry without sensitive PII or clinical data', () {
      expect(
        () => ObservabilitySanitizer.assertNoSensitiveContent(
          'Sync queue depth normalized to 12 items after scheduled drain.',
        ),
        returnsNormally,
      );
    });

    test('Strictly blocks logs containing Aadhaar numbers', () {
      expect(
        () => ObservabilitySanitizer.assertNoSensitiveContent(
          'Telemetry record processed for officer with ID 4829 1049 8812',
        ),
        throwsA(isA<SensitiveDataLeakException>()),
      );
    });

    test('Strictly blocks logs containing personal phone numbers', () {
      expect(
        () => ObservabilitySanitizer.assertNoSensitiveContent(
          'Contact attempted via mobile +91 9845012345 during rest period',
        ),
        throwsA(isA<SensitiveDataLeakException>()),
      );
    });

    test('Strictly blocks logs containing raw military/force service numbers', () {
      expect(
        () => ObservabilitySanitizer.assertNoSensitiveContent(
          'Audit exception reported for CRPF-9481029 patrol leader',
        ),
        throwsA(isA<SensitiveDataLeakException>()),
      );
    });

    test('Strictly blocks logs containing clinical diagnoses or raw psychometric scores', () {
      expect(
        () => ObservabilitySanitizer.assertNoSensitiveContent(
          'Officer completed assessment with PHQ-9 score: 18 severe',
        ),
        throwsA(isA<SensitiveDataLeakException>()),
      );

      expect(
        () => ObservabilitySanitizer.assertNoSensitiveContent(
          'Escalation flagged for active suicidal ideation in unit',
        ),
        throwsA(isA<SensitiveDataLeakException>()),
      );
    });

    test('Sanitizes text by replacing sensitive tokens with redactions', () {
      final raw = 'Officer CRPF-1029384 with phone 9876543210 reported clinical depression symptoms.';
      final sanitized = ObservabilitySanitizer.sanitize(raw);

      expect(sanitized, contains('[REDACTED_FORCE_ID]'));
      expect(sanitized, contains('[REDACTED_PHONE]'));
      expect(sanitized, contains('[REDACTED_CLINICAL_DATA]'));
      expect(sanitized, isNot(contains('CRPF-1029384')));
      expect(sanitized, isNot(contains('9876543210')));
    });
  });

  group('Phase 18: ObservabilityRepository & Telemetry Contracts', () {
    late ObservabilityRepository repository;

    setUp(() {
      repository = ObservabilityRepository();
    });

    test('Returns valid system health metrics with high uptime and low error rate', () async {
      final sys = await repository.getSystemHealthMetrics();
      expect(sys.uptimePercent, greaterThanOrEqualTo(99.9));
      expect(sys.errorRatePercent, lessThan(0.1));
      expect(sys.apiLatencyMsP95, greaterThan(0));
    });

    test('Returns sync monitoring metrics with queue capacity boundary', () async {
      final sync = await repository.getSyncMonitoringMetrics();
      expect(sync.queueCapacity, 5000);
      expect(sync.pendingQueueDepth, lessThan(sync.queueCapacity));
      expect(sync.isQueueOverloaded, isFalse);
      expect(sync.syncSuccessRatePercent, greaterThan(99.0));
    });

    test('Crisis routing metrics strictly enforce 100% human routing and 0 AI violations', () async {
      final crisis = await repository.getCrisisRoutingMetrics();
      expect(crisis.zeroAiViolations, 0);
      expect(crisis.humanRoutedDispatches, crisis.totalCrisisDispatches);
      expect(crisis.isCompliant, isTrue);
    });

    test('Returns model drift metrics covering required features', () async {
      final drifts = await repository.getModelDriftMetrics();
      expect(drifts.length, greaterThanOrEqualTo(4));
      final sleepDrift = drifts.firstWhere((d) => d.featureName == 'rolling_sleep_avg_14d');
      expect(sleepDrift.driftLevel, DriftLevel.stable);
      expect(sleepDrift.psiScore, lessThan(0.10));
    });

    test('Returns 30-day model calibration satisfying Brier score < 0.10 and PR-AUC >= 0.80', () async {
      final cal = await repository.getLatestCalibrationMetric();
      expect(cal.brierScore, lessThan(0.10));
      expect(cal.prAuc, greaterThanOrEqualTo(0.80));
      expect(cal.highRiskRecall, greaterThanOrEqualTo(0.90));
      expect(cal.isCalibrated, isTrue);
    });

    test('Returns provider health metrics with all critical dependencies healthy', () async {
      final providers = await repository.getProviderHealthMetrics();
      expect(providers.any((p) => p.providerName.contains('Supabase')), isTrue);
      expect(providers.any((p) => p.providerName.contains('HSM')), isTrue);
      expect(providers.any((p) => p.providerName.contains('SMS')), isTrue);
      expect(providers.any((p) => p.providerName.contains('Tele-MANAS')), isTrue);
      expect(providers.every((p) => p.status == ProviderStatus.healthy), isTrue);
    });

    test('Dispatches sanitized alert and allows acknowledgment', () async {
      final alert = await repository.dispatchSanitizedAlert(
        severity: AlertSeverity.warning,
        source: 'test_runner',
        title: 'Cache Invalidation Latency Exceeded',
        details: 'Secondary Redis cache node took 420ms to propagate.',
      );

      expect(alert.isAcknowledged, isFalse);
      final alerts = await repository.getAlerts();
      expect(alerts.first.id, alert.id);

      await repository.acknowledgeAlert(alert.id);
      final updatedAlerts = await repository.getAlerts();
      expect(updatedAlerts.first.isAcknowledged, isTrue);
    });

    test('Rejects dispatching alert containing sensitive personal or clinical leakage', () async {
      expect(
        () => repository.dispatchSanitizedAlert(
          severity: AlertSeverity.critical,
          source: 'test_runner',
          title: 'Distress detected for officer with Aadhaar 9912 3412 8812',
          details: 'Emergency outreach recommended.',
        ),
        throwsA(isA<SensitiveDataLeakException>()),
      );
    });
  });
}
