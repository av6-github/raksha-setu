// lib/features/performance/domain/acr_context_note.dart
// Welfare-HR Firewall Enforced: Non-clinical context notes for reporting officers.
// Absolutely NO stress scores, assessments, or counselling records permitted.

class AcrContextNote {
  final String id;
  final String officerId;
  final int reportingPeriodYear;
  final String nonClinicalHrContext;
  final bool verifiedNoStressData; // Enforced true by database constraint
  final String? approvedByIdentityId;
  final DateTime createdAt;

  const AcrContextNote({
    required this.id,
    required this.officerId,
    required this.reportingPeriodYear,
    required this.nonClinicalHrContext,
    this.verifiedNoStressData = true,
    this.approvedByIdentityId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'officer_id': officerId,
        'reporting_period_year': reportingPeriodYear,
        'non_clinical_hr_context': nonClinicalHrContext,
        'verified_no_stress_data': verifiedNoStressData,
        'approved_by_identity_id': approvedByIdentityId,
        'created_at': createdAt.toIso8601String(),
      };

  factory AcrContextNote.fromJson(Map<String, dynamic> json) {
    return AcrContextNote(
      id: json['id'] as String,
      officerId: json['officer_id'] as String,
      reportingPeriodYear: json['reporting_period_year'] as int,
      nonClinicalHrContext: json['non_clinical_hr_context'] as String,
      verifiedNoStressData: json['verified_no_stress_data'] as bool? ?? true,
      approvedByIdentityId: json['approved_by_identity_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
