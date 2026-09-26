// lib/features/counsellor_dashboard/domain/clinical_case.dart
// Clinical case record for licensed force counsellors and medical officers

class ClinicalCase {
  final String caseId;
  final String officerId;
  final String officerDisplayName;
  final String rank;
  final String unit;
  final String activeConcern;
  final int lastPhq9Score;
  final int lastGad7Score;
  final String cssrsSeverity; // 'none', 'mild', 'moderate', 'high', 'imminent'
  final bool hasActiveSafetyPlan;
  final String status; // 'active', 'monitoring', 'discharged'
  final DateTime nextSessionDate;
  final List<String> clinicalNotes;

  const ClinicalCase({
    required this.caseId,
    required this.officerId,
    required this.officerDisplayName,
    required this.rank,
    required this.unit,
    required this.activeConcern,
    required this.lastPhq9Score,
    required this.lastGad7Score,
    required this.cssrsSeverity,
    required this.hasActiveSafetyPlan,
    required this.status,
    required this.nextSessionDate,
    required this.clinicalNotes,
  });

  ClinicalCase copyWith({
    String? status,
    DateTime? nextSessionDate,
    List<String>? clinicalNotes,
    bool? hasActiveSafetyPlan,
  }) {
    return ClinicalCase(
      caseId: caseId,
      officerId: officerId,
      officerDisplayName: officerDisplayName,
      rank: rank,
      unit: unit,
      activeConcern: activeConcern,
      lastPhq9Score: lastPhq9Score,
      lastGad7Score: lastGad7Score,
      cssrsSeverity: cssrsSeverity,
      hasActiveSafetyPlan: hasActiveSafetyPlan ?? this.hasActiveSafetyPlan,
      status: status ?? this.status,
      nextSessionDate: nextSessionDate ?? this.nextSessionDate,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'case_id': caseId,
        'officer_id': officerId,
        'officer_display_name': officerDisplayName,
        'rank': rank,
        'unit': unit,
        'active_concern': activeConcern,
        'last_phq9_score': lastPhq9Score,
        'last_gad7_score': lastGad7Score,
        'cssrs_severity': cssrsSeverity,
        'has_active_safety_plan': hasActiveSafetyPlan,
        'status': status,
        'next_session_date': nextSessionDate.toIso8601String(),
        'clinical_notes': clinicalNotes,
      };
}
