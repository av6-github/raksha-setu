// lib/features/assessments/presentation/assessment_screen.dart
// Clinical assessment wizard with progress bar, adaptive questions, and safety intercept

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/welfare_banner.dart';
import 'assessment_view_model.dart';

class AssessmentScreen extends StatelessWidget {
  final AssessmentViewModel viewModel;

  const AssessmentScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final step = viewModel.step;

        return PopScope(
          canPop: step == AssessmentWizardStep.instrumentSelection || step == AssessmentWizardStep.results,
          child: Scaffold(
            appBar: AppBar(
              title: Text(_appBarTitle(step)),
              leading: (step == AssessmentWizardStep.questionnaire)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: viewModel.previousQuestion,
                    )
                  : null,
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildBody(context),
            ),
          ),
        );
      },
    );
  }

  String _appBarTitle(AssessmentWizardStep step) {
    switch (step) {
      case AssessmentWizardStep.instrumentSelection:
        return 'Standard Clinical Battery';
      case AssessmentWizardStep.questionnaire:
        return viewModel.selectedInstrument == 'phq9' ? 'PHQ-9 Assessment' : 'GAD-7 Assessment';
      case AssessmentWizardStep.crisisIntercept:
        return 'Immediate Support Handoff';
      case AssessmentWizardStep.results:
        return 'Assessment Results';
      default:
        return 'Clinical Assessment';
    }
  }

  Widget _buildBody(BuildContext context) {
    switch (viewModel.step) {
      case AssessmentWizardStep.instrumentSelection:
        return _InstrumentSelectionView(viewModel: viewModel);
      case AssessmentWizardStep.questionnaire:
        return _QuestionnaireView(viewModel: viewModel);
      case AssessmentWizardStep.crisisIntercept:
        return _CrisisInterceptView(onCrisisTap: () => context.push('/crisis'));
      case AssessmentWizardStep.submitting:
        return const Center(child: CircularProgressIndicator());
      case AssessmentWizardStep.results:
        return _ResultsView(viewModel: viewModel, onClose: () => context.pop());
      case AssessmentWizardStep.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(viewModel.errorMessage ?? 'Submission error'),
              const SizedBox(height: 16),
              FilledButton(onPressed: viewModel.reset, child: const Text('Retry')),
            ],
          ),
        );
    }
  }
}

class _InstrumentSelectionView extends StatelessWidget {
  final AssessmentViewModel viewModel;

  const _InstrumentSelectionView({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const WelfareBanner(),
        const SizedBox(height: 16),
        Text(
          'Validated Psychological Instruments',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'These standardised clinical inventories provide deeper insights than the biweekly check-in. '
          'Your scores remain strictly confidential under the Welfare-HR firewall.',
          style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        _batteryCard(
          context,
          icon: Icons.psychology,
          color: Colors.blue,
          title: 'PHQ-9 Depression Inventory',
          subtitle: '9 questions • Screens for emotional exhaustion and depression • ~3 minutes',
          onTap: () => viewModel.startAssessment('phq9'),
        ),
        const SizedBox(height: 16),

        _batteryCard(
          context,
          icon: Icons.shield,
          color: Colors.teal,
          title: 'GAD-7 Anxiety Scale',
          subtitle: '7 questions • Screens for persistent operational tension & anxiety • ~2 minutes',
          onTap: () => viewModel.startAssessment('gad7'),
        ),
      ],
    );
  }

  Widget _batteryCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle, style: const TextStyle(fontSize: 13)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _QuestionnaireView extends StatelessWidget {
  final AssessmentViewModel viewModel;

  const _QuestionnaireView({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final q = viewModel.currentQuestion;
    final total = viewModel.currentQuestions.length;
    final current = viewModel.currentQuestionIndex + 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Text(
                '${(viewModel.progress * 100).toInt()}% Complete',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: viewModel.progress),
          const SizedBox(height: 36),

          Text(
            'Over the last 2 weeks, how often have you been bothered by:',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Text(
            q.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
          ),
          if (q.isCrisisIndicator) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Safety-critical question. Answering positively immediately connects you with support.',
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),

          Expanded(
            child: ListView.separated(
              itemCount: q.optionLabels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),

              itemBuilder: (context, index) {
                return OutlinedButton(
                  onPressed: () => viewModel.answerQuestion(index),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    q.optionLabels[index],
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CrisisInterceptView extends StatelessWidget {
  final VoidCallback onCrisisTap;

  const _CrisisInterceptView({required this.onCrisisTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF7F1D1D),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.favorite_rounded, size: 72, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            'We hear you. You matter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Based on your response to this safety question, the questionnaire is paused. '
            'Your wellbeing is the absolute priority.\n\n'
            'Please connect directly with our 24x7 clinical support responder. '
            'No AI is involved in this flow. Your record remains confidential.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 36),
          FilledButton.icon(
            onPressed: onCrisisTap,
            icon: const Icon(Icons.phone_rounded, color: Color(0xFF7F1D1D)),
            label: const Text(
              'Connect to Immediate Support (14416)',
              style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Return to Home', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final AssessmentViewModel viewModel;
  final VoidCallback onClose;

  const _ResultsView({required this.viewModel, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final assessment = viewModel.completedAssessment;
    final theme = Theme.of(context);

    if (assessment == null) {
      return const Center(child: Text('No results recorded.'));
    }

    final isNormal = assessment.severityTier == 'normal';
    final tierColor = isNormal ? Colors.green : (assessment.severityTier == 'mild' ? Colors.blue : Colors.orange);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: tierColor.withValues(alpha: 0.15),
            child: Icon(
              isNormal ? Icons.verified : Icons.info,
              size: 40,
              color: tierColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${assessment.assessmentType.toUpperCase()} Complete',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Severity: ${assessment.severityTier.toUpperCase()}',
              style: TextStyle(fontWeight: FontWeight.bold, color: tierColor),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '${assessment.totalScore.toInt()}',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: tierColor),
                ),
                Text(
                  'Total Clinical Score',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const Divider(height: 32),
                Text(
                  _explanationForTier(assessment.assessmentType, assessment.severityTier),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const WelfareBanner(),
        const SizedBox(height: 24),

        FilledButton(
          onPressed: onClose,
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('Done', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  String _explanationForTier(String type, String tier) {
    if (tier == 'normal') {
      return 'Your responses indicate stable wellbeing within regular operational thresholds. Continue routine recovery practices.';
    } else if (tier == 'mild') {
      return 'Mild stress symptoms detected, likely correlated with recent deployment rhythm or sleep disruptions. Access the self-care modules or consult a peer supporter.';
    } else {
      return 'Elevated emotional fatigue identified. A confidential conversation with an assigned welfare officer or counsellor is available at your convenience.';
    }
  }
}
