// lib/core/security/rbac_guard.dart
// Strict Role-Based Access Control (RBAC) Guard and Forbidden Endpoint Enforcement
// Enforces Welfare-HR Firewall, Minimum Group Size (k >= 10), and Break-Glass Logging

import '../logging/app_logger.dart';
import '../../features/auth/domain/user_role.dart';

enum ResourceType {
  // Officer Resources
  officerOwnData,
  officerPersonalBaseline,
  officerRiskExplanation,
  officerAccessLog,
  officerConsentSettings,

  // Clinical Resources (Counsellor / Medical Officer Only)
  clinicalAssessmentDetail,
  clinicalTherapyNotes,
  clinicalSafetyPlan,
  clinicalFollowUps,

  // Welfare Resources (Welfare Officer Only - Pseudonymised)
  welfarePseudonymisedTiers,
  welfareEscalations,
  welfareOutreachPipeline,
  welfareFamilyAssistance,

  // Command Resources (Commander Only - Minimum Group Size >= 10)
  commanderUnitAggregates,
  commanderRosterRecommendations,
  commanderOperationalAvailability,

  // Strictly Forbidden / Toxic Intersections
  individualClinicalDataForCommander,
  individualStressScoreForCommander,
  rawClinicalNotesForWelfareOfficer,
  unconsentedRealIdentityForWelfareOfficer,
  unitAdminAnalyticsForIndividualOfficer,
}

class ForbiddenAccessException implements Exception {
  final UserRole role;
  final ResourceType resource;
  final String message;

  const ForbiddenAccessException({
    required this.role,
    required this.resource,
    required this.message,
  });

  @override
  String toString() => 'ForbiddenAccessException: Role "${role.toDbString()}" is strictly barred from accessing "$resource". $message';
}

class BreakGlassEvent {
  final String id;
  final String requesterId;
  final UserRole requesterRole;
  final String targetOfficerId;
  final String reasonCode;
  final String clinicalJustification;
  final DateTime timestamp;
  final bool isReviewed;

  const BreakGlassEvent({
    required this.id,
    required this.requesterId,
    required this.requesterRole,
    required this.targetOfficerId,
    required this.reasonCode,
    required this.clinicalJustification,
    required this.timestamp,
    this.isReviewed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'requester_id': requesterId,
        'requester_role': requesterRole.toDbString(),
        'target_officer_id': targetOfficerId,
        'reason_code': reasonCode,
        'clinical_justification': clinicalJustification,
        'timestamp': timestamp.toIso8601String(),
        'is_reviewed': isReviewed,
      };
}

class RbacGuard {
  static const int minAggregateGroupSize = 10;
  static final List<BreakGlassEvent> _breakGlassLog = [];

  static List<BreakGlassEvent> get breakGlassLog => List.unmodifiable(_breakGlassLog);

