// test/unit/performance_acr_firewall_test.dart
// Unit tests for Phase 13: Performance Records, Welfare-HR ACR Firewall, and Encouraging Coaching Feedback

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/performance/data/performance_repository.dart';
import 'package:raksha_welfare/features/performance/domain/acr_context_note.dart';
import 'package:raksha_welfare/features/performance/domain/acr_firewall_validator.dart';
import 'package:raksha_welfare/features/performance/domain/encouraging_feedback_engine.dart';
import 'package:raksha_welfare/features/performance/domain/performance_record.dart';

void main() {
  group('Phase 13: AcrFirewallValidator (Welfare-HR Firewall)', () {
    test('Blocks stress, anxiety, depression and psychometrics from entering ACR context', () {
      expect(
        () => AcrFirewallValidator.assertNoStressInAcrContext('Officer experienced severe stress during winter watch.'),
        throwsA(isA<AcrFirewallViolationException>()),
      );
      expect(
        () => AcrFirewallValidator.assertNoStressInAcrContext('High anxiety and depression noted in quarterly review.'),
        throwsA(isA<AcrFirewallViolationException>()),
      );
      expect(
        () => AcrFirewallValidator.assertNoStressInAcrContext('PHQ-9 screening score of 12 recorded.'),
        throwsA(isA<AcrFirewallViolationException>()),
      );
      expect(
        () => AcrFirewallValidator.assertNoStressInAcrContext('C-SSRS screener showed mild risk.'),
        throwsA(isA<AcrFirewallViolationException>()),
      );
    });

    test('Blocks counselling, psychotherapy and clinical therapy terms from ACR context', () {
      expect(
        () => AcrFirewallValidator.assertNoStressInAcrContext('Referred for confidential counselling session.'),
        throwsA(isA<AcrFirewallViolationException>()),
      );
      expect(
        () => AcrFirewallValidator.assertNoStressInAcrContext('Consulted psychiatrist for insomnia and burnout.'),
        throwsA(isA<AcrFirewallViolationException>()),
      );
    });

    test('Allows strictly non-clinical operational and administrative context in ACR', () {
      expect(
        () => AcrFirewallValidator.assertNoStressInAcrContext(
          'Officer demonstrated exceptional radio communication discipline during high-altitude patrol. Punctual, diligent, and technically proficient.',
        ),
        returnsNormally,
      );
    });
  });

  group('Phase 13: EncouragingFeedbackEngine (AI Guardrails & Sensitive Routing)', () {
    test('Blocks clinical medical advice, diagnoses and prescriptions in LLM feedback', () {
      expect(
        () => EncouragingFeedbackEngine.assertNoMedicalAdvice('We diagnose an adjustment disorder and recommend medication.'),
        throwsA(isA<MedicalAdviceProhibitedException>()),
      );
      expect(
        () => EncouragingFeedbackEngine.assertNoMedicalAdvice('Consider an antidepressant prescription from a clinic.'),
        throwsA(isA<MedicalAdviceProhibitedException>()),
      );
    });

    test('Allows vetted non-clinical coaching feedback', () {
      expect(
        () => EncouragingFeedbackEngine.assertNoMedicalAdvice(
          'Commendable focus on weapon drill. Incremental aerobic tempo sessions will bolster ridge navigation.',
        ),
        returnsNormally,
      );
    });

    test('checkSensitiveTopicRouting detects crisis triggers and redirects to Tele-MANAS', () {
      final crisisCheck = EncouragingFeedbackEngine.checkSensitiveTopicRouting(
        'I cannot go on, thinking about suicide after prolonged field duty.',
      );
      expect(crisisCheck.requiresEmergencyRouting, isTrue);
      expect(crisisCheck.redirectPath, equals('/crisis'));
      expect(crisisCheck.emergencyHotline, contains('14416'));
    });

    test('checkSensitiveTopicRouting reports safe for operational queries', () {
      final safeCheck = EncouragingFeedbackEngine.checkSensitiveTopicRouting(
        'Looking for recommendations to increase sprint stamina.',
      );
      expect(safeCheck.requiresEmergencyRouting, isFalse);
    });

    test('generateFeedbackFromRecord generates constructive feedback from competencies', () {
      final record = PerformanceRecord(
        id: 'perf-test',
        officerId: 'off-1',
        periodStart: DateTime.now().subtract(const Duration(days: 30)),
        periodEnd: DateTime.now(),
        overallPerformanceScore: 88.0,
        evaluatedAreas: {
          'Weapon Drill': 95.0,
          'Sprint Endurance': 75.0,
        },
        improvementSuggestions: 'Focus on stamina pacing.',
        createdAt: DateTime.now(),
      );

      final feedback = EncouragingFeedbackEngine.generateFeedbackFromRecord(record);
      expect(feedback, contains('Weapon Drill'));
      expect(feedback, contains('Sprint Endurance'));
      expect(feedback, contains('readiness'));
    });
  });

  group('Phase 13: PerformanceRepository', () {
    late PerformanceRepository repository;

    setUp(() {
      repository = PerformanceRepository();
    });

    test('Loads pre-seeded operational performance records', () async {
      final records = await repository.getPerformanceRecords('mock-officer-uuid-001');
      expect(records.isNotEmpty, isTrue);
      expect(records.first.evaluatedAreas.containsKey('Weapon Handling & Drill'), isTrue);
    });

    test('Rejects creating ACR context note if stress/clinical terms are present', () async {
      final violatingNote = AcrContextNote(
        id: 'acr-violating',
        officerId: 'mock-officer-uuid-001',
        reportingPeriodYear: 2026,
        nonClinicalHrContext: 'Officer suffered acute stress and was referred to counselling.',
        createdAt: DateTime.now(),
      );

      expect(
        () => repository.createAcrContextNote(violatingNote),
        throwsA(isA<AcrFirewallViolationException>()),
      );
    });

    test('Successfully saves clean non-clinical ACR context note', () async {
      final cleanNote = AcrContextNote(
        id: 'acr-clean',
        officerId: 'mock-officer-uuid-001',
        reportingPeriodYear: 2026,
        nonClinicalHrContext: 'Commended for excellent technical maintenance of radar equipment during monsoon deployment.',
        createdAt: DateTime.now(),
      );

      final saved = await repository.createAcrContextNote(cleanNote);
      expect(saved.id, equals('acr-clean'));
      expect(saved.verifiedNoStressData, isTrue);

      final notes = await repository.getAcrContextNotes('mock-officer-uuid-001');
      expect(notes.any((n) => n.id == 'acr-clean'), isTrue);
    });

    test('Generates encouraging feedback and creates audit log', () async {
      final record = await repository.getLatestPerformance('mock-officer-uuid-001');
      expect(record, isNotNull);

      final feedback = await repository.getEncouragingFeedback(record!);
      expect(feedback, isNotEmpty);

      final logs = repository.getFeedbackLogs('mock-officer-uuid-001');
      expect(logs.isNotEmpty, isTrue);
      expect(logs.first.passedMedicalFilter, isTrue);
    });
  });
}
