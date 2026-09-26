// lib/features/anonymous_reporting/domain/report_category.dart
// Categories for whistleblower and anonymous welfare disclosures

enum ReportCategory {
  bullying,
  harassment,
  unsafeConditions,
  concernForColleague,
  otherWelfareConcern;

  String get displayName {
    switch (this) {
      case ReportCategory.bullying:
        return 'Bullying & Hazing';
      case ReportCategory.harassment:
        return 'Harassment & Abuse of Authority';
      case ReportCategory.unsafeConditions:
        return 'Unsafe Operational or Living Conditions';
      case ReportCategory.concernForColleague:
        return 'Critical Concern for Colleague Safety/Welfare';
      case ReportCategory.otherWelfareConcern:
        return 'Other Welfare or Vigilance Concern';
    }
  }

  String get description {
    switch (this) {
      case ReportCategory.bullying:
        return 'Targeted intimidation, hazing, or verbal/physical mistreatment.';
      case ReportCategory.harassment:
        return 'Sexual, personal, or administrative harassment and abuse of power.';
      case ReportCategory.unsafeConditions:
        return 'Defective safety gear, dangerous accommodation, extreme climate neglect, or ration deficits.';
      case ReportCategory.concernForColleague:
        return 'Observation of a colleague in extreme distress, crisis, or self-harm risk requiring confidential intervention.';
      case ReportCategory.otherWelfareConcern:
        return 'Institutional welfare lapses, denial of statutory leave, or irregularities.';
    }
  }

  String get code {
    switch (this) {
      case ReportCategory.bullying:
        return 'bullying';
      case ReportCategory.harassment:
        return 'harassment';
      case ReportCategory.unsafeConditions:
        return 'unsafe_conditions';
      case ReportCategory.concernForColleague:
        return 'concern_for_colleague';
      case ReportCategory.otherWelfareConcern:
        return 'other_welfare_concern';
    }
  }

  static ReportCategory fromCode(String code) {
    switch (code) {
      case 'bullying':
        return ReportCategory.bullying;
      case 'harassment':
        return ReportCategory.harassment;
      case 'unsafe_conditions':
        return ReportCategory.unsafeConditions;
      case 'concern_for_colleague':
        return ReportCategory.concernForColleague;
      default:
        return ReportCategory.otherWelfareConcern;
    }
  }
}
