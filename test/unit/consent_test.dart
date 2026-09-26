import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/consent/data/consent_repository.dart';
import 'package:raksha_welfare/features/consent/presentation/consent_view_model.dart';


void main() {
  group('Phase 2 — Consent & Trust Unit Tests', () {
    late ConsentRepository repository;
    late ConsentViewModel viewModel;
    const testOfficerId = 'test-officer-999';

    setUp(() {
      repository = ConsentRepository(client: null);
      viewModel = ConsentViewModel(
        repository: repository,
        officerId: testOfficerId,
      );
    });

    test('Loads initial core consents and family consents', () async {
      await viewModel.loadConsents();

      expect(viewModel.consents.length, 4);
      expect(viewModel.consents.any((c) => c.consentType == 'biometrics'), isTrue);
      expect(viewModel.consents.any((c) => c.consentType == 'family_sharing'), isTrue);
      expect(viewModel.familyConsents.length, 1);
      expect(viewModel.familyConsents.first.familyMemberName, 'Ananya Singh');
    });

    test('Consent modification — Grants biometrics consent', () async {
      await viewModel.loadConsents();

      final initial = viewModel.consents.firstWhere((c) => c.consentType == 'biometrics');
      expect(initial.isGranted, isFalse);

      await viewModel.toggleConsent('biometrics', true);

      final updated = viewModel.consents.firstWhere((c) => c.consentType == 'biometrics');
      expect(updated.isGranted, isTrue);
      expect(updated.revokedAt, isNull);
    });

    test('Consent revocation — Revoking immediately sets isGranted to false and records timestamp', () async {
      await viewModel.loadConsents();

      // First grant
      await viewModel.toggleConsent('biometrics', true);
      expect(viewModel.consents.firstWhere((c) => c.consentType == 'biometrics').isGranted, isTrue);

      // Now revoke
      await viewModel.revokeConsent('biometrics');

      final revoked = viewModel.consents.firstWhere((c) => c.consentType == 'biometrics');
      expect(revoked.isGranted, isFalse);
      expect(revoked.revokedAt, isNotNull);
    });

    test('Granular family consent — modifies flash notifications and notification window', () async {
      await viewModel.loadConsents();

      final fcId = viewModel.familyConsents.first.id;
      expect(viewModel.familyConsents.first.shareFlashNotifications, isTrue);

      // Toggle off flash notifications
      await viewModel.toggleFamilyFlashNotifications(fcId, false);
      expect(viewModel.familyConsents.first.shareFlashNotifications, isFalse);

      // Update quiet hours notification window
      await viewModel.updateNotificationWindow(fcId, '10:00', '19:00');
      expect(viewModel.familyConsents.first.notificationWindowStart, '10:00');
      expect(viewModel.familyConsents.first.notificationWindowEnd, '19:00');
    });
  });
}
