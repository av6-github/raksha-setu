// lib/features/welfare_dashboard/domain/welfare_escalation.dart
// Welfare escalations for proactive human non-clinical outreach

import '../../risk/domain/risk_score.dart';

enum OutreachStatus {
  pending,
  contacted,
  supportPackageDispatched,
  respiteLeaveFacilitated,
  resolved;

  static OutreachStatus fromString(String val) {
    return OutreachStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => OutreachStatus.pending,
    );
  }
}

class WelfareEscalation {
  final String id;
  final String pseudoId;
  final RiskTier tier;
  final DateTime escalatedAt;
  final OutreachStatus status;
  final String triggerReason; // Non-clinical operational trigger: e.g. "Consecutive 45-day high altitude patrol"
  final String? actionLogNotes;
  final DateTime? lastContactedAt;

  const WelfareEscalation({
    required this.id,
    required this.pseudoId,
    required this.tier,
    required this.escalatedAt,
    required this.status,
    required this.triggerReason,
    this.actionLogNotes,
    this.lastContactedAt,
  });

  WelfareEscalation copyWith({
    OutreachStatus? status,
    String? actionLogNotes,
    DateTime? lastContactedAt,
  }) {
    return WelfareEscalation(
      id: id,
      pseudoId: pseudoId,
      tier: tier,
      escalatedAt: escalatedAt,
      status: status ?? this.status,
      triggerReason: triggerReason,
      actionLogNotes: actionLogNotes ?? this.actionLogNotes,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pseudo_id': pseudoId,
        'tier': tier.name,
        'escalated_at': escalatedAt.toIso8601String(),
        'status': status.name,
        'trigger_reason': triggerReason,
        'action_log_notes': actionLogNotes,
        'last_contacted_at': lastContactedAt?.toIso8601String(),
      };
}
