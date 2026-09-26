// lib/features/team_cohesion/domain/session_attendance.dart
// Attendance tracking with confidential option for 1-on-1 individual alternative

class SessionAttendance {
  final String id;
  final String sessionId;
  final String officerId;
  final bool attended;
  final bool optedForIndividualAlternative;
  final String? feedbackNotes;
  final DateTime createdAt;

  const SessionAttendance({
    required this.id,
    required this.sessionId,
    required this.officerId,
    this.attended = false,
    this.optedForIndividualAlternative = false,
    this.feedbackNotes,
    required this.createdAt,
  });

  SessionAttendance copyWith({
    bool? attended,
    bool? optedForIndividualAlternative,
    String? feedbackNotes,
  }) {
    return SessionAttendance(
      id: id,
      sessionId: sessionId,
      officerId: officerId,
      attended: attended ?? this.attended,
      optedForIndividualAlternative: optedForIndividualAlternative ?? this.optedForIndividualAlternative,
      feedbackNotes: feedbackNotes ?? this.feedbackNotes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'officer_id': officerId,
        'attended': attended,
        'opted_for_individual_alternative': optedForIndividualAlternative,
        'feedback_notes': feedbackNotes,
        'created_at': createdAt.toIso8601String(),
      };

  factory SessionAttendance.fromJson(Map<String, dynamic> json) {
    return SessionAttendance(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      officerId: json['officer_id'] as String,
      attended: json['attended'] as bool? ?? false,
      optedForIndividualAlternative: json['opted_for_individual_alternative'] as bool? ?? false,
      feedbackNotes: json['feedback_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
