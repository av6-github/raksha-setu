// test/unit/governance_security_test.dart
// Unit tests for Phase 16: Field-Level AES-256, TLS 1.3, Tenant Isolation, Differential Privacy, and Governance

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/security/field_encryption_service.dart';
import 'package:raksha_welfare/features/trust/data/governance_repository.dart';
import 'package:raksha_welfare/features/trust/domain/differential_privacy_engine.dart';
import 'package:raksha_welfare/features/trust/domain/governance_models.dart';

void main() {
  group('Phase 16: FieldEncryptionService & Cryptographic Controls', () {
    late FieldEncryptionService encryptionService;

    setUp(() {
      encryptionService = FieldEncryptionService();
    });

    test('Encrypts plaintext into AES-256 format and decrypts back to identical string', () {
      const sensitiveClinicalNote = 'Officer reported severe insomnia (PHQ-9 score 14). Prescribed sleep routine.';
      final encrypted = encryptionService.encryptField(sensitiveClinicalNote);

      expect(encrypted.startsWith('enc:v1:'), isTrue);
      expect(encrypted, isNot(equals(sensitiveClinicalNote)));

      final decrypted = encryptionService.decryptField(encrypted);
      expect(decrypted, equals(sensitiveClinicalNote));
    });

    test('Gracefully handles empty plaintext or legacy unencrypted strings', () {
      expect(encryptionService.encryptField(''), equals(''));
      expect(encryptionService.decryptField('legacy_plaintext_note'), equals('legacy_plaintext_note'));
    });

    test('assertTls13 enforces HTTPS transport and rejects insecure plaintext HTTP', () {
      expect(
        () => FieldEncryptionService.assertTls13('https://api.raksha.gov.in/v1/telemetry'),
        returnsNormally,
      );

      expect(
        () => FieldEncryptionService.assertTls13('http://insecure-api.raksha.gov.in/v1/telemetry'),
        throwsA(isA<SecurityPolicyException>()),
      );
    });
  });

  group('Phase 16: TenantIsolationGuard Multi-Force Separation', () {
    test('Permits access when user and resource belong to identical force', () {
      expect(
        () => TenantIsolationGuard.assertTenantAccess(
          userForce: 'CRPF',
          resourceForce: 'crpf',
          resourceId: 'unit-battalion-45',
        ),
        returnsNormally,
      );
    });

    test('Throws TenantIsolationException when accessing cross-force tenant resource', () {
      expect(
        () => TenantIsolationGuard.assertTenantAccess(
          userForce: 'crpf',
          resourceForce: 'bsf',
          resourceId: 'bsf-forward-post-09',
        ),
        throwsA(isA<TenantIsolationException>()),
      );
    });
  });

  group('Phase 16: DifferentialPrivacyEngine & Anonymity Controls', () {
    test('assertKAnonymity suppresses cohorts smaller than threshold 10', () {
      expect(
        () => DifferentialPrivacyEngine.assertKAnonymity(12),
        returnsNormally,
      );

      expect(
        () => DifferentialPrivacyEngine.assertKAnonymity(6),
        throwsA(isA<PrivacyPreservationException>()),
      );
    });

    test('assertNoIndividualStressRanking rejects sorting by clinical or risk keys', () {
      expect(
        () => DifferentialPrivacyEngine.assertNoIndividualStressRanking(['duty_hours', 'leave_balance']),
        returnsNormally,
      );

      expect(
        () => DifferentialPrivacyEngine.assertNoIndividualStressRanking(['rank', 'stress_score']),
        throwsA(isA<PrivacyPreservationException>()),
      );
    });

    test('addLaplaceNoise adds bounded mathematical noise to aggregate metrics', () {
      final fakeRng = Random(42);
      final noisyVal = DifferentialPrivacyEngine.addLaplaceNoise(
        trueValue: 6.5,
        minValue: 3.0,
        maxValue: 10.0,
        cohortSize: 20,
        epsilon: 1.0,
        rng: fakeRng,
      );

      expect(noisyVal, greaterThanOrEqualTo(3.0));
      expect(noisyVal, lessThanOrEqualTo(10.0));
      expect(noisyVal, isNot(equals(6.5)));
    });

    test('generateDifferentiallyPrivateSummary suppresses when cohort < 10 and applies DP when cohort >= 10', () {
      final suppressed = DifferentialPrivacyEngine.generateDifferentiallyPrivateSummary(
        unitName: 'Bravo Coy',
        cohortSize: 7,
        averageSleepHours: 6.2,
        averageWorkloadHours: 11.5,
        checkInCompletionRate: 0.90,
      );
      expect(suppressed['is_suppressed'], isTrue);
      expect(suppressed['dp_applied'], isFalse);

      final allowed = DifferentialPrivacyEngine.generateDifferentiallyPrivateSummary(
        unitName: 'Bravo Coy',
        cohortSize: 25,
        averageSleepHours: 6.2,
        averageWorkloadHours: 11.5,
        checkInCompletionRate: 0.90,
      );
      expect(allowed['is_suppressed'], isFalse);
      expect(allowed['dp_applied'], isTrue);
      expect(allowed.containsKey('average_sleep_hours'), isTrue);
    });
  });

  group('Phase 16: GovernanceRepository Workflow', () {
    late GovernanceRepository repo;

    setUp(() {
      repo = GovernanceRepository();
    });

    test('Fetches independent oversight reviews and bias audits', () async {
      final reviews = await repo.getOversightReviews();
      expect(reviews.length, greaterThanOrEqualTo(3));
      expect(reviews.any((r) => r.reviewType == OversightReviewType.ethicsBoard), isTrue);

      final bias = await repo.getBiasAudits();
      expect(bias.length, greaterThanOrEqualTo(3));
      for (final audit in bias) {
        expect(audit.isCompliant, isTrue);
        expect(audit.disparityMetric, greaterThanOrEqualTo(0.80)); // 4/5ths rule
      }
    });

    test('Fetches break-glass logs and records oversight adjudication', () async {
      final events = await repo.getBreakGlassEvents();
      expect(events.length, greaterThanOrEqualTo(2));

      final pending = events.firstWhere((e) => e.reviewStatus == BreakGlassStatus.pendingReview);
      await repo.reviewBreakGlassEvent(
        pending.id,
        BreakGlassStatus.validatedEmergency,
        'Oversight committee confirmed acute operational crisis warranted clinical access.',
      );

      final updated = await repo.getBreakGlassEvents();
      final target = updated.firstWhere((e) => e.id == pending.id);
      expect(target.reviewStatus, equals(BreakGlassStatus.validatedEmergency));
      expect(target.reviewerNotes, contains('acute operational crisis'));
    });

    test('Submits co-design feedback from troops', () async {
      final feedback = CoDesignFeedback(
        id: 'cd-test-01',
        officerRankDisplay: 'Sub-Inspector',
        unit: '72 Bn BSF',
        topic: 'Duty Sleep Rules',
        feedbackText: 'Ensure 6-hour continuous rest period is protected after night patrol.',
        actionStatus: 'under_review',
        submittedAt: DateTime.now(),
      );

      await repo.submitCoDesignFeedback(feedback);
      final list = await repo.getCoDesignFeedbacks();
      expect(list.any((f) => f.id == 'cd-test-01'), isTrue);
    });

    test('Shadow-mode pilot metrics satisfy clinical validation benchmark', () async {
      final shadow = await repo.getShadowPilotMetrics();
      expect(shadow.concordanceWithClinicians, greaterThanOrEqualTo(0.90));
      expect(shadow.brierScore, lessThan(0.10));
      expect(shadow.prAuc, greaterThanOrEqualTo(0.80));
      expect(shadow.goNoGoStatus, equals('PASSED_SHADOW_PILOT'));
    });

    test('Security compliance status reflects defense-grade guarantees', () async {
      final status = await repo.getSecurityComplianceStatus();
      expect(status['aes_256_at_rest'], isTrue);
      expect(status['tls_1_3_enforced'], isTrue);
      expect(status['field_level_encryption'], isTrue);
      expect(status['k_anonymity_threshold'], equals(10));
      expect(status['welfare_hr_firewall_status'], equals('ACTIVE_HARD_FIREWALL'));
    });
  });
}
