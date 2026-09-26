// test/unit/analytics_baseline_test.dart
// Unit tests for Phase 5: Personal Baseline, Bayesian Shrinkage, CUSUM Deviation Detection, and k-Anonymity

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/analytics/data/baseline_repository.dart';
import 'package:raksha_welfare/features/analytics/data/cusum_detector.dart';
import 'package:raksha_welfare/features/analytics/domain/cohort_prior.dart';
import 'package:raksha_welfare/features/analytics/domain/personal_baseline.dart';
import 'package:raksha_welfare/features/analytics/domain/unit_aggregate_signal.dart';
import 'package:raksha_welfare/features/analytics/presentation/baseline_view_model.dart';

void main() {
  group('Phase 5 — Baseline and Analytics Engine Tests', () {
    const testOfficerId = 'officer-test-analytics';

    test('Cold-start Bayesian shrinkage pulls new-joiner baseline toward cohort prior', () {
      final prior = CohortPrior.generalDuty(); // sleepMean = 6.8, dutyMean = 9.5, pseudoCount = 14

      // Synthetic 7-day observations (cold start, n = 7 < 28)
      final sleepObs = [8.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0]; // empirical mean = 8.0
      final dutyObs = [12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0]; // empirical mean = 12.0
      final distressObs = [3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0];

      final baseline = PersonalBaseline.calibrate(
        officerId: testOfficerId,
        sleepObservations: sleepObs,
        dutyObservations: dutyObs,
        distressObservations: distressObs,
        cohortPrior: prior,
        version: 1,
      );

      expect(baseline.isColdStart, isTrue);
      expect(baseline.sampleCount, equals(7));

      // Shrunk mean formula: (7 * 8.0 + 14 * 6.8) / (7 + 14) = (56 + 95.2) / 21 = 151.2 / 21 = 7.2
      expect(baseline.sleepMean, closeTo(7.2, 0.05));
      expect(baseline.sleepMean, lessThan(8.0));
      expect(baseline.sleepMean, greaterThan(prior.sleepHoursMean));

      // Duty mean formula: (7 * 12.0 + 14 * 9.5) / 21 = (84 + 133) / 21 = 217 / 21 = 10.33
      expect(baseline.dutyHoursMean, closeTo(10.33, 0.05));
    });

    test('Mature baseline (n >= 28) relies predominantly on officer empirical history', () {
      final prior = CohortPrior.generalDuty(); // prior mean = 6.8, n0 = 14
      // 35 days of synthetic observations (n = 35 >= 28)
      final sleepObs = List.filled(35, 8.0);
      final dutyObs = List.filled(35, 7.5);
      final distressObs = List.filled(35, 1.0);

      final baseline = PersonalBaseline.calibrate(
        officerId: testOfficerId,
        sleepObservations: sleepObs,
        dutyObservations: dutyObs,
        distressObservations: distressObs,
        cohortPrior: prior,
        version: 2,
      );

      expect(baseline.isColdStart, isFalse);
      expect(baseline.sampleCount, equals(35));
      expect(baseline.version, equals(2));

      // Formula: (35 * 8.0 + 14 * 6.8) / (35 + 14) = (280 + 95.2) / 49 = 375.2 / 49 = 7.657
      // Empirical weight is 35/49 = 71.4%, dominating the prior
      expect(baseline.sleepMean, closeTo(7.66, 0.05));
    });

    test('CUSUM detector flags sustained upward shift in workload', () {
      const detector = CusumDetector(slackFactor: 0.5, decisionThreshold: 3.5);

      // Baseline: mean 8.0, std 1.0
      // Surge: 6 days of 12.0 hours (z = 4.0 each day)
      final series = [12.0, 12.0, 12.0, 12.0, 12.0, 12.0];

      final deviation = detector.evaluateSeries(
        officerId: testOfficerId,
        feature: 'workload_hours',
        baselineMean: 8.0,
        baselineStd: 1.0,
        recentObservations: series,
        operationalContext: 'High tempo deployment',
      );

      expect(deviation, isNotNull);
      expect(deviation!.feature, equals('workload_hours'));
      expect(deviation.direction, equals('elevated'));
      expect(deviation.magnitude, greaterThan(3.0));
      expect(deviation.durationDays, greaterThanOrEqualTo(5));
      expect(deviation.confidence, greaterThan(0.70));
      expect(deviation.context, contains('High tempo'));
    });

    test('CUSUM detector flags sustained downward compression in sleep', () {
      const detector = CusumDetector(slackFactor: 0.5, decisionThreshold: 3.5);

      // Baseline: mean 7.0, std 1.0
      // Sleep drop: 6 days of 4.0 hours (z = -3.0 each day)
      final series = [4.0, 4.0, 4.0, 4.0, 4.0, 4.0];

      final deviation = detector.evaluateSeries(
        officerId: testOfficerId,
        feature: 'sleep_hours',
        baselineMean: 7.0,
        baselineStd: 1.0,
        recentObservations: series,
        operationalContext: 'Night stand-to fatigue',
      );

      expect(deviation, isNotNull);
      expect(deviation!.feature, equals('sleep_hours'));
      expect(deviation.direction, equals('depressed'));
      expect(deviation.currentValue, equals(4.0));
      expect(deviation.durationDays, greaterThanOrEqualTo(5));
    });

    test('CUSUM detector does not trigger on normal non-systemic fluctuations', () {
      const detector = CusumDetector(slackFactor: 0.5, decisionThreshold: 3.5);

      // Normal variations close to baseline
      final series = [7.1, 6.9, 7.2, 6.8, 7.0, 7.1];

      final deviation = detector.evaluateSeries(
        officerId: testOfficerId,
        feature: 'sleep_hours',
        baselineMean: 7.0,
        baselineStd: 1.0,
        recentObservations: series,
        operationalContext: '',
      );

      expect(deviation, isNull);
    });

    test('Strict k-anonymity suppresses aggregate metrics when unit size < k', () {
      // Unit with 3 officers (k < 5)
      final smallUnit = UnitAggregateSignal.compute(
        unitId: 'unit-outpost-delta',
        unitName: 'Small Outpost Delta',
        totalOfficers: 3,
        avgFriction: 0.75,
        avgDuty: 14.0,
        avgSleep: 4.5,
        elevatedFatigueCount: 2,
        leaveDenialCount: 3,
        kThreshold: 5,
      );

      expect(smallUnit.isAnonymized, isFalse);
      expect(smallUnit.averageFrictionIndex, equals(0.0));
      expect(smallUnit.averageDutyHours, equals(0.0));
      expect(smallUnit.averageSleepHours, equals(0.0));
      expect(smallUnit.officersWithElevatedFatigue, equals(0));
      expect(smallUnit.systemicRecommendations.first, contains('Data suppressed to uphold strict k-anonymity'));
      expect(smallUnit.systemicRecommendations.first, contains('unit size 3 < threshold 5'));
    });

    test('k-anonymity permits aggregate analysis when unit size >= k', () {
      final normalUnit = UnitAggregateSignal.compute(
        unitId: 'unit-bravo',
        unitName: 'Bravo Company',
        totalOfficers: 25,
        avgFriction: 0.62,
        avgDuty: 11.2,
        avgSleep: 5.8,
        elevatedFatigueCount: 9,
        leaveDenialCount: 4,
        kThreshold: 5,
      );

      expect(normalUnit.isAnonymized, isTrue);
      expect(normalUnit.averageDutyHours, equals(11.2));
      expect(normalUnit.averageFrictionIndex, equals(0.62));
      expect(normalUnit.systemicRecommendations, isNotEmpty);
      expect(normalUnit.systemicRecommendations.any((r) => r.contains('rotational reinforcements')), isTrue);
    });

    test('BaselineViewModel loads data and triggers baseline recalibration', () async {
      final repository = BaselineRepository(client: null);
      final vm = BaselineViewModel(repository: repository, officerId: testOfficerId);

      expect(vm.isLoading, isTrue);
      await vm.loadData();

      expect(vm.isLoading, isFalse);
      expect(vm.baseline, isNotNull);
      expect(vm.deviations, isNotEmpty);
      expect(vm.unitAggregate, isNotNull);

      final initialVersion = vm.baseline!.version;

      // Recalibrate with 30 days of data
      await vm.recalibrate(
        sleepObs: List.filled(30, 7.5),
        dutyObs: List.filled(30, 8.0),
        distressObs: List.filled(30, 1.0),
        cohortPrior: CohortPrior.peaceStation(),
      );

      expect(vm.baseline!.version, equals(initialVersion + 1));
      expect(vm.baseline!.isColdStart, isFalse);
    });
  });
}
