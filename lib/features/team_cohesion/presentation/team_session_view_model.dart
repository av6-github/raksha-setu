// lib/features/team_cohesion/presentation/team_session_view_model.dart
// Presentation ViewModel managing unit team cohesion sessions and confidential alternative requests

import 'package:flutter/foundation.dart';
import '../../hrms/domain/duty_record.dart';
import '../data/team_session_repository.dart';
import '../domain/session_attendance.dart';
import '../domain/team_session.dart';

class TeamSessionViewModel extends ChangeNotifier {
  final ITeamSessionRepository repository;

  List<TeamSession> _sessions = [];
  Map<String, SessionAttendance> _attendanceMap = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  TeamSessionViewModel({required this.repository});

  List<TeamSession> get sessions => _sessions;
  Map<String, SessionAttendance> get attendanceMap => _attendanceMap;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadSessions({
    required String unitId,
    required String officerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedSessions = await repository.getSessionsForUnit(unitId);
      final Map<String, SessionAttendance> newAttendanceMap = {};
      for (final session in loadedSessions) {
        final att = await repository.getOfficerAttendance(session.id, officerId);
        if (att != null) {
          newAttendanceMap[session.id] = att;
        }
      }
      _sessions = loadedSessions;
      _attendanceMap = newAttendanceMap;
    } catch (e) {
      _errorMessage = 'Failed to load team sessions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmAttendance({
    required String sessionId,
    required String officerId,
    String? feedbackNotes,
  }) async {
    _errorMessage = null;
    _successMessage = null;
    try {
      final att = await repository.recordAttendance(
        sessionId: sessionId,
        officerId: officerId,
        attended: true,
        feedbackNotes: feedbackNotes,
      );
      _attendanceMap[sessionId] = att;
      _successMessage = 'Attendance confirmed for session.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Could not record attendance: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> optForIndividualAlternative({
    required String sessionId,
    required String officerId,
    String? reason,
  }) async {
    _errorMessage = null;
    _successMessage = null;
    try {
      final att = await repository.optForIndividualAlternative(
        sessionId: sessionId,
        officerId: officerId,
        reason: reason,
      );
      _attendanceMap[sessionId] = att;
      _successMessage = 'Requested confidential 1-on-1 alternative session. No stigma, no command record.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Could not request individual alternative: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> scheduleSession({
    required TeamSession session,
    Map<String, dynamic>? groupingCriteria,
    List<DutyRecord>? officerDuties,
  }) async {
    _errorMessage = null;
    _successMessage = null;
    try {
      final scheduled = await repository.scheduleSession(
        session,
        groupingCriteria: groupingCriteria,
        officerDuties: officerDuties,
      );
      _sessions.add(scheduled);
      _successMessage = 'Session successfully scheduled.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
