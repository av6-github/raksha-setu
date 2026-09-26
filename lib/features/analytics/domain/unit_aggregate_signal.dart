// lib/features/analytics/domain/unit_aggregate_signal.dart
// Privacy-preserving unit-level aggregate operational analytics with strict k-anonymity

class UnitAggregateSignal {
  final String unitId;
  final String unitName;
  final int totalOfficers;
  final int kAnonymityThreshold; // Minimum group size (e.g. 5)
  final bool isAnonymized;
  final double averageFrictionIndex;
  final double averageDutyHours;
  final double averageSleepHours;
  final int officersWithElevatedFatigue;
  final int unitOperationalLeaveDenials;
  final List<String> systemicRecommendations;

  const UnitAggregateSignal({
    required this.unitId,
    required this.unitName,
    required this.totalOfficers,
    this.kAnonymityThreshold = 5,
    required this.isAnonymized,
    required this.averageFrictionIndex,
    required this.averageDutyHours,
    required this.averageSleepHours,
    required this.officersWithElevatedFatigue,
    required this.unitOperationalLeaveDenials,
    required this.systemicRecommendations,
  });

  /// Factory computing unit metrics with k-anonymity privacy check.
  /// If total officers is less than kAnonymityThreshold, granular aggregates are suppressed
  /// to completely eliminate any possibility of individual officer re-identification.
  factory UnitAggregateSignal.compute({
    required String unitId,
    required String unitName,
    required int totalOfficers,
    required double avgFriction,
    required double avgDuty,
    required double avgSleep,
    required int elevatedFatigueCount,
    required int leaveDenialCount,
    int kThreshold = 5,
  }) {
    if (totalOfficers < kThreshold) {
      // k-anonymity suppression
      return UnitAggregateSignal(
        unitId: unitId,
        unitName: unitName,
        totalOfficers: totalOfficers,
        kAnonymityThreshold: kThreshold,
        isAnonymized: false,
        averageFrictionIndex: 0.0,
        averageDutyHours: 0.0,
        averageSleepHours: 0.0,
        officersWithElevatedFatigue: 0,
        unitOperationalLeaveDenials: 0,
        systemicRecommendations: [
          'Data suppressed to uphold strict k-anonymity (unit size $totalOfficers < threshold $kThreshold). '
          'No individual or micro-cohort statistics are exposed to commanders.'
        ],
      );
    }

    final recommendations = <String>[];
    if (avgDuty > 10.0) {
      recommendations.add('Elevated unit roster hours (${avgDuty.toStringAsFixed(1)}h/day) indicates need for rotational reinforcements.');
    }
    if (leaveDenialCount >= 3) {
      recommendations.add('High operational leave denial count ($leaveDenialCount) signals systemic force over-commitment.');
    }
    if (elevatedFatigueCount >= (totalOfficers * 0.3).round()) {
      recommendations.add('Substantial fatigue clustering detected across ${((elevatedFatigueCount / totalOfficers) * 100).toStringAsFixed(0)}% of personnel.');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Unit operational workload and rest cycles are within standard equilibrium.');
    }

    return UnitAggregateSignal(
      unitId: unitId,
      unitName: unitName,
      totalOfficers: totalOfficers,
      kAnonymityThreshold: kThreshold,
      isAnonymized: true,
      averageFrictionIndex: avgFriction,
      averageDutyHours: avgDuty,
      averageSleepHours: avgSleep,
      officersWithElevatedFatigue: elevatedFatigueCount,
      unitOperationalLeaveDenials: leaveDenialCount,
      systemicRecommendations: recommendations,
    );
  }
}
