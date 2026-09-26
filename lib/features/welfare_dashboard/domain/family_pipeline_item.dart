// lib/features/welfare_dashboard/domain/family_pipeline_item.dart
// Family welfare pipeline tracking grants, education aid, and dependent support

enum FamilyRequestType {
  educationGrant,
  housingSupport,
  medicalAssistance,
  bereavementAid,
  resiliencePackage;

  String get displayName {
    switch (this) {
      case FamilyRequestType.educationGrant:
        return 'PMSS / Education Scholarship';
      case FamilyRequestType.housingSupport:
        return 'Family Quarters / Housing Aid';
      case FamilyRequestType.medicalAssistance:
        return 'Ayushman CAPF Dependent Claim';
      case FamilyRequestType.bereavementAid:
        return 'Ex-Gratia / Bereavement Support';
      case FamilyRequestType.resiliencePackage:
        return 'Family Morale Care Package';
    }
  }
}

class FamilyPipelineItem {
  final String id;
  final String familyMemberPseudoId; // e.g. 'FAM-882-SPOUSE'
  final String officerPseudoId;
  final FamilyRequestType requestType;
  final String status; // 'under_review', 'verified', 'disbursed'
  final DateTime submittedAt;
  final double? grantAmount;
  final String remarks;

  const FamilyPipelineItem({
    required this.id,
    required this.familyMemberPseudoId,
    required this.officerPseudoId,
    required this.requestType,
    required this.status,
    required this.submittedAt,
    this.grantAmount,
    required this.remarks,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'family_member_pseudo_id': familyMemberPseudoId,
        'officer_pseudo_id': officerPseudoId,
        'request_type': requestType.name,
        'status': status,
        'submitted_at': submittedAt.toIso8601String(),
        'grant_amount': grantAmount,
        'remarks': remarks,
      };
}
