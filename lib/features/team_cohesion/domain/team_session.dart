// lib/features/team_cohesion/domain/team_session.dart
// Unit team session entity scheduled around operational duty rosters

import 'team_session_topic.dart';

class TeamSession {
  final String id;
  final String unitId;
  final String unitName;
  final String title;
  final TeamSessionTopic topic;
  final String facilitatorName;
  final String facilitatorRole; // 'Regimental Medical Officer', 'Force Counsellor', 'Senior Subedar Leader'
  final DateTime scheduledAt;
  final String location;
  final int durationMinutes;
  final bool isCompulsory;
  final int maxParticipants;
  final String status; // 'scheduled', 'in_progress', 'completed', 'cancelled'
  final String? targetShift; // e.g. 'Day Watch (Shift A)'

  const TeamSession({
    required this.id,
    required this.unitId,
    required this.unitName,
    required this.title,
    required this.topic,
    required this.facilitatorName,
    required this.facilitatorRole,
    required this.scheduledAt,
    required this.location,
    this.durationMinutes = 60,
    this.isCompulsory = false,
    this.maxParticipants = 25,
    this.status = 'scheduled',
    this.targetShift,
  });

  DateTime get endsAt => scheduledAt.add(Duration(minutes: durationMinutes));

  TeamSession copyWith({
    String? status,
    DateTime? scheduledAt,
    String? location,
  }) {
    return TeamSession(
      id: id,
      unitId: unitId,
      unitName: unitName,
      title: title,
      topic: topic,
      facilitatorName: facilitatorName,
      facilitatorRole: facilitatorRole,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      location: location ?? this.location,
      durationMinutes: durationMinutes,
      isCompulsory: isCompulsory,
      maxParticipants: maxParticipants,
      status: status ?? this.status,
      targetShift: targetShift,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unit_id': unitId,
        'unit_name': unitName,
        'title': title,
        'topic': topic.name,
        'facilitator_name': facilitatorName,
        'facilitator_role': facilitatorRole,
        'scheduled_at': scheduledAt.toIso8601String(),
        'location': location,
        'duration_minutes': durationMinutes,
        'is_compulsory': isCompulsory,
        'max_participants': maxParticipants,
        'status': status,
        'target_shift': targetShift,
      };

  factory TeamSession.fromJson(Map<String, dynamic> json) {
    return TeamSession(
      id: json['id'] as String,
      unitId: json['unit_id'] as String,
      unitName: json['unit_name'] as String? ?? 'Unit',
      title: json['title'] as String,
      topic: TeamSessionTopic.values.firstWhere(
        (t) => t.name == json['topic'],
        orElse: () => TeamSessionTopic.sleepHygiene,
      ),
      facilitatorName: json['facilitator_name'] as String,
      facilitatorRole: json['facilitator_role'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      location: json['location'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      isCompulsory: json['is_compulsory'] as bool? ?? false,
      maxParticipants: json['max_participants'] as int? ?? 25,
      status: json['status'] as String? ?? 'scheduled',
      targetShift: json['target_shift'] as String?,
    );
  }
}
