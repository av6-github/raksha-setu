// test/unit/team_cohesion_test.dart
// Unit tests for Phase 11: Team Cohesion, Anti-Stress Grouping Firewall, and Duty/Rest Conflict Detection

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/hrms/domain/duty_record.dart';
import 'package:raksha_welfare/features/team_cohesion/data/team_session_repository.dart';
import 'package:raksha_welfare/features/team_cohesion/domain/team_scheduler_engine.dart';
import 'package:raksha_welfare/features/team_cohesion/domain/team_session.dart';
import 'package:raksha_welfare/features/team_cohesion/domain/team_session_topic.dart';

void main() {
  group('Phase 11: TeamSchedulerEngine (Anti-Stress Grouping Firewall)', () {
    test('Throws StressGroupingProhibitedException if grouping by stress_score', () {
      expect(
        () => TeamSchedulerEngine.assertNoStressScoreGrouping({'stress_score': 'high'}),
        throwsA(isA<StressGroupingProhibitedException>()),
      );
    });

    test('Throws StressGroupingProhibitedException if grouping by risk_level or clinical metrics', () {
      expect(
        () => TeamSchedulerEngine.assertNoStressScoreGrouping({'risk_level': 'tier-3'}),
        throwsA(isA<StressGroupingProhibitedException>()),
      );
      expect(
        () => TeamSchedulerEngine.assertNoStressScoreGrouping({'phq9': '>10'}),
        throwsA(isA<StressGroupingProhibitedException>()),
      );
      expect(
        () => TeamSchedulerEngine.assertNoStressScoreGrouping({'cssrs': 'positive'}),
        throwsA(isA<StressGroupingProhibitedException>()),
      );
      expect(
        () => TeamSchedulerEngine.assertNoStressScoreGrouping({'criteria': 'group_by_vulnerability_index'}),
        throwsA(isA<StressGroupingProhibitedException>()),
      );
    });

    test('Passes when grouping strictly by operational cohort (unit, shift, platoon)', () {
      expect(
        () => TeamSchedulerEngine.assertNoStressScoreGrouping({
          'unit_id': 'unit-alpha',
          'shift_name': 'Shift A',
          'platoon': 'Platoon 2',
        }),
        returnsNormally,
      );
    });
  });

  group('Phase 11: Duty/Rest Conflict Detection', () {
    final now = DateTime.now();
    final todayMorningSession = TeamSession(
      id: 'session-test',
      unitId: 'unit-alpha',
      unitName: 'Unit Alpha',
      title: 'Morning Recovery',
      topic: TeamSessionTopic.sleepHygiene,
      facilitatorName: 'Dr. Major Raman',
      facilitatorRole: 'RMO',
      scheduledAt: DateTime(now.year, now.month, now.day, 9, 0), // 09:00 AM
      location: 'Camp Hall',
      isCompulsory: false,
    );

    test('Detects conflict if officer just came off night shift during diurnal rest window', () {
      final nightDuty = DutyRecord(
        id: 'duty-1',
        officerId: 'off-1',
        date: DateTime(now.year, now.month, now.day),
        shiftName: 'Night Picket Watch',
        isNightShift: true,
      );

      final conflict = TeamSchedulerEngine.detectDutyRestConflict(
        session: todayMorningSession,
        duties: [nightDuty],
      );

      expect(conflict.hasConflict, isTrue);
      expect(conflict.reason, contains('mandatory 8-hour post-night-shift rest window'));
    });

    test('Detects conflict if compulsory session scheduled during elevated consecutive duty fatigue', () {
      final compulsorySession = todayMorningSession.copyWith(
        scheduledAt: DateTime(now.year, now.month, now.day, 16, 0), // 16:00 PM (outside night rest)
      );

      final fatiguedDuty = DutyRecord(
        id: 'duty-2',
        officerId: 'off-1',
        date: DateTime(now.year, now.month, now.day),
        shiftName: 'Day Watch',
        isNightShift: false,
        consecutiveDaysOnDuty: 14, // Elevated fatigue >= 12
      );

      // Non-compulsory is allowed
      final nonCompulsoryConflict = TeamSchedulerEngine.detectDutyRestConflict(
        session: compulsorySession, // isCompulsory = false
        duties: [fatiguedDuty],
      );
      expect(nonCompulsoryConflict.hasConflict, isFalse);

      // Compulsory is blocked
      final forcedCompulsory = TeamSession(
        id: 'session-compulsory',
        unitId: 'unit-alpha',
        unitName: 'Unit Alpha',
        title: 'Compulsory Drill',
        topic: TeamSessionTopic.operationalDecompression,
        facilitatorName: 'Subedar Major',
        facilitatorRole: 'JCO',
        scheduledAt: DateTime(now.year, now.month, now.day, 16, 0),
        location: 'Ground',
        isCompulsory: true,
      );

      final compulsoryConflict = TeamSchedulerEngine.detectDutyRestConflict(
        session: forcedCompulsory,
        duties: [fatiguedDuty],
      );
      expect(compulsoryConflict.hasConflict, isTrue);
      expect(compulsoryConflict.reason, contains('elevated fatigue'));
    });

    test('Reports no conflict when session conforms to rest and duty guidelines', () {
      final normalDuty = DutyRecord(
        id: 'duty-3',
        officerId: 'off-1',
        date: DateTime(now.year, now.month, now.day),
        shiftName: 'Day Watch',
        isNightShift: false,
        consecutiveDaysOnDuty: 3,
      );

      final afternoonSession = TeamSession(
        id: 'session-ok',
        unitId: 'unit-alpha',
        unitName: 'Unit Alpha',
        title: 'Afternoon Cohesion',
        topic: TeamSessionTopic.peerSupportSkills,
        facilitatorName: 'Capt. Sen',
        facilitatorRole: 'Counsellor',
        scheduledAt: DateTime(now.year, now.month, now.day, 16, 30),
        location: 'Mess Hall',
      );

      final conflict = TeamSchedulerEngine.detectDutyRestConflict(
        session: afternoonSession,
        duties: [normalDuty],
      );
      expect(conflict.hasConflict, isFalse);
    });
  });

  group('Phase 11: TeamSessionRepository', () {
    late TeamSessionRepository repo;

    setUp(() {
      repo = TeamSessionRepository();
    });

    test('Loads pre-populated team cohesion sessions for unit', () async {
      final sessions = await repo.getSessionsForUnit('unit-alpha');
      expect(sessions.isNotEmpty, isTrue);
      expect(sessions.any((s) => s.topic == TeamSessionTopic.sleepHygiene), isTrue);
    });

    test('Prevents scheduling if grouping criteria violates anti-stress firewall', () async {
      final newSession = TeamSession(
        id: 'session-violating',
        unitId: 'unit-alpha',
        unitName: 'Unit Alpha',
        title: 'Stressed Officers Cohort',
        topic: TeamSessionTopic.operationalDecompression,
        facilitatorName: 'Dr. Raman',
        facilitatorRole: 'RMO',
        scheduledAt: DateTime.now().add(const Duration(days: 2)),
        location: 'Hall',
      );

      expect(
        () => repo.scheduleSession(
          newSession,
          groupingCriteria: {'risk_score': 'high'},
        ),
        throwsA(isA<StressGroupingProhibitedException>()),
      );
    });

    test('Records confirmed attendance for officer', () async {
      final record = await repo.recordAttendance(
        sessionId: 'session-001',
        officerId: 'officer-99',
        attended: true,
        feedbackNotes: 'Good recovery concepts discussed.',
      );

      expect(record.sessionId, equals('session-001'));
      expect(record.officerId, equals('officer-99'));
      expect(record.attended, isTrue);
      expect(record.optedForIndividualAlternative, isFalse);

      final fetched = await repo.getOfficerAttendance('session-001', 'officer-99');
      expect(fetched, isNotNull);
      expect(fetched!.attended, isTrue);
    });

    test('Confidential 1-on-1 alternative opt-in records without stigma', () async {
      final record = await repo.optForIndividualAlternative(
        sessionId: 'session-002',
        officerId: 'officer-101',
        reason: 'Prefer private consultation',
      );

      expect(record.sessionId, equals('session-002'));
      expect(record.officerId, equals('officer-101'));
      expect(record.attended, isFalse);
      expect(record.optedForIndividualAlternative, isTrue);

      final fetched = await repo.getOfficerAttendance('session-002', 'officer-101');
      expect(fetched, isNotNull);
      expect(fetched!.optedForIndividualAlternative, isTrue);
    });
  });
}
