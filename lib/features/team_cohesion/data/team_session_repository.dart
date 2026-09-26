// lib/features/team_cohesion/data/team_session_repository.dart
// Repository for Team Cohesion sessions and attendance with anti-stress grouping verification

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../hrms/domain/duty_record.dart';
import '../domain/session_attendance.dart';
import '../domain/team_session.dart';
import '../domain/team_session_topic.dart';
import '../domain/team_scheduler_engine.dart';

abstract class ITeamSessionRepository {
  Future<List<TeamSession>> getSessionsForUnit(String unitId);
  Future<TeamSession> scheduleSession(
    TeamSession session, {
    Map<String, dynamic>? groupingCriteria,
    List<DutyRecord>? officerDuties,
  });
  Future<List<SessionAttendance>> getAttendanceForSession(String sessionId);
  Future<SessionAttendance?> getOfficerAttendance(String sessionId, String officerId);
  Future<SessionAttendance> recordAttendance({
    required String sessionId,
    required String officerId,
    required bool attended,
    String? feedbackNotes,
  });
  Future<SessionAttendance> optForIndividualAlternative({
    required String sessionId,
    required String officerId,
    String? reason,
  });
}

class TeamSessionRepository implements ITeamSessionRepository {
  final SupabaseClient? client;

  // In-memory fallback / mock store for offline & test operation
  final List<TeamSession> _mockSessions = [
    TeamSession(
      id: 'session-001',
      unitId: 'unit-alpha',
      unitName: '14 Rajputana Rifles (Alpha Coy)',
      title: 'Squad Sleep Hygiene & Circadian Banking',
      topic: TeamSessionTopic.sleepHygiene,
      facilitatorName: 'Dr. Major S. K. Raman',
      facilitatorRole: 'Regimental Medical Officer',
      scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 10)),
      location: 'Company Recreation Hall, Picket 4',
      durationMinutes: 45,
      isCompulsory: false,
      maxParticipants: 20,
      status: 'scheduled',
      targetShift: 'Shift B (Post-Watch)',
    ),
    TeamSession(
      id: 'session-002',
      unitId: 'unit-alpha',
      unitName: '14 Rajputana Rifles (Alpha Coy)',
      title: 'Tactical Decompression & Adrenaline Down-regulation',
      topic: TeamSessionTopic.operationalDecompression,
      facilitatorName: 'Capt. Ananya Sen',
      facilitatorRole: 'Force Counsellor',
      scheduledAt: DateTime.now().add(const Duration(days: 3, hours: 14)),
      location: 'Forward Base Camp Auditorium',
      durationMinutes: 60,
      isCompulsory: false,
      maxParticipants: 25,
      status: 'scheduled',
      targetShift: 'General Roster',
    ),
    TeamSession(
      id: 'session-003',
      unitId: 'unit-alpha',
      unitName: '14 Rajputana Rifles (Alpha Coy)',
      title: 'Buddy-Pair Peer Support & Warning Signs',
      topic: TeamSessionTopic.peerSupportSkills,
      facilitatorName: 'Subedar Major H. Singh',
      facilitatorRole: 'Senior JCO Leader',
      scheduledAt: DateTime.now().add(const Duration(days: 5, hours: 9)),
      location: 'Briefing Room 2',
      durationMinutes: 50,
      isCompulsory: true,
      maxParticipants: 30,
      status: 'scheduled',
      targetShift: 'Platoon 1',
    ),
  ];

  final List<SessionAttendance> _mockAttendance = [];

  TeamSessionRepository({this.client});

  @override
  Future<List<TeamSession>> getSessionsForUnit(String unitId) async {
    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('team_sessions')
            .select()
            .eq('unit_id', unitId)
            .order('scheduled_at', ascending: true);
        return (res as List).map((row) => TeamSession.fromJson(row)).toList();
      } catch (_) {
        // Fallback to mock
      }
    }
    return _mockSessions.where((s) => s.unitId == unitId || s.unitId == 'unit-alpha').toList();
  }

  @override
  Future<TeamSession> scheduleSession(
    TeamSession session, {
    Map<String, dynamic>? groupingCriteria,
    List<DutyRecord>? officerDuties,
  }) async {
    // 1. Enforce strict anti-stress grouping firewall
    if (groupingCriteria != null && groupingCriteria.isNotEmpty) {
      TeamSchedulerEngine.assertNoStressScoreGrouping(groupingCriteria);
    }

    // 2. Check duty/rest conflicts if duty records provided
    if (officerDuties != null && officerDuties.isNotEmpty) {
      final conflict = TeamSchedulerEngine.detectDutyRestConflict(
        session: session,
        duties: officerDuties,
      );
      if (conflict.hasConflict) {
        throw StateError('Cannot schedule session due to duty/rest conflict: ${conflict.reason}');
      }
    }

    final c = client;
    if (c != null) {
      try {
        final res = await c.from('team_sessions').insert(session.toJson()).select().single();
        return TeamSession.fromJson(res);
      } catch (_) {
        // Fallback
      }
    }

    _mockSessions.add(session);
    return session;
  }

  @override
  Future<List<SessionAttendance>> getAttendanceForSession(String sessionId) async {
    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('session_attendance')
            .select()
            .eq('session_id', sessionId);
        return (res as List).map((row) => SessionAttendance.fromJson(row)).toList();
      } catch (_) {
        // Fallback
      }
    }
    return _mockAttendance.where((a) => a.sessionId == sessionId).toList();
  }

  @override
  Future<SessionAttendance?> getOfficerAttendance(String sessionId, String officerId) async {
    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('session_attendance')
            .select()
            .eq('session_id', sessionId)
            .eq('officer_id', officerId)
            .maybeSingle();
        if (res != null) {
          return SessionAttendance.fromJson(res);
        }
      } catch (_) {
        // Fallback
      }
    }
    try {
      return _mockAttendance.firstWhere(
        (a) => a.sessionId == sessionId && a.officerId == officerId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SessionAttendance> recordAttendance({
    required String sessionId,
    required String officerId,
    required bool attended,
    String? feedbackNotes,
  }) async {
    final record = SessionAttendance(
      id: 'att-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      officerId: officerId,
      attended: attended,
      optedForIndividualAlternative: false,
      feedbackNotes: feedbackNotes,
      createdAt: DateTime.now(),
    );

    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('session_attendance')
            .upsert(record.toJson())
            .select()
            .single();
        return SessionAttendance.fromJson(res);
      } catch (_) {
        // Fallback
      }
    }

    _mockAttendance.removeWhere((a) => a.sessionId == sessionId && a.officerId == officerId);
    _mockAttendance.add(record);
    return record;
  }

  @override
  Future<SessionAttendance> optForIndividualAlternative({
    required String sessionId,
    required String officerId,
    String? reason,
  }) async {
    final record = SessionAttendance(
      id: 'att-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      officerId: officerId,
      attended: false,
      optedForIndividualAlternative: true,
      feedbackNotes: reason ?? 'Requested confidential 1-on-1 alternative session',
      createdAt: DateTime.now(),
    );

    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('session_attendance')
            .upsert(record.toJson())
            .select()
            .single();
        return SessionAttendance.fromJson(res);
      } catch (_) {
        // Fallback
      }
    }

    _mockAttendance.removeWhere((a) => a.sessionId == sessionId && a.officerId == officerId);
    _mockAttendance.add(record);
    return record;
  }
}
