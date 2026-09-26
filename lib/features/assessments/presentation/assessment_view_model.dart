// lib/features/assessments/presentation/assessment_view_model.dart
// State machine for adaptive clinical questionnaires with crisis safety intercept

import 'package:flutter/foundation.dart';
import '../data/assessment_repository.dart';
import '../domain/assessment_model.dart';

enum AssessmentWizardStep { instrumentSelection, questionnaire, results, crisisIntercept, submitting, error }

class AssessmentViewModel extends ChangeNotifier {
  final IAssessmentRepository repository;
  final String officerId;

  AssessmentWizardStep _step = AssessmentWizardStep.instrumentSelection;
  String _selectedInstrument = 'phq9'; // 'phq9', 'gad7'
  int _currentQuestionIndex = 0;
  final Map<String, int> _answers = {};
  AssessmentModel? _completedAssessment;
  bool _isCrisisTriggered = false;
  String? _errorMessage;

  AssessmentViewModel({
    required this.repository,
    required this.officerId,
  });

  AssessmentWizardStep get step => _step;
  String get selectedInstrument => _selectedInstrument;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, int> get answers => _answers;
  AssessmentModel? get completedAssessment => _completedAssessment;
  bool get isCrisisTriggered => _isCrisisTriggered;
  String? get errorMessage => _errorMessage;

  List<AssessmentQuestion> get currentQuestions {
    return _selectedInstrument == 'phq9'
        ? AssessmentModel.phq9Questions
        : AssessmentModel.gad7Questions;
  }

  AssessmentQuestion get currentQuestion => currentQuestions[_currentQuestionIndex];
  double get progress => (_currentQuestionIndex + 1) / currentQuestions.length;

  void startAssessment(String instrument) {
    _selectedInstrument = instrument;
    _currentQuestionIndex = 0;
    _answers.clear();
    _isCrisisTriggered = false;
    _completedAssessment = null;
    _step = AssessmentWizardStep.questionnaire;
    notifyListeners();
  }

  void answerQuestion(int score) {
    final q = currentQuestion;
    _answers[q.identifier] = score;

    // PHQ-9 Item 9 safety trigger check
    if (q.isCrisisIndicator && score > 0) {
      _isCrisisTriggered = true;
      _step = AssessmentWizardStep.crisisIntercept;
      notifyListeners();
      return;
    }

    if (_currentQuestionIndex < currentQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      _finishAndSubmit();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  Future<void> _finishAndSubmit() async {
    _step = AssessmentWizardStep.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final AssessmentModel scored;
      if (_selectedInstrument == 'phq9') {
        scored = AssessmentModel.scorePhq9(
          officerId: officerId,
          triggerReason: 'quarterly_routine',
          answers: _answers,
        );
      } else {
        scored = AssessmentModel.scoreGad7(
          officerId: officerId,
          triggerReason: 'quarterly_routine',
          answers: _answers,
        );
      }

      _completedAssessment = await repository.submitAssessment(scored);
      _step = AssessmentWizardStep.results;
    } catch (e) {
      _errorMessage = e.toString();
      _step = AssessmentWizardStep.error;
    }

    notifyListeners();
  }

  void reset() {
    _step = AssessmentWizardStep.instrumentSelection;
    _answers.clear();
    _currentQuestionIndex = 0;
    _isCrisisTriggered = false;
    _completedAssessment = null;
    notifyListeners();
  }
}
