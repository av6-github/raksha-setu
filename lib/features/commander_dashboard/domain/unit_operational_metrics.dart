// lib/features/commander_dashboard/domain/unit_operational_metrics.dart
// Aggregate operational readiness and fatigue metrics for command staff
// Strictly privacy-preserving: No individual stress ranking, k-anonymity >= 10 enforced

class UnitOperationalMetrics {
  final String unitCode;
  final String unitName;
  final int totalPersonnel;
  final bool isSuppressed; // True if totalPersonnel < 10 (k-anonymity privacy protection)
  final double highFatigueRosterPercent; // % of unit working >55h/week or consecutive watches
  final int consecutiveDutyFlagCount;
  final double leaveFrictionIndex; // Systemic leave denial rate (0.0 to 1.0)
  final int availableCount;
  final int medicallyUnavailableCount;
  final double aggregateReadinessScore; // 0.0 to 100.0

  const UnitOperationalMetrics({
    required this.unitCode,
    required this.unitName,
    required this.totalPersonnel,
    required this.isSuppressed,
    required this.highFatigueRosterPercent,
    required this.consecutiveDutyFlagCount,
    required this.leaveFrictionIndex,
    required this.availableCount,
    required this.medicallyUnavailableCount,
    required this.aggregateReadinessScore,
  });

  Map<String, dynamic> toJson() => {
        'unit_code': unitCode,
        'unit_name': unitName,
        'total_personnel': totalPersonnel,
        'is_suppressed': isSuppressed,
        'high_fatigue_roster_percent': highFatigueRosterPercent,
        'consecutive_duty_flag_count': consecutiveDutyFlagCount,
        'leave_friction_index': leaveFrictionIndex,
        'available_count': availableCount,
        'medically_unavailable_count': medicallyUnavailableCount,
        'aggregate_readiness_score': aggregateReadinessScore,
      };
}
