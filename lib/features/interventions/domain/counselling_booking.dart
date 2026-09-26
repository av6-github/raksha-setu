// lib/features/interventions/domain/counselling_booking.dart
// Confidential human-in-the-loop clinical counselling session booking

class CounsellingBooking {
  final String id;
  final String officerId;
  final String counsellorName;
  final DateTime sessionDate;
  final String sessionType; // 'routine', 'welfare_followup', 'crisis_escalation', 'tele_counselling'
  final bool isTeleCounselling;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final bool attended;

  const CounsellingBooking({
    required this.id,
    required this.officerId,
    required this.counsellorName,
    required this.sessionDate,
    required this.sessionType,
    this.isTeleCounselling = false,
    this.status = 'scheduled',
    this.attended = false,
  });

  String get sessionTypeDisplay {
    switch (sessionType) {
      case 'tele_counselling':
        return 'Tele-MANAS Confidential Call';
      case 'welfare_followup':
        return 'Welfare Follow-up Consultation';
      case 'crisis_escalation':
        return 'Priority Human Crisis Consultation';
      default:
        return 'Regimental Counsellor Session';
    }
  }

  factory CounsellingBooking.fromMap(Map<String, dynamic> map) {
    return CounsellingBooking(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      counsellorName: map['counsellor_name'] as String? ?? 'Force Welfare Counsellor',
      sessionDate: DateTime.tryParse(map['session_date'] as String? ?? '') ?? DateTime.now(),
      sessionType: map['session_type'] as String? ?? 'routine',
      isTeleCounselling: map['is_tele_counselling'] as bool? ?? false,
      status: map['status'] as String? ?? 'scheduled',
      attended: map['attended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'counsellor_name': counsellorName,
      'session_date': sessionDate.toIso8601String(),
      'session_type': sessionType,
      'is_tele_counselling': isTeleCounselling,
      'status': status,
      'attended': attended,
    };
  }
}
