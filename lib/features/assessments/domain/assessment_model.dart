// lib/features/assessments/domain/assessment_model.dart
// Clinical assessment instruments (PHQ-9, GAD-7, PCL-5) with safety and scoring rules

class AssessmentQuestion {
  final String identifier;
  final String text;
  final int minScore;
  final int maxScore;
  final List<String> optionLabels;
  final bool isCrisisIndicator;

  const AssessmentQuestion({
    required this.identifier,
    required this.text,
    this.minScore = 0,
    this.maxScore = 3,
    required this.optionLabels,
    this.isCrisisIndicator = false,
  });
}

class AssessmentResponseItem {
  final String questionIdentifier;
  final String questionText;
  final int responseValue;
  final String responseText;

  const AssessmentResponseItem({
    required this.questionIdentifier,
    required this.questionText,
    required this.responseValue,
    required this.responseText,
  });

  Map<String, dynamic> toMap() {
    return {
      'question_identifier': questionIdentifier,
      'question_text': questionText,
      'response_value': responseValue,
      'response_text': responseText,
    };
  }
}

class AssessmentModel {
  final String? id;
  final String officerId;
  final String assessmentType; // 'phq9', 'gad7', 'pcl5', 'dass21', 'cssrs'
  final String triggerReason; // 'quarterly_routine', 'elevated_risk_trigger', 'clinician_initiated'
  final double totalScore;
  final String severityTier; // 'normal', 'mild', 'moderate', 'severe', 'crisis'
  final int phq9Item9Score;
  final bool isCrisisFlagged;
  final List<AssessmentResponseItem> responses;
  final DateTime completedAt;

  const AssessmentModel({
    this.id,
    required this.officerId,
    required this.assessmentType,
    required this.triggerReason,
    required this.totalScore,
    required this.severityTier,
    this.phq9Item9Score = 0,
    this.isCrisisFlagged = false,
    this.responses = const [],
    required this.completedAt,
  });

  Map<String, dynamic> toDbPayload() {
    return {
      'officer_id': officerId,
      'assessment_type': assessmentType,
      'trigger_reason': triggerReason,
      'total_score': totalScore,
      'severity_tier': severityTier,
      'phq9_item9_score': phq9Item9Score,
      'is_crisis_flagged': isCrisisFlagged,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory AssessmentModel.fromMap(Map<String, dynamic> map, [List<AssessmentResponseItem> responses = const []]) {
    return AssessmentModel(
      id: map['id'] as String?,
      officerId: map['officer_id'] as String,
      assessmentType: map['assessment_type'] as String,
      triggerReason: map['trigger_reason'] as String? ?? 'quarterly_routine',
      totalScore: (map['total_score'] as num).toDouble(),
      severityTier: map['severity_tier'] as String,
      phq9Item9Score: (map['phq9_item9_score'] as num?)?.toInt() ?? 0,
      isCrisisFlagged: map['is_crisis_flagged'] as bool? ?? false,
      responses: responses,
      completedAt: DateTime.tryParse(map['completed_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Factory helper to build and score PHQ-9
  static AssessmentModel scorePhq9({
    required String officerId,
    required String triggerReason,
    required Map<String, int> answers,
  }) {
    int sum = 0;
    int item9 = answers['PHQ9_Q9'] ?? 0;
    final responseList = <AssessmentResponseItem>[];

    for (final q in phq9Questions) {
      final val = answers[q.identifier] ?? 0;
      sum += val;
      responseList.add(AssessmentResponseItem(
        questionIdentifier: q.identifier,
        questionText: q.text,
        responseValue: val,
        responseText: q.optionLabels[val.clamp(0, q.optionLabels.length - 1)],
      ));
    }

    final isCrisis = item9 > 0;
    String tier = 'normal';
    if (isCrisis) {
      tier = 'crisis';
    } else if (sum >= 20) {
      tier = 'severe';
    } else if (sum >= 15) {
      tier = 'severe';
    } else if (sum >= 10) {
      tier = 'moderate';
    } else if (sum >= 5) {
      tier = 'mild';
    }

    return AssessmentModel(
      officerId: officerId,
      assessmentType: 'phq9',
      triggerReason: triggerReason,
      totalScore: sum.toDouble(),
      severityTier: tier,
      phq9Item9Score: item9,
      isCrisisFlagged: isCrisis,
      responses: responseList,
      completedAt: DateTime.now(),
    );
  }

  /// Factory helper to build and score GAD-7
  static AssessmentModel scoreGad7({
    required String officerId,
    required String triggerReason,
    required Map<String, int> answers,
  }) {
    int sum = 0;
    final responseList = <AssessmentResponseItem>[];

    for (final q in gad7Questions) {
      final val = answers[q.identifier] ?? 0;
      sum += val;
      responseList.add(AssessmentResponseItem(
        questionIdentifier: q.identifier,
        questionText: q.text,
        responseValue: val,
        responseText: q.optionLabels[val.clamp(0, q.optionLabels.length - 1)],
      ));
    }

    String tier = 'normal';
    if (sum >= 15) {
      tier = 'severe';
    } else if (sum >= 10) {
      tier = 'moderate';
    } else if (sum >= 5) {
      tier = 'mild';
    }

    return AssessmentModel(
      officerId: officerId,
      assessmentType: 'gad7',
      triggerReason: triggerReason,
      totalScore: sum.toDouble(),
      severityTier: tier,
      phq9Item9Score: 0,
      isCrisisFlagged: false,
      responses: responseList,
      completedAt: DateTime.now(),
    );
  }

  static const List<String> standardOptions = [
    'Not at all (0)',
    'Several days (1)',
    'More than half the days (2)',
    'Nearly every day (3)',
  ];

  static const List<AssessmentQuestion> phq9Questions = [
    AssessmentQuestion(
      identifier: 'PHQ9_Q1',
      text: 'Little interest or pleasure in doing things',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'PHQ9_Q2',
      text: 'Feeling down, depressed, or hopeless',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'PHQ9_Q3',
      text: 'Trouble falling or staying asleep, or sleeping too much',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'PHQ9_Q4',
      text: 'Feeling tired or having little energy',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'PHQ9_Q5',
      text: 'Poor appetite or overeating',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'PHQ9_Q6',
      text: 'Feeling bad about yourself — or that you are a failure or have let yourself or your family down',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'PHQ9_Q7',
      text: 'Trouble concentrating on things, such as reading or mission briefings',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'PHQ9_Q8',
      text: 'Moving or speaking so slowly that other people could have noticed, or being fidgety and restless',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'PHQ9_Q9',
      text: 'Thoughts that you would be better off dead, or of hurting yourself in some way',
      optionLabels: standardOptions,
      isCrisisIndicator: true,
    ),
  ];

  static const List<AssessmentQuestion> gad7Questions = [
    AssessmentQuestion(
      identifier: 'GAD7_Q1',
      text: 'Feeling nervous, anxious, or on edge',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'GAD7_Q2',
      text: 'Not being able to stop or control worrying',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'GAD7_Q3',
      text: 'Worrying too much about different things',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'GAD7_Q4',
      text: 'Trouble relaxing',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'GAD7_Q5',
      text: 'Being so restless that it is hard to sit still',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'GAD7_Q6',
      text: 'Becoming easily annoyed or irritable',
      optionLabels: standardOptions,
    ),
    AssessmentQuestion(
      identifier: 'GAD7_Q7',
      text: 'Feeling afraid, as if something awful might happen',
      optionLabels: standardOptions,
    ),
  ];
}
