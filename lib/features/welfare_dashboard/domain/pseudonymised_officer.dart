// lib/features/welfare_dashboard/domain/pseudonymised_officer.dart
// Pseudonymised officer identity for welfare officer outreach without diagnostic label leakage

import '../../risk/domain/risk_score.dart';

class PseudonymisedOfficer {
  final String pseudoId; // e.g. P-ALPHA-702
  final RiskTier currentTier;
  final int daysInTier;
  final DateTime lastCheckInDate;
  final bool consentToDiscloseName;
  final String? realName; // Populated ONLY if consentToDiscloseName is true
  final String unitCode;
  final String hardshipPostingGrade; // e.g. 'Class-A High Altitude'

  const PseudonymisedOfficer({
    required this.pseudoId,
    required this.currentTier,
    required this.daysInTier,
    required this.lastCheckInDate,
    required this.consentToDiscloseName,
    this.realName,
    required this.unitCode,
    required this.hardshipPostingGrade,
  });

  String get displayIdentifier => consentToDiscloseName && realName != null
      ? '$realName ($pseudoId)'
      : 'Officer $pseudoId';

  Map<String, dynamic> toJson() => {
        'pseudo_id': pseudoId,
        'current_tier': currentTier.name,
        'days_in_tier': daysInTier,
        'last_check_in_date': lastCheckInDate.toIso8601String(),
        'consent_to_disclose_name': consentToDiscloseName,
        'real_name': consentToDiscloseName ? realName : null,
        'unit_code': unitCode,
        'hardship_posting_grade': hardshipPostingGrade,
      };

  factory PseudonymisedOfficer.fromJson(Map<String, dynamic> json) {
    return PseudonymisedOfficer(
      pseudoId: json['pseudo_id'] as String,
      currentTier: RiskTier.fromString(json['current_tier'] as String? ?? 'green'),
      daysInTier: json['days_in_tier'] as int? ?? 0,
      lastCheckInDate: DateTime.parse(json['last_check_in_date'] as String),
      consentToDiscloseName: json['consent_to_disclose_name'] as bool? ?? false,
      realName: json['real_name'] as String?,
      unitCode: json['unit_code'] as String? ?? '12-BN',
      hardshipPostingGrade: json['hardship_posting_grade'] as String? ?? 'Standard',
    );
  }
}
