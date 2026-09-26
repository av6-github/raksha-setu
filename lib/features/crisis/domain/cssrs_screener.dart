// lib/features/crisis/domain/cssrs_screener.dart
// Columbia-Suicide Severity Rating Scale (C-SSRS) clinical screener for human triage

class CssrsQuestion {
  final int number;
  final String text;
  final String clinicalRationale;

  const CssrsQuestion({
    required this.number,
    required this.text,
    required this.clinicalRationale,
  });
}

class CssrsScreener {
  static const List<CssrsQuestion> questions = [
    CssrsQuestion(
      number: 1,
      text: 'Have you wished you were dead or wished you could go to sleep and not wake up?',
      clinicalRationale: 'Passive suicidal ideation',
    ),
    CssrsQuestion(
      number: 2,
      text: 'Have you had any actual thoughts of killing yourself?',
      clinicalRationale: 'Active suicidal ideation without intent or method',
    ),
    CssrsQuestion(
      number: 3,
      text: 'Have you thought about how you might do this (method)?',
      clinicalRationale: 'Suicidal thoughts with methods',
    ),
    CssrsQuestion(
      number: 4,
      text: 'Have you had these thoughts and had some intention of acting on them?',
      clinicalRationale: 'Suicidal intent without specific plan',
    ),
    CssrsQuestion(
      number: 5,
      text: 'Have you worked out details of a plan and intend to carry it out?',
      clinicalRationale: 'Suicidal intent with specific plan (imminent risk)',
    ),
    CssrsQuestion(
      number: 6,
      text: 'Have you ever done anything, begun to do anything, or prepared to end your life?',
      clinicalRationale: 'Preparatory suicidal behavior (lifetime or recent past)',
    ),
  ];

  /// Evaluates C-SSRS response map and returns clinical severity triage tier:
  /// - 'imminent': Q4, Q5, or Q6 is affirmative (requires immediate human intervention)
  /// - 'high': Q3 is affirmative (requires same-day clinical review)
  /// - 'moderate': Q1 or Q2 is affirmative (requires 24h counsellor contact)
  /// - 'low': all negative
  static String evaluateSeverity(Map<int, bool> answers) {
    if (answers[5] == true || answers[4] == true || answers[6] == true) {
      return 'imminent';
    }
    if (answers[3] == true) {
      return 'high';
    }
    if (answers[1] == true || answers[2] == true) {
      return 'moderate';
    }
    return 'low';
  }
}
