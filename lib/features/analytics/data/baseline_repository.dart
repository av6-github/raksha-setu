// lib/features/analytics/data/baseline_repository.dart
// Repository for personal baseline calibration, CUSUM deviation monitoring, and aggregate insights

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../domain/cohort_prior.dart';
import '../domain/deviation_event.dart';
import '../domain/personal_baseline.dart';
import '../domain/unit_aggregate_signal.dart';
import 'cusum_detector.dart';

abstract class IBaselineRepository {
  Future<PersonalBaseline> getPersonalBaseline(String officerId);
  Future<List<DeviationEvent>> getDeviationEvents(String officerId, PersonalBaseline baseline);
  Future<UnitAggregateSignal> getUnitAggregate({
    required String unitId,
    required String unitName,
    int? officerCountOverride,
  });
  Future<PersonalBaseline> recalibrateBaseline({
    required String officerId,
    required List<double> sleepObs,
    required List<double> dutyObs,
    required List<double> distressObs,
    required CohortPrior cohortPrior,
  });
}

class BaselineRepository implements IBaselineRepository {
  final sp.SupabaseClient? client;
  final CusumDetector detector;

  // In-memory cache / mock storage for prototype
  final Map<String, PersonalBaseline> _cachedBaselines = {};

  BaselineRepository({
    this.client,
    CusumDetector? detector,
  }) : detector = detector ?? const CusumDetector();

  @override
  Future<PersonalBaseline> getPersonalBaseline(String officerId) async {
    if (_cachedBaselines.containsKey(officerId)) {
      return _cachedBaselines[officerId]!;
    }

    if (client != null) {
      try {
        final res = await client!
            .from('personal_baselines')
            .select()
            .eq('officer_id', officerId)
            .maybeSingle();

        if (res != null) {
          final baseline = PersonalBaseline.fromMap(res);
          _cachedBaselines[officerId] = baseline;
          return baseline;
        }
      } catch (e) {
        AppLogger.warning('Failed to load personal baseline from remote database; generating fallback', error: e);
      }
    }

    // Fallback: calibrate with initial 14-day pseudo observations
    final baseline = PersonalBaseline.calibrate(
      officerId: officerId,
      sleepObservations: [6.5, 7.0, 6.8, 7.2, 6.4, 6.9, 7.1],
      dutyObservations: [9.0, 9.5, 10.0, 8.5, 9.0, 9.5, 9.0],
      distressObservations: [1.0, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0],
      cohortPrior: CohortPrior.generalDuty(),
      version: 1,
    );

    _cachedBaselines[officerId] = baseline;
    return baseline;
  }

  @override
  Future<List<DeviationEvent>> getDeviationEvents(String officerId, PersonalBaseline baseline) async {
    final deviations = <DeviationEvent>[];

    // 1. Workload time-series: recent 7 days simulating heightened duty hours post operational alert
    final recentDutyObs = [10.0, 11.5, 12.0, 13.0, 12.5, 13.5, 14.0];
    final dutyDeviation = detector.evaluateSeries(
      officerId: officerId,
      feature: 'workload_hours',
      baselineMean: baseline.dutyHoursMean,
      baselineStd: baseline.dutyHoursStd,
      recentObservations: recentDutyObs,
      operationalContext: 'Workload surged following operational stand-to commitments',
    );
    if (dutyDeviation != null) deviations.add(dutyDeviation);

    // 2. Sleep time-series: recent 7 days showing sleep compression
    final recentSleepObs = [5.5, 5.0, 4.8, 5.2, 4.5, 4.2, 4.0];
    final sleepDeviation = detector.evaluateSeries(
      officerId: officerId,
      feature: 'sleep_hours',
      baselineMean: baseline.sleepMean,
      baselineStd: baseline.sleepStd,
      recentObservations: recentSleepObs,
      operationalContext: 'Significant sleep duration depression coinciding with night roster rotation',
    );
    if (sleepDeviation != null) deviations.add(sleepDeviation);

    // 3. Check-in distress: stable within baseline
    final recentDistressObs = [1.0, 2.0, 1.0, 2.0, 2.0, 1.0, 2.0];
    final distressDeviation = detector.evaluateSeries(
      officerId: officerId,
      feature: 'checkin_distress',
      baselineMean: baseline.checkInDistressMean,
      baselineStd: baseline.checkInDistressStd,
      recentObservations: recentDistressObs,
      operationalContext: '',
    );
    if (distressDeviation != null) deviations.add(distressDeviation);

    return deviations;
  }

  @override
  Future<UnitAggregateSignal> getUnitAggregate({
    required String unitId,
    required String unitName,
    int? officerCountOverride,
  }) async {
    final totalOfficers = officerCountOverride ?? 24;

    return UnitAggregateSignal.compute(
      unitId: unitId,
      unitName: unitName,
      totalOfficers: totalOfficers,
      avgFriction: 0.58,
      avgDuty: 10.8,
      avgSleep: 6.1,
      elevatedFatigueCount: 8,
      leaveDenialCount: 5,
      kThreshold: 5,
    );
  }

  @override
  Future<PersonalBaseline> recalibrateBaseline({
    required String officerId,
    required List<double> sleepObs,
    required List<double> dutyObs,
    required List<double> distressObs,
    required CohortPrior cohortPrior,
  }) async {
    final current = _cachedBaselines[officerId];
    final nextVersion = (current?.version ?? 0) + 1;

    final updated = PersonalBaseline.calibrate(
      officerId: officerId,
      sleepObservations: sleepObs,
      dutyObservations: dutyObs,
      distressObservations: distressObs,
      cohortPrior: cohortPrior,
      version: nextVersion,
    );

    _cachedBaselines[officerId] = updated;
    AppLogger.info('Recalibrated personal baseline for $officerId to version $nextVersion');
    return updated;
  }
}
