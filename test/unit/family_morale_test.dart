// test/unit/family_morale_test.dart
// Unit tests for Family Support, Granular Consent, OPSEC Filter, and Morale Vault (Phase 10)

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/family/data/family_repository.dart';
import 'package:raksha_welfare/features/family/domain/family_consent.dart';
import 'package:raksha_welfare/features/family/domain/morale_vault_item.dart';
import 'package:raksha_welfare/features/family/domain/opsec_filter.dart';
import 'package:raksha_welfare/features/family/presentation/family_view_model.dart';

void main() {
  const testOfficerId = 'mock-officer-uuid-001';

  group('Phase 10 — Family Support & Morale Vault Unit Tests', () {
    test('FamilyMember invitation and default consent initialization', () async {
      final repository = FamilyRepository();

      final member = await repository.inviteFamilyMember(
        officerId: testOfficerId,
        relation: 'sibling',
        firstName: 'Priya',
        lastName: 'Singh',
        phone: '+91 98765 00000',
      );

      expect(member.officerId, equals(testOfficerId));
      expect(member.relation, equals('sibling'));
      expect(member.relationDisplay, equals('Sibling'));
      expect(member.isVerified, isTrue);

      final consent = await repository.getFamilyConsent(
        officerId: testOfficerId,
        familyMemberId: member.id,
      );

      expect(consent.officerId, equals(testOfficerId));
      expect(consent.familyMemberId, equals(member.id));
      expect(consent.isRevoked, isFalse);
      expect(consent.shareMoraleMessages, isTrue);
    });

    test('Granular consent revocation immediately blocks communication', () async {
      final repository = FamilyRepository();
      final consent = await repository.getFamilyConsent(
        officerId: testOfficerId,
        familyMemberId: 'fam-member-001',
      );

      expect(consent.isRevoked, isFalse);

      // Revoke consent
      await repository.revokeFamilyConsent(
        officerId: testOfficerId,
        familyMemberId: 'fam-member-001',
      );

      final revoked = await repository.getFamilyConsent(
        officerId: testOfficerId,
        familyMemberId: 'fam-member-001',
      );

      expect(revoked.isRevoked, isTrue);
      expect(revoked.revokedAt, isNotNull);
      expect(() => revoked.assertActiveConsent(), throwsStateError);

      // Verify that call-home prompt is blocked immediately
      final insideWindowTime = DateTime(2026, 9, 25, 19, 30); // 7:30 PM (inside 18-22 window)
      final success = await repository.sendCallHomePrompt(
        officerId: testOfficerId,
        familyMemberId: 'fam-member-001',
        timestamp: insideWindowTime,
      );

      expect(success, isFalse);
    });

    test('Notification window prevents duty schedule leakage during quiet hours', () {
      final consent = FamilyConsent(
        id: 'test-consent',
        officerId: testOfficerId,
        familyMemberId: 'fam-001',
        notificationWindowStartHour: 18, // 6:00 PM
        notificationWindowEndHour: 22, // 10:00 PM
        isRevoked: false,
        grantedAt: DateTime.now(),
      );

      // During active duty hours (e.g. 14:00 / 2:00 PM) -> strictly blocked
      final dutyHour = DateTime(2026, 9, 25, 14, 0);
      expect(consent.isNotificationAllowedAt(dutyHour), isFalse);

      // During late night operational watch (e.g. 02:00 AM) -> strictly blocked
      final midnightHour = DateTime(2026, 9, 25, 2, 30);
      expect(consent.isNotificationAllowedAt(midnightHour), isFalse);

      // Inside permissible evening rest window (e.g. 19:30 / 7:30 PM) -> allowed
      final restWindowHour = DateTime(2026, 9, 25, 19, 30);
      expect(consent.isNotificationAllowedAt(restWindowHour), isTrue);
    });

    test('OpsecFilter passes benign family messages and flags tactical breaches', () {
      // 1. Clean heartfelt message
      const cleanMessage = 'Hi Papa, we are all doing great at home. Sending lots of prayers for your health!';
      final cleanResult = OpsecFilter.scan(text: cleanMessage);

      expect(cleanResult.isSafe, isTrue);
      expect(cleanResult.detectedFlags, isEmpty);
      expect(cleanResult.riskScore, equals(0.0));
      expect(cleanResult.recommendedStatus, equals(MoraleMediaSecurityStatus.safe));

      // 2. Tactical & location leak message
      const tacticalMessage = 'Heard your convoy is moving for a night ambush patrol near sector 4 tomorrow.';
      final tacticalResult = OpsecFilter.scan(text: tacticalMessage);

      expect(tacticalResult.isSafe, isFalse);
      expect(tacticalResult.detectedFlags.length, greaterThanOrEqualTo(3));
      expect(tacticalResult.detectedFlags.any((f) => f.contains('convoy')), isTrue);
      expect(tacticalResult.detectedFlags.any((f) => f.contains('patrol')), isTrue);
      expect(tacticalResult.detectedFlags.any((f) => f.contains('sector 4')), isTrue);
      expect(tacticalResult.riskScore, greaterThan(0.5));
      expect(tacticalResult.recommendedStatus, equals(MoraleMediaSecurityStatus.autoFlagged));

      // 3. GPS coordinate leak
      const gpsMessage = 'Family sent a gift parcel to coordinates 34° 15 N at the forward picket';
      final gpsResult = OpsecFilter.scan(text: gpsMessage);

      expect(gpsResult.isSafe, isFalse);
      expect(gpsResult.detectedFlags.any((f) => f.contains('location_leak: forward picket')), isTrue);
      expect(gpsResult.detectedFlags.any((f) => f.contains('gps_coordinates_detected')), isTrue);
    });

    test('Morale Vault strictly quarantines flagged media from officer until approved', () async {
      final repository = FamilyRepository();

      // Upload a suspicious message
      final flaggedItem = await repository.uploadMoraleMedia(
        officerId: testOfficerId,
        familyMemberId: 'fam-member-001',
        familyMemberName: 'Ananya',
        mediaType: 'audio',
        mediaUrl: 'https://cloudinary.example.com/audio/suspect_1.mp3',
        transcriptOrCaption: 'Stay safe on the ammunition dump sentry watch tonight.',
      );

      expect(flaggedItem.securityStatus, equals(MoraleMediaSecurityStatus.autoFlagged));
      expect(flaggedItem.isAvailableToOfficer, isFalse);

      // Officer views Morale Vault (includeQuarantined: false)
      final officerItems = await repository.getMoraleVaultItems(testOfficerId, includeQuarantined: false);
      expect(officerItems.any((item) => item.id == flaggedItem.id), isFalse);

      // Human security review clears the item
      await repository.reviewQuarantinedMedia(
        mediaId: flaggedItem.id,
        decision: MoraleMediaSecurityStatus.humanApproved,
        reviewerId: 'security-reviewer-01',
        notes: 'Reviewed audio: No classified coordinates heard; cleared for delivery.',
      );

      // Officer views Morale Vault again -> now accessible!
      final updatedOfficerItems = await repository.getMoraleVaultItems(testOfficerId, includeQuarantined: false);
      expect(updatedOfficerItems.any((item) => item.id == flaggedItem.id), isTrue);
    });

    test('FamilyViewModel loads modules, uploads media, and handles call-home triggers', () async {
      final repository = FamilyRepository();
      final vm = FamilyViewModel(repository: repository, officerId: testOfficerId);

      await vm.loadAll();
      expect(vm.isLoading, isFalse);
      expect(vm.familyMembers.isNotEmpty, isTrue);
      expect(vm.moraleItems.isNotEmpty, isTrue);
      expect(vm.trainingModules.length, greaterThanOrEqualTo(3));

      // Upload clean media
      final uploaded = await vm.uploadMedia(
        mediaType: 'audio',
        mediaUrl: 'https://cloudinary.example.com/audio/test_cheer.mp3',
        caption: 'Good luck with the sports competition!',
      );

      expect(uploaded, isNotNull);
      expect(uploaded!.isAvailableToOfficer, isTrue);

      // Trigger call-home prompt during permissible window (7:00 PM)
      final success = await vm.triggerCallHomePrompt(
        simulatedTime: DateTime(2026, 9, 25, 19, 0),
      );
      expect(success, isTrue);
      expect(vm.callHomeStatusMessage, contains('Call-Home reminder sent'));

      // Trigger call-home prompt outside window (3:00 PM)
      final outsideSuccess = await vm.triggerCallHomePrompt(
        simulatedTime: DateTime(2026, 9, 25, 15, 0),
      );
      expect(outsideSuccess, isFalse);
      expect(vm.callHomeStatusMessage, contains('Outside designated quiet hours'));
    });
  });
}
