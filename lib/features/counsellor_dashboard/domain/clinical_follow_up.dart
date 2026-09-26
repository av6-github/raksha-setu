// lib/features/counsellor_dashboard/domain/clinical_follow_up.dart
// Clinical follow-up sessions, observations, and therapeutic progression

class ClinicalFollowUp {
  final String id;
  final String caseId;
  final String officerId;
  final DateTime sessionDate;
  final String sessionType; // 'individual_counselling', 'trauma_debrief', 'tele_manas_review'
  final String progressNote;
  final String attendance; // 'attended', 'rescheduled', 'unexcused'
  final String rtdRecommendation; // e.g. 'Gradual duty resumption with daytime shift preference'

  const ClinicalFollowUp({
    required this.id,
    required this.caseId,
    required this.officerId,
    required this.sessionDate,
    required this.sessionType,
    required this.progressNote,
    required this.attendance,
    required this.rtdRecommendation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'case_id': caseId,
        'officer_id': officerId,
        'session_date': sessionDate.toIso8601String(),
        'session_type': sessionType,
        'progress_note': progressNote,
        'attendance': attendance,
        'rtd_recommendation': rtdRecommendation,
      };
}
