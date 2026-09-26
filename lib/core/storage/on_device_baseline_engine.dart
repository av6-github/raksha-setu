// lib/core/storage/on_device_baseline_engine.dart
// On-device local baseline calculation and CUSUM change-point alert generation without internet connectivity

import 'dart:math';

class LocalBaselineMetrics {
  final int sampleCount;
  final double meanSleep;
  final double stdDevSleep;
  final double meanWorkload;
  final double stdDevWorkload;
  final bool sleepShiftAlert;
  final bool workloadSpikeAlert;

  const LocalBaselineMetrics({
    required this.sampleCount,
    required this.meanSleep,
    required this.stdDevSleep,
    required this.meanWorkload,
    required this.stdDevWorkload,
    required this.sleepShiftAlert,
    required this.workloadSpikeAlert,
  });
}

class OnDeviceBaselineEngine {
  static const double cusumThreshold = 4.0; // Standard decision boundary h
  static const double cusumSlack = 0.5; // Reference value k

  /// Computes rolling baseline statistics from a list of local check-ins (sleep and workload)
  static LocalBaselineMetrics computeLocalBaseline({
    required List<Map<String, dynamic>> localCheckIns,
  }) {
    if (localCheckIns.isEmpty) {
      return const LocalBaselineMetrics(
        sampleCount: 0,
        meanSleep: 7.0,
        stdDevSleep: 1.0,
        meanWorkload: 8.0,
        stdDevWorkload: 1.5,
        sleepShiftAlert: false,
        workloadSpikeAlert: false,
      );
    }

    final sleepValues = localCheckIns
        .map((c) => (c['sleep_hours'] as num?)?.toDouble())
        .whereType<double>()
        .toList();

    final workloadValues = localCheckIns
        .map((c) => (c['workload_score'] as num?)?.toDouble() ?? (c['duty_hours'] as num?)?.toDouble())
        .whereType<double>()
        .toList();

    final n = max(sleepValues.length, workloadValues.length);

    final meanSleep = sleepValues.isNotEmpty
        ? sleepValues.reduce((a, b) => a + b) / sleepValues.length
        : 7.0;

    final meanWorkload = workloadValues.isNotEmpty
        ? workloadValues.reduce((a, b) => a + b) / workloadValues.length
        : 8.0;

    // Calculate sample standard deviations
    double varSleep = 0.0;
    for (final s in sleepValues) {
      varSleep += pow(s - meanSleep, 2);
    }
    final stdDevSleep = sleepValues.length > 1
        ? sqrt(varSleep / (sleepValues.length - 1))
        : 1.0;

    double varWorkload = 0.0;
    for (final w in workloadValues) {
      varWorkload += pow(w - meanWorkload, 2);
    }
    final stdDevWorkload = workloadValues.length > 1
        ? sqrt(varWorkload / (workloadValues.length - 1))
        : 1.5;

    // Baseline reference: use historical entries prior to test window if available
    final baselineSleepValues = sleepValues.length > 5
        ? sleepValues.sublist(0, sleepValues.length - 5)
        : sleepValues;
    final bMeanSleep = baselineSleepValues.reduce((a, b) => a + b) / baselineSleepValues.length;
    double bVarSleep = 0.0;
    for (final s in baselineSleepValues) {
      bVarSleep += pow(s - bMeanSleep, 2);
    }
    final bStdSleep = baselineSleepValues.length > 1
        ? max(0.4, sqrt(bVarSleep / (baselineSleepValues.length - 1)))
        : 1.0;

    final baselineWorkloadValues = workloadValues.length > 5
        ? workloadValues.sublist(0, workloadValues.length - 5)
        : workloadValues;
    final bMeanWorkload = baselineWorkloadValues.reduce((a, b) => a + b) / baselineWorkloadValues.length;
    double bVarWorkload = 0.0;
    for (final w in baselineWorkloadValues) {
      bVarWorkload += pow(w - bMeanWorkload, 2);
    }
    final bStdWorkload = baselineWorkloadValues.length > 1
        ? max(0.5, sqrt(bVarWorkload / (baselineWorkloadValues.length - 1)))
        : 1.5;

    // Run Two-Sided CUSUM detection on latest 5 entries in chronological order
    bool sleepAlert = false;
    bool workloadAlert = false;

    if (sleepValues.length >= 5) {
      final recent = sleepValues.sublist(sleepValues.length - 5);
      double sNeg = 0.0; // detecting downward sleep shift
      for (final s in recent) {
        final z = (bMeanSleep - s) / bStdSleep;
        sNeg = max(0.0, sNeg + z - cusumSlack);
        if (sNeg >= cusumThreshold) {
          sleepAlert = true;
          break;
        }
      }
    }

    if (workloadValues.length >= 5) {
      final recent = workloadValues.sublist(workloadValues.length - 5);
      double sPos = 0.0; // detecting upward workload shift
      for (final w in recent) {
        final z = (w - bMeanWorkload) / bStdWorkload;
        sPos = max(0.0, sPos + z - cusumSlack);
        if (sPos >= cusumThreshold) {
          workloadAlert = true;
          break;
        }
      }
    }

    return LocalBaselineMetrics(
      sampleCount: n,
      meanSleep: double.parse(meanSleep.toStringAsFixed(1)),
      stdDevSleep: double.parse(stdDevSleep.toStringAsFixed(2)),
      meanWorkload: double.parse(meanWorkload.toStringAsFixed(1)),
      stdDevWorkload: double.parse(stdDevWorkload.toStringAsFixed(2)),
      sleepShiftAlert: sleepAlert,
      workloadSpikeAlert: workloadAlert,
    );
  }
}
