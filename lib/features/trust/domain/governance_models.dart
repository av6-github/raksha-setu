// lib/features/trust/domain/governance_models.dart
// Domain models for Ethics Review, Independent Oversight, Bias Audits, Break-Glass Logs, and Troop Co-Design

import 'package:flutter/material.dart';

enum OversightReviewType {
  ethicsBoard,
  clinicalAudit,
  firewallVerification,
  antiStigmatisation;

  String get displayName {
    switch (this) {
      case OversightReviewType.ethicsBoard:
        return 'Independent Ethics Board';
      case OversightReviewType.clinicalAudit:
        return 'Clinical Oversight Committee';
      case OversightReviewType.firewallVerification:
        return 'Welfare-HR Firewall Audit';
      case OversightReviewType.antiStigmatisation:
        return 'Anti-Stigmatisation Review';
    }
  }

  IconData get icon {
    switch (this) {
      case OversightReviewType.ethicsBoard:
        return Icons.gavel_rounded;
      case OversightReviewType.clinicalAudit:
        return Icons.health_and_safety_rounded;
      case OversightReviewType.firewallVerification:
        return Icons.security_rounded;
      case OversightReviewType.antiStigmatisation:
        return Icons.diversity_1_rounded;
    }
  }
}

class OversightReview {
  final String id;
  final DateTime reviewDate;
  final OversightReviewType reviewType;
  final String findings;
  final String? correctiveActions;
  final String status; // 'completed', 'action_required'
  final String approvedByName;

  const OversightReview({
    required this.id,
    required this.reviewDate,
    required this.reviewType,
    required this.findings,
    this.correctiveActions,
    this.status = 'completed',
    required this.approvedByName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'review_date': reviewDate.toIso8601String(),
    'review_type': reviewType.name,
    'findings': findings,
    'corrective_actions': correctiveActions,
    'status': status,
    'approved_by_name': approvedByName,
  };
}

class BiasAudit {
  final String id;
  final DateTime auditDate;
  final String subgroup; // 'Gender (Female/Male)', 'Rank (PBOR vs Officer)', 'Hardship (High-Hazard vs Peace)'
  final int sampleSize;
  final double falsePositiveRate;
  final double falseNegativeRate;
  final double disparityMetric; // e.g. 0.94 (Compliant if >= 0.80 per 4/5ths rule)
  final bool isCompliant;

  const BiasAudit({
    required this.id,
    required this.auditDate,
    required this.subgroup,
    required this.sampleSize,
    required this.falsePositiveRate,
    required this.falseNegativeRate,
    required this.disparityMetric,
    this.isCompliant = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'audit_date': auditDate.toIso8601String(),
    'subgroup': subgroup,
    'sample_size': sampleSize,
    'false_positive_rate': falsePositiveRate,
    'false_negative_rate': falseNegativeRate,
    'disparity_metric': disparityMetric,
    'is_compliant': isCompliant,
  };
}

enum BreakGlassStatus {
  pendingReview,
  validatedEmergency,
  unjustifiedBreach;

  String get displayName {
    switch (this) {
      case BreakGlassStatus.pendingReview:
        return 'Pending Oversight Review';
      case BreakGlassStatus.validatedEmergency:
        return 'Validated Emergency Access';
      case BreakGlassStatus.unjustifiedBreach:
        return 'Unjustified Policy Breach (Escalated)';
    }
  }

  Color get color {
    switch (this) {
      case BreakGlassStatus.pendingReview:
        return Colors.orange;
      case BreakGlassStatus.validatedEmergency:
        return Colors.green;
      case BreakGlassStatus.unjustifiedBreach:
        return Colors.red;
    }
  }
}

class BreakGlassEvent {
  final String id;
  final String actorIdentityId;
  final String actorName;
  final String officerId;
  final String officerName;
  final String reason;
  final String authorizedBy;
  final DateTime accessGrantedAt;
  final DateTime accessExpiresAt;
  final BreakGlassStatus reviewStatus;
  final String? reviewerNotes;
  final DateTime? reviewedAt;

  const BreakGlassEvent({
    required this.id,
    required this.actorIdentityId,
    required this.actorName,
    required this.officerId,
    required this.officerName,
    required this.reason,
    required this.authorizedBy,
    required this.accessGrantedAt,
    required this.accessExpiresAt,
    this.reviewStatus = BreakGlassStatus.pendingReview,
    this.reviewerNotes,
    this.reviewedAt,
  });

  BreakGlassEvent copyWith({
    String? id,
    String? actorIdentityId,
    String? actorName,
    String? officerId,
    String? officerName,
    String? reason,
    String? authorizedBy,
    DateTime? accessGrantedAt,
    DateTime? accessExpiresAt,
    BreakGlassStatus? reviewStatus,
    String? reviewerNotes,
    DateTime? reviewedAt,
  }) {
    return BreakGlassEvent(
      id: id ?? this.id,
      actorIdentityId: actorIdentityId ?? this.actorIdentityId,
      actorName: actorName ?? this.actorName,
      officerId: officerId ?? this.officerId,
      officerName: officerName ?? this.officerName,
      reason: reason ?? this.reason,
      authorizedBy: authorizedBy ?? this.authorizedBy,
      accessGrantedAt: accessGrantedAt ?? this.accessGrantedAt,
      accessExpiresAt: accessExpiresAt ?? this.accessExpiresAt,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'actor_identity_id': actorIdentityId,
    'actor_name': actorName,
    'officer_id': officerId,
    'officer_name': officerName,
    'reason': reason,
    'authorized_by': authorizedBy,
    'access_granted_at': accessGrantedAt.toIso8601String(),
    'access_expires_at': accessExpiresAt.toIso8601String(),
    'review_status': reviewStatus.name,
    'reviewer_notes': reviewerNotes,
    'reviewed_at': reviewedAt?.toIso8601String(),
  };
}

class CoDesignFeedback {
  final String id;
  final String officerRankDisplay;
  final String unit;
  final String topic; // 'App Lock & Pin', 'Welfare Firewall Clarification', 'Duty Roster Rest Rules'
  final String feedbackText;
  final String actionStatus; // 'implemented', 'under_review'
  final DateTime submittedAt;

  const CoDesignFeedback({
    required this.id,
    required this.officerRankDisplay,
    required this.unit,
    required this.topic,
    required this.feedbackText,
    this.actionStatus = 'implemented',
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'officer_rank_display': officerRankDisplay,
    'unit': unit,
    'topic': topic,
    'feedback_text': feedbackText,
    'action_status': actionStatus,
    'submitted_at': submittedAt.toIso8601String(),
  };
}

class ShadowPilotMetrics {
  final String modelVersion;
  final int totalShadowScored;
  final double concordanceWithClinicians; // e.g. 0.925
  final double brierScore; // e.g. 0.082
  final double prAuc; // e.g. 0.841
  final bool falsePositiveParity;
  final String goNoGoStatus; // 'PASSED_SHADOW_PILOT', 'PENDING'

  const ShadowPilotMetrics({
    required this.modelVersion,
    required this.totalShadowScored,
    required this.concordanceWithClinicians,
    required this.brierScore,
    required this.prAuc,
    this.falsePositiveParity = true,
    this.goNoGoStatus = 'PASSED_SHADOW_PILOT',
  });
}
