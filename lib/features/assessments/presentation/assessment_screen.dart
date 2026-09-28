// lib/features/assessments/presentation/assessment_screen.dart
// Clinical assessment wizard with progress bar, adaptive questions, and safety intercept
// Styled with Arctic Frost glassmorphism matching the biweekly check-in experience

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/rakshasetu_scaffold.dart';
import '../../../shared/widgets/welfare_banner.dart';
import '../../../shared/widgets/kinetic_dots_loader.dart';
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
          child: RakshaSetuScaffold(
            currentRoute: '/assessment',
            subtitle: _appBarSubtitle(step),
            showBackButton: true,
            onBack: (step == AssessmentWizardStep.questionnaire)
                ? () {
                    if (viewModel.currentQuestionIndex > 0) {
                      viewModel.previousQuestion();
                    } else {
                      viewModel.reset();
                    }
                  }
                : null,
            showFloatingDock: step == AssessmentWizardStep.instrumentSelection || step == AssessmentWizardStep.results,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _buildBody(context),
            ),
          ),
        );
      },
    );
  }

  String _appBarSubtitle(AssessmentWizardStep step) {
    switch (step) {
      case AssessmentWizardStep.instrumentSelection:
        return 'Standard Clinical Battery • Confidential';
      case AssessmentWizardStep.questionnaire:
        return viewModel.selectedInstrument == 'phq9'
            ? 'PHQ-9 Depression Inventory (Question ${viewModel.currentQuestionIndex + 1} of ${viewModel.currentQuestions.length})'
            : 'GAD-7 Anxiety Scale (Question ${viewModel.currentQuestionIndex + 1} of ${viewModel.currentQuestions.length})';
      case AssessmentWizardStep.crisisIntercept:
        return 'Immediate Human Support Intercept';
      case AssessmentWizardStep.results:
        return 'Confidential Assessment Results';
      default:
        return 'Psychological Health Assessment';
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
        return const Center(
          child: KineticDotsLoader(
            size: 20,
            label: 'Computing encrypted clinical scores...',
          ),
        );
      case AssessmentWizardStep.results:
        return _ResultsView(viewModel: viewModel, onClose: () => context.pop());
      case AssessmentWizardStep.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LiquidGlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: RakshaSetuColors.rose600, size: 44),
                  const SizedBox(height: 12),
                  const Text(
                    'Assessment Processing Error',
                    style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    viewModel.errorMessage ?? 'Submission error occurred. Stored in tamper-proof offline cache.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11.5, color: RakshaSetuColors.slate600),
                  ),
                  const SizedBox(height: 16),
                  ObsidianButton(
                    label: 'Retry Assessment',
                    onPressed: viewModel.reset,
                  ),
                ],
              ),
            ),
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Intro Glass Card
          LiquidGlassCard(
            borderRadius: 22,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xE6E0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_rounded, size: 30, color: RakshaSetuColors.azure),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Standard Clinical Battery',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: RakshaSetuColors.slate900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Standardised clinical inventories providing deeper baseline diagnostics than the biweekly check-in. Strictly confidential under the Welfare-HR firewall.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: RakshaSetuColors.slate600, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IntroBullet(text: 'Legally isolated from ACRs, postings, and promotion boards'),
                      SizedBox(height: 8),
                      _IntroBullet(text: 'Clinical gold standard: PHQ-9 & GAD-7 inventories'),
                      SizedBox(height: 8),
                      _IntroBullet(text: 'Instant confidential self-insight with severity tiering'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // PHQ-9 Card
          LiquidGlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            borderLeftColor: RakshaSetuColors.azure,
            borderLeftWidth: 3.5,
            onTap: () => viewModel.startAssessment('phq9'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xB3CFFAFE),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0x6606B6D4)),
                      ),
                      child: const Text(
                        '9 QUESTIONS • ~3 MINS • MOOD & DEPRESSION',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0E7490),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: RakshaSetuColors.azure),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'PHQ-9 Depression Inventory',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: RakshaSetuColors.slate900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Standardized screening for emotional exhaustion, anhedonia, low mood, and depressive symptoms over the last 14 days.',
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 12, height: 1.4, color: RakshaSetuColors.slate600),
                ),
                const SizedBox(height: 14),
                ObsidianButton(
                  label: 'Start PHQ-9 Inventory',
                  icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Color(0xFF67E8F9)),
                  onPressed: () => viewModel.startAssessment('phq9'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // GAD-7 Card
          LiquidGlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            borderLeftColor: const Color(0xFF0D9488), // teal
            borderLeftWidth: 3.5,
            onTap: () => viewModel.startAssessment('gad7'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xB3CCFBF1),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0x6614B8A6)),
                      ),
                      child: const Text(
                        '7 QUESTIONS • ~2 MINS • ANXIETY & TENSION',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F766E),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF0D9488)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'GAD-7 Anxiety Scale',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: RakshaSetuColors.slate900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Standardized measurement of persistent operational anxiety, acute tension, restlessness, and situational worry.',
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 12, height: 1.4, color: RakshaSetuColors.slate600),
                ),
                const SizedBox(height: 14),
                ObsidianButton(
                  label: 'Start GAD-7 Scale',
                  icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Color(0xFF67E8F9)),
                  onPressed: () => viewModel.startAssessment('gad7'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const WelfareBanner(),
        ],
      ),
    );
  }
}

