// lib/features/performance/domain/encouraging_feedback_engine.dart
// Encouraging coaching feedback engine with approved templates, output filters, and sensitive-topic routing

import 'performance_record.dart';

class MedicalAdviceProhibitedException implements Exception {
  final String message;
  const MedicalAdviceProhibitedException(this.message);

  @override
  String toString() => 'MedicalAdviceProhibitedException: $message';
}

class SensitiveTopicRoutingResult {
  final bool requiresEmergencyRouting;
  final String? redirectPath;
  final String? emergencyHotline;
  final String? rationale;

  const SensitiveTopicRoutingResult({
    required this.requiresEmergencyRouting,
    this.redirectPath,
    this.emergencyHotline,
    this.rationale,
  });

  static const safe = SensitiveTopicRoutingResult(requiresEmergencyRouting: false);
}

class FeedbackGenerationLog {
  final String id;
  final String officerId;
  final String promptTemplate;
  final String generatedFeedback;
  final bool passedMedicalFilter;
  final DateTime timestamp;

  const FeedbackGenerationLog({
    required this.id,
    required this.officerId,
    required this.promptTemplate,
    required this.generatedFeedback,
    required this.passedMedicalFilter,
    required this.timestamp,
  });
}

class EncouragingFeedbackEngine {
  static const Set<String> _medicalProhibitedTerms = {
    'diagnose',
    'diagnosis',
    'diagnostic',
    'disorder',
    'pathology',
    'syndrome',
    'medication',
    'medicate',
    'prescribe',
    'prescription',
    'antidepressant',
    'anxiolytic',
    'sedative',
    'psychiatric treatment',
    'clinical psychotherapy',
    'bipolar',
    'schizophrenia',
  };

  static const List<String> _sensitiveCrisisTriggers = [
    'kill myself',
    'suicide',
    'end my life',
    'self-harm',
    'overdose',
    'cannot go on',
    'no reason to live',
    'hopeless',
  ];

  /// Asserts that generated output contains absolutely zero clinical diagnostic or medical advice
  static void assertNoMedicalAdvice(String output) {
    final lower = output.toLowerCase();
    for (final term in _medicalProhibitedTerms) {
      final regex = RegExp(r'\b' + RegExp.escape(term) + r'\b', caseSensitive: false);
      if (regex.hasMatch(lower)) {
        throw MedicalAdviceProhibitedException(
          'Output Filter Blocked: Feedback contains prohibited clinical/medical advice term "$term". '
          'AI assistance must be strictly non-clinical, encouraging, and focused solely on operational performance.',
        );
      }
    }
  }

  /// Scans input text for sensitive crisis or distress indicators and routes away from LLM to human responders
  static SensitiveTopicRoutingResult checkSensitiveTopicRouting(String input) {
    final lower = input.toLowerCase();
    for (final trigger in _sensitiveCrisisTriggers) {
      if (lower.contains(trigger)) {
        return const SensitiveTopicRoutingResult(
          requiresEmergencyRouting: true,
          redirectPath: '/crisis',
          emergencyHotline: '14416 (Tele-MANAS)',
          rationale: 'Sensitive topic detected. AI assistance suspended; immediate routing to human crisis responders.',
        );
      }
    }
    return SensitiveTopicRoutingResult.safe;
  }

  /// Generates encouraging coaching feedback using vetted military developmental templates
  static String generateFeedbackFromRecord(PerformanceRecord record) {
    final entries = record.evaluatedAreas.entries.toList();
    if (entries.isEmpty) {
      return 'Consistent operational readiness demonstrated. Continue adhering to established training routines and unit standards.';
    }

    // Sort to find top strength and growth area
    entries.sort((a, b) => b.value.compareTo(a.value));
    final topArea = entries.first;
    final growthArea = entries.last;

    String feedback;
    if (record.overallPerformanceScore >= 85.0) {
      feedback = 'Commendable operational execution demonstrated in ${topArea.key} (${topArea.value.toStringAsFixed(0)}%). '
          'Continuing to refine ${growthArea.key} through structured pacing and routine buddy drills will sustain peak readiness.';
    } else if (record.overallPerformanceScore >= 70.0) {
      feedback = 'Solid, dependable progress maintained across evaluated competencies (${record.overallPerformanceScore.toStringAsFixed(1)}% overall). '
          'Target incremental focus on ${growthArea.key} to build elevated tactical confidence alongside strong performance in ${topArea.key}.';
    } else {
      feedback = 'Steady participation and operational discipline observed. '
          'Prioritizing collaborative practice in ${growthArea.key} with squad peers will steadily advance individual endurance and skills.';
    }

    // Enforce safety filter
    assertNoMedicalAdvice(feedback);
    return feedback;
  }
}
