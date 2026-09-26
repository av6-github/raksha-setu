// test/unit/rbac_test.dart
// Unit tests for Role-Based Access Control (RBAC), Forbidden Endpoints, and k-Anonymity (Phase 9)

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/security/rbac_guard.dart';
import 'package:raksha_welfare/features/auth/domain/user_role.dart';

void main() {
  group('Phase 9 — RBAC and Forbidden Endpoints Tests', () {
    test('Commander is strictly blocked from accessing individual clinical scores or therapy notes', () {
      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.commander,
          resource: ResourceType.individualStressScoreForCommander,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.commander,
          resource: ResourceType.clinicalAssessmentDetail,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.commander,
          resource: ResourceType.clinicalTherapyNotes,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.commander,
          resource: ResourceType.clinicalSafetyPlan,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );
    });

    test('Welfare Officer is strictly blocked from raw clinical therapy notes and unconsented identities', () {
      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.welfareOfficer,
          resource: ResourceType.rawClinicalNotesForWelfareOfficer,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.welfareOfficer,
          resource: ResourceType.clinicalTherapyNotes,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.welfareOfficer,
          resource: ResourceType.unconsentedRealIdentityForWelfareOfficer,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );
    });

    test('Individual Officer is strictly blocked from command unit aggregates and other officers data', () {
      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.officer,
          resource: ResourceType.commanderUnitAggregates,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.officer,
          resource: ResourceType.officerOwnData,
          requesterOfficerId: 'officer-alpha',
          targetOfficerId: 'officer-bravo', // Mismatched target officer
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );
    });

    test('Counsellor is blocked from command operational rosters and unit administrative strategy', () {
      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.counsellor,
          resource: ResourceType.commanderRosterRecommendations,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.counsellor,
          resource: ResourceType.commanderUnitAggregates,
        ),
        throwsA(isA<ForbiddenAccessException>()),
      );
    });

    test('Authorized accesses pass without exception', () {
      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.officer,
          resource: ResourceType.officerOwnData,
          requesterOfficerId: 'officer-alpha',
          targetOfficerId: 'officer-alpha',
        ),
        returnsNormally,
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.welfareOfficer,
          resource: ResourceType.welfarePseudonymisedTiers,
        ),
        returnsNormally,
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.counsellor,
          resource: ResourceType.clinicalAssessmentDetail,
        ),
        returnsNormally,
      );

      expect(
        () => RbacGuard.assertAccess(
          role: UserRole.commander,
          resource: ResourceType.commanderUnitAggregates,
        ),
        returnsNormally,
      );
    });

    test('Minimum group size (k >= 10) is strictly enforced for unit aggregate reporting', () {
      expect(RbacGuard.isCohortSizeSuppressed(6), isTrue);
      expect(RbacGuard.isCohortSizeSuppressed(9), isTrue);
      expect(RbacGuard.isCohortSizeSuppressed(10), isFalse);
      expect(RbacGuard.isCohortSizeSuppressed(84), isFalse);

      expect(
        () => RbacGuard.assertAggregateGroupSize(8, unitName: 'Small Recon Section'),
        throwsArgumentError,
      );

      expect(
        () => RbacGuard.assertAggregateGroupSize(12, unitName: 'Company Platoon'),
        returnsNormally,
      );
    });

    test('Audited break-glass recording creates immutable record and rejects short justifications', () {
      expect(
        () => RbacGuard.recordBreakGlass(
          requesterId: 'counsellor-001',
          requesterRole: UserRole.counsellor,
          targetOfficerId: 'officer-001',
          reasonCode: 'imminent_danger',
          clinicalJustification: 'Short', // Less than 15 chars
        ),
        throwsArgumentError,
      );

      final event = RbacGuard.recordBreakGlass(
        requesterId: 'counsellor-001',
        requesterRole: UserRole.counsellor,
        targetOfficerId: 'officer-001',
        reasonCode: 'imminent_danger',
        clinicalJustification: 'Officer actively exhibiting severe suicidal intent requiring medical evacuation.',
      );

      expect(event.id, startsWith('bg-'));
      expect(event.requesterId, equals('counsellor-001'));
      expect(event.requesterRole, equals(UserRole.counsellor));
      expect(event.isReviewed, isFalse);
      expect(RbacGuard.breakGlassLog.contains(event), isTrue);
    });
  });
}