class _IntroBullet extends StatelessWidget {
  final String text;
  const _IntroBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, size: 16, color: RakshaSetuColors.emerald500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, color: RakshaSetuColors.slate700, height: 1.3),
          ),
        ),
      ],
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step Counter & Progress Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question $current of $total',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: RakshaSetuColors.slate600,
                  ),
                ),
                Text(
                  '${(viewModel.progress * 100).toInt()}% Complete',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: RakshaSetuColors.azure,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: viewModel.progress,
              backgroundColor: const Color(0x3322D3EE),
              valueColor: const AlwaysStoppedAnimation<Color>(RakshaSetuColors.azure),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 14),

          // Question Card
          LiquidGlassCard(
            borderRadius: 22,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xB3CFFAFE),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: const Color(0x6606B6D4)),
                  ),
                  child: Text(
                    viewModel.selectedInstrument == 'phq9'
                        ? 'PHQ-9 CLINICAL INVENTORY'
                        : 'GAD-7 CLINICAL SCALE',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0E7490),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Over the last 2 weeks, how often have you been bothered by:',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: RakshaSetuColors.slate600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  q.text,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    color: RakshaSetuColors.slate900,
                  ),
                ),
                if (q.isCrisisIndicator) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0x1AF43F5E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x66F43F5E)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: RakshaSetuColors.rose600, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Safety-critical question. An affirmative response immediately connects you with support.',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: RakshaSetuColors.rose600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Option Cards
                ...List.generate(q.optionLabels.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => viewModel.answerQuestion(index),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x6622D3EE), width: 1.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A06B6D4),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                q.optionLabels[index],
                                style: const TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: RakshaSetuColors.slate900,
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0x660891B2), width: 1.5),
                              ),
                              child: const Center(
                                child: Icon(Icons.arrow_forward_ios_rounded, size: 10, color: RakshaSetuColors.azure),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),

                if (viewModel.currentQuestionIndex > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: viewModel.previousQuestion,
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: const Text(
                            'Previous Question',
                            style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0x660891B2)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                const Text(
                  'Confidential • Welfare-HR Firewall Protected • Zero ACR Leakage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 10,
                    color: RakshaSetuColors.slate500,
                  ),
                ),
              ],
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      child: LiquidGlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(22),
        borderLeftColor: const Color(0xFFDC2626),
        borderLeftWidth: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0x1AF43F5E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.health_and_safety_rounded, size: 36, color: Color(0xFFDC2626)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We hear you. You matter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Public Sans',
                color: RakshaSetuColors.slate900,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Based on your response to this safety question, the questionnaire is paused. Your wellbeing is our absolute priority.\n\nPlease connect directly with our 24x7 clinical support responder. Zero AI is involved in this flow. Your record remains strictly confidential.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Public Sans',
                color: RakshaSetuColors.slate700,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            ObsidianButton(
              label: 'Connect to Immediate Support (14416)',
              icon: const Icon(Icons.phone_in_talk_rounded, size: 18, color: Color(0xFF67E8F9)),
              onPressed: onCrisisTap,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x660891B2)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              ),
              child: const Text(
                'Return to Dashboard',
                style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700, color: RakshaSetuColors.slate700),
              ),
            ),
          ],
        ),
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

    if (assessment == null) {
      return const Center(child: Text('No results recorded.'));
    }

    final isNormal = assessment.severityTier == 'normal';
    final tierColor = isNormal
        ? RakshaSetuColors.emerald500
        : (assessment.severityTier == 'mild' ? RakshaSetuColors.azure : RakshaSetuColors.amber500);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LiquidGlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: tierColor.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Icon(
                    isNormal ? Icons.verified_rounded : Icons.info_outline_rounded,
                    size: 32,
                    color: tierColor,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${assessment.assessmentType.toUpperCase()} Complete',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: RakshaSetuColors.slate900,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'SEVERITY: ${assessment.severityTier.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: tierColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Score Display
                LiquidGlassInner(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        '${assessment.totalScore.toInt()}',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: tierColor,
                        ),
                      ),
                      const Text(
                        'Total Clinical Diagnostic Score',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: RakshaSetuColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _explanationForTier(assessment.assessmentType, assessment.severityTier),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 12.5,
                          height: 1.45,
                          color: RakshaSetuColors.slate700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ObsidianButton(
                  label: 'Done • Return to Dashboard',
                  icon: const Icon(Icons.check_rounded, size: 18, color: Color(0xFF67E8F9)),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const WelfareBanner(),
        ],
      ),
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