  /// Validates whether a specific role is allowed to access a requested resource.
  /// Throws [ForbiddenAccessException] if the access is unauthorized.
  static void assertAccess({
    required UserRole role,
    required ResourceType resource,
    String? requesterOfficerId,
    String? targetOfficerId,
  }) {
    // 1. Strict Barrier: Commander accessing individual clinical/stress scores
    if (role == UserRole.commander) {
      if (resource == ResourceType.individualClinicalDataForCommander ||
          resource == ResourceType.individualStressScoreForCommander ||
          resource == ResourceType.clinicalAssessmentDetail ||
          resource == ResourceType.clinicalTherapyNotes ||
          resource == ResourceType.clinicalSafetyPlan ||
          resource == ResourceType.officerOwnData ||
          resource == ResourceType.officerRiskExplanation) {
        AppLogger.warning('SECURITY BREACH BLOCKED: Commander attempted to access individual clinical/stress scores.');
        throw ForbiddenAccessException(
          role: role,
          resource: resource,
          message: 'Welfare-HR Firewall strictly bars commanders from inspecting individual stress scores, PHQ-9/GAD-7 data, or therapy notes.',
        );
      }
    }

    // 2. Strict Barrier: Welfare officer accessing raw clinical therapy notes
    if (role == UserRole.welfareOfficer) {
      if (resource == ResourceType.rawClinicalNotesForWelfareOfficer ||
          resource == ResourceType.clinicalTherapyNotes ||
          resource == ResourceType.unconsentedRealIdentityForWelfareOfficer) {
        AppLogger.warning('SECURITY BREACH BLOCKED: Welfare Officer attempted to access raw clinical therapy notes or unconsented identity.');
        throw ForbiddenAccessException(
          role: role,
          resource: resource,
          message: 'Welfare officers operate exclusively on pseudonymised tiers. Clinical therapy notes and unconsented identities are strictly quarantined.',
        );
      }
    }

    // 3. Strict Barrier: Individual Officer accessing unit administration or other officers' data
    if (role == UserRole.officer) {
      if (resource == ResourceType.unitAdminAnalyticsForIndividualOfficer ||
          resource == ResourceType.commanderUnitAggregates ||
          resource == ResourceType.welfarePseudonymisedTiers ||
          resource == ResourceType.clinicalAssessmentDetail) {
        throw ForbiddenAccessException(
          role: role,
          resource: resource,
          message: 'Officers have access solely to their own wellness data, explanations, support hub, and access logs.',
        );
      }

      // Check officer identity matching
      if (targetOfficerId != null && requesterOfficerId != null && requesterOfficerId != targetOfficerId) {
        AppLogger.warning('SECURITY BREACH BLOCKED: Officer $requesterOfficerId attempted to access data for $targetOfficerId.');
        throw ForbiddenAccessException(
          role: role,
          resource: resource,
          message: 'Cross-officer unauthorized record inspection is strictly blocked.',
        );
      }
    }

    // 4. Strict Barrier: Counsellor accessing non-clinical command analytics
    if (role == UserRole.counsellor) {
      if (resource == ResourceType.commanderRosterRecommendations ||
          resource == ResourceType.commanderUnitAggregates) {
        throw ForbiddenAccessException(
          role: role,
          resource: resource,
          message: 'Clinical personnel cannot inspect command operational rosters or unit administrative strategies.',
        );
      }
    }

    AppLogger.debug('RBAC access approved for role ${role.toDbString()} -> $resource');
  }

  /// Enforces minimum group size (k >= 10) for unit-level aggregate reporting.
  /// If cohort size is less than [minGroupSize], suppression is required to prevent re-identification.
  static bool isCohortSizeSuppressed(int count) {
    return count < minAggregateGroupSize;
  }

  /// Asserts that a unit aggregate report meets the k-anonymity threshold.
  static void assertAggregateGroupSize(int count, {String unitName = 'Unit'}) {
    if (isCohortSizeSuppressed(count)) {
      AppLogger.warning('Aggregate query suppressed for $unitName: cohort size $count < $minAggregateGroupSize');
      throw ArgumentError(
        'Aggregate metrics suppressed: Cohort size ($count) is below the minimum group size threshold of $minAggregateGroupSize. Privacy-preserving suppression enforced.',
      );
    }
  }

  /// Records an audited break-glass access event for emergency clinician intervention.
  static BreakGlassEvent recordBreakGlass({
    required String requesterId,
    required UserRole requesterRole,
    required String targetOfficerId,
    required String reasonCode,
    required String clinicalJustification,
  }) {
    if (clinicalJustification.trim().length < 15) {
      throw ArgumentError('Break-glass emergency access requires an explicit, audited clinical justification (min 15 chars).');
    }

    final event = BreakGlassEvent(
      id: 'bg-${DateTime.now().microsecondsSinceEpoch}',
      requesterId: requesterId,
      requesterRole: requesterRole,
      targetOfficerId: targetOfficerId,
      reasonCode: reasonCode,
      clinicalJustification: clinicalJustification,
      timestamp: DateTime.now(),
    );

    _breakGlassLog.add(event);
    AppLogger.warning('BREAK-GLASS EMERGENCY ACCESSED by ${requesterRole.toDbString()} $requesterId for officer $targetOfficerId [Reason: $reasonCode]');
    return event;
  }
}
