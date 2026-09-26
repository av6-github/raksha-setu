// lib/features/team_cohesion/domain/team_scheduler_engine.dart
// Enforces ethical scheduling: Anti-Stress Grouping Guarantee & Duty/Rest Conflict Detection

import '../../hrms/domain/duty_record.dart';
import 'team_session.dart';

class StressGroupingProhibitedException implements Exception {
  final String message;
  const StressGroupingProhibitedException(this.message);

  @override
  String toString() => 'StressGroupingProhibitedException: $message';
}

class ConflictResult {
  final bool hasConflict;
  final String? reason;

  const ConflictResult({
    required this.hasConflict,
    this.reason,
  });

  static const noConflict = ConflictResult(hasConflict: false);
}

class TeamSchedulerEngine {
  /// Prohibited criteria keys that could be used to segregate or group personnel by psychological status
  static const Set<String> _prohibitedKeys = {
    'stress_score',
    'stress_level',
    'risk_score',
    'risk_level',
    'clinical_score',
    'phq9',
    'gad7',
    'cssrs',
    'psych_evaluation',
    'vulnerability_index',
    'depression_score',
    'anxiety_score',
    'trauma_score',
  };

  /// Asserts that grouping criteria for team cohesion sessions do NOT use stress scores or clinical risk.
  /// Team sessions must ONLY be grouped by unit, platoon, squad, shift, or operational company.
  static void assertNoStressScoreGrouping(Map<String, dynamic> criteria) {
    for (final entry in criteria.entries) {
      final key = entry.key.toLowerCase().trim();
      if (_prohibitedKeys.contains(key)) {
        throw StressGroupingProhibitedException(
          'Ethical Firewall Violation: Grouping personnel by "$key" is strictly prohibited to prevent stigmatization. Sessions must be scheduled strictly by unit/shift.',
        );
      }

      final valStr = entry.value.toString().toLowerCase();
      for (final prohibited in _prohibitedKeys) {
        if (valStr.contains(prohibited)) {
          throw StressGroupingProhibitedException(
            'Ethical Firewall Violation: Grouping criteria value references prohibited metric "$prohibited".',
          );
        }
      }
    }
  }

  /// Detects whether a team session schedule conflicts with duty shifts or mandatory rest recovery
  static ConflictResult detectDutyRestConflict({
    required TeamSession session,
    required List<DutyRecord> duties,
  }) {
    for (final duty in duties) {
      final sessionDate = DateTime(session.scheduledAt.year, session.scheduledAt.month, session.scheduledAt.day);
      final dutyDate = DateTime(duty.date.year, duty.date.month, duty.date.day);

      // 1. Same-day night shift check: If officer is on night shift today or worked night shift yesterday
      if (duty.isNightShift) {
        final daysDiff = sessionDate.difference(dutyDate).inDays.abs();
        if (daysDiff <= 1) {
          // Night shifts require mandatory 8-hour diurnal rest window (typically 06:00 to 14:00 post-shift)
          final sessionHour = session.scheduledAt.hour;
          if (sessionHour >= 6 && sessionHour < 14) {
            return ConflictResult(
              hasConflict: true,
              reason: 'Session clashes with mandatory 8-hour post-night-shift rest window (${duty.shiftName}).',
            );
          }
        }
      }

      // 2. High consecutive fatigue check
      if (duty.isElevatedFatigue && sessionDate.isAtSameMomentAs(dutyDate)) {
        if (session.isCompulsory) {
          return ConflictResult(
            hasConflict: true,
            reason: 'Officer has elevated fatigue (${duty.consecutiveDaysOnDuty} consecutive duty days). Compulsory non-operational events are restricted.',
          );
        }
      }
    }

    return ConflictResult.noConflict;
  }
}
