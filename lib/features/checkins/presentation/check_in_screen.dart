// lib/features/checkins/presentation/check_in_screen.dart
// PHQ-2, GAD-2, sleep, workload biweekly check-in wizard with offline-first support
// Styled with Arctic Frost glassmorphism, RakshaSetuScaffold, and overflow-free scrolling

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/rakshasetu_scaffold.dart';
import '../../../shared/widgets/kinetic_dots_loader.dart';
import 'check_in_view_model.dart';

class CheckInScreen extends StatelessWidget {
  final CheckInViewModel viewModel;

  const CheckInScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return PopScope(
          canPop: viewModel.step == CheckInStep.intro || viewModel.step == CheckInStep.done,
          child: RakshaSetuScaffold(
            currentRoute: '/checkin',
            subtitle: 'Biweekly Confidential Wellness Check-In',
            showBackButton: true,
            showFloatingDock: viewModel.step == CheckInStep.intro || viewModel.step == CheckInStep.done,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _buildStep(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (viewModel.step) {
      case CheckInStep.intro:
        return _IntroStep(onStart: viewModel.start);
      case CheckInStep.phq2:
        return _QuestionStep(
          key: const ValueKey('phq2'),
          title: 'Mood & Emotional Wellbeing',
          question:
              'Over the last 2 weeks, how often have you been bothered by little interest or pleasure in doing things, or feeling down, depressed, or hopeless?',
          scale: 6,
          labels: const ['0 — Not at all', '1–2 — Slightly', '3–4 — Moderately', '5–6 — Very much'],
          onSelect: viewModel.setPhq2Score,
          disclaimer: 'PHQ-2 • Confidential • Non-disciplinary',
        );
      case CheckInStep.gad2:
        return _QuestionStep(
          key: const ValueKey('gad2'),
          title: 'Anxiety & Worry',
          question:
              'Over the last 2 weeks, how often have you been bothered by feeling nervous, anxious, on edge, or unable to stop worrying?',
          scale: 6,
          labels: const ['0 — Not at all', '1–2 — Slightly', '3–4 — Moderately', '5–6 — Very much'],
          onSelect: viewModel.setGad2Score,
          disclaimer: 'GAD-2 • Confidential • Non-disciplinary',
        );
      case CheckInStep.sleep:
        return _ScaleStep(
          key: const ValueKey('sleep'),
          title: 'Sleep Quality',
          question: 'How would you rate your sleep quality over the last two weeks?',
          minLabel: 'Very poor',
          maxLabel: 'Excellent',
          maxValue: 5,
          currentValue: viewModel.sleepQualityScore,
          onSelect: viewModel.setSleepScore,
        );
      case CheckInStep.workload:
        return _ScaleStep(
          key: const ValueKey('workload'),
          title: 'Workload & Rest Balance',
          question: 'How manageable has your operational duty workload been over the last two weeks?',
          minLabel: 'Overwhelming',
          maxLabel: 'Manageable',
          maxValue: 5,
          currentValue: viewModel.workloadScore,
          onSelect: viewModel.setWorkloadScore,
        );
      case CheckInStep.freeText:
        return _FreeTextStep(
          onSubmit: viewModel.submitWithText,
          onSkip: viewModel.skipFreeText,
        );
      case CheckInStep.submitting:
        return const Center(
          child: KineticDotsLoader(
            size: 20,
            label: 'Encrypting and syncing check-in...',
          ),
        );
      case CheckInStep.done:
        return _DoneStep(
          isElevated: viewModel.isElevated,
          onClose: () => context.pop(),
        );
      case CheckInStep.error:
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
                    'Saved Locally For Offline Sync',
                    style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    viewModel.errorMessage ?? 'Network unreachable. Stored in tamper-proof offline queue.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11.5, color: RakshaSetuColors.slate600),
                  ),
                  const SizedBox(height: 16),
                  ObsidianButton(
                    label: 'Return to Dashboard',
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class _IntroStep extends StatelessWidget {
  final VoidCallback onStart;
  const _IntroStep({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: LiquidGlassCard(
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
                child: const Icon(Icons.fact_check_rounded, size: 30, color: RakshaSetuColors.azure),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Biweekly Wellness Check-In',
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
              'A rapid 2-minute personal operational status check to track your baseline resilience.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: RakshaSetuColors.slate600),
            ),
            const SizedBox(height: 18),
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
                  _IntroBullet(text: 'Completely confidential & end-to-end encrypted'),
                  SizedBox(height: 8),
                  _IntroBullet(text: 'Isolated from Service promotion, ACRs, and posting files'),
                  SizedBox(height: 8),
                  _IntroBullet(text: 'Backed by cryptographic Welfare-HR Firewall'),
                  SizedBox(height: 8),
                  _IntroBullet(text: 'Works 100% offline with automatic mesh sync'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            ObsidianButton(
              label: 'Start Check-In',
              icon: const Icon(Icons.arrow_forward_rounded, size: 17, color: Color(0xFF67E8F9)),
              onPressed: onStart,
            ),
          ],
        ),
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

class _QuestionStep extends StatelessWidget {
  final String title;
  final String question;
  final int scale;
  final List<String> labels;
  final ValueChanged<int> onSelect;
  final String disclaimer;

  const _QuestionStep({
    super.key,
    required this.title,
    required this.question,
    required this.scale,
    required this.labels,
    required this.onSelect,
    required this.disclaimer,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: LiquidGlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: RakshaSetuColors.slate900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question,
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 13, height: 1.45, color: RakshaSetuColors.slate700),
            ),
            const SizedBox(height: 20),
            ...List.generate(scale ~/ 2 + 1, (i) {
              final value = i == 0 ? 0 : (i == 1 ? 2 : 4) + (i > 2 ? (i - 2) * 2 : 0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => onSelect(value),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x6622D3EE), width: 1.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          i < labels.length ? labels[i] : 'Score $value',
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: RakshaSetuColors.slate900,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: RakshaSetuColors.azure),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Text(
              disclaimer,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 10.5, color: RakshaSetuColors.slate500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleStep extends StatefulWidget {
  final String title;
  final String question;
  final String minLabel;
  final String maxLabel;
  final int maxValue;
  final int currentValue;
  final ValueChanged<int> onSelect;

  const _ScaleStep({
    super.key,
    required this.title,
    required this.question,
    required this.minLabel,
    required this.maxLabel,
    required this.maxValue,
    required this.currentValue,
    required this.onSelect,
  });

  @override
  State<_ScaleStep> createState() => _ScaleStepState();
}

class _ScaleStepState extends State<_ScaleStep> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: LiquidGlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: RakshaSetuColors.slate900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.question,
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 13, height: 1.45, color: RakshaSetuColors.slate700),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.minLabel, style: const TextStyle(fontSize: 11, color: RakshaSetuColors.slate500)),
                Text(widget.maxLabel, style: const TextStyle(fontSize: 11, color: RakshaSetuColors.slate500)),
              ],
            ),
            Slider(
              value: _value.toDouble(),
              min: 1,
              max: widget.maxValue.toDouble(),
              divisions: widget.maxValue - 1,
              activeColor: RakshaSetuColors.azure,
              inactiveColor: const Color(0x3322D3EE),
              label: '$_value',
              onChanged: (v) => setState(() => _value = v.round()),
            ),
            Center(
              child: Text(
                'Rating: $_value / ${widget.maxValue}',
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: RakshaSetuColors.navy,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ObsidianButton(
              label: 'Next Question',
              onPressed: () => widget.onSelect(_value),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeTextStep extends StatefulWidget {
  final Future<void> Function(String?) onSubmit;
  final VoidCallback onSkip;

  const _FreeTextStep({required this.onSubmit, required this.onSkip});

  @override
  State<_FreeTextStep> createState() => _FreeTextStepState();
}

class _FreeTextStepState extends State<_FreeTextStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: LiquidGlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Optional Officer Note',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: RakshaSetuColors.slate900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Is there anything else you would like to note? This is completely optional and isolated by the HR Firewall.',
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 12, height: 1.4, color: RakshaSetuColors.slate600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(fontSize: 13, color: RakshaSetuColors.slate900),
              decoration: InputDecoration(
                hintText: 'Optional — notes are encrypted with your personal key...',
                hintStyle: const TextStyle(fontSize: 12, color: RakshaSetuColors.slate400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            ObsidianButton(
              label: 'Submit Check-In',
              onPressed: () => widget.onSubmit(_controller.text.isEmpty ? null : _controller.text),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: widget.onSkip,
                child: const Text(
                  'Skip and Submit',
                  style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700, color: RakshaSetuColors.azure),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneStep extends StatelessWidget {
  final bool isElevated;
  final VoidCallback onClose;

  const _DoneStep({required this.isElevated, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: LiquidGlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isElevated ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isElevated ? Icons.info_rounded : Icons.check_circle_rounded,
                  size: 34,
                  color: isElevated ? RakshaSetuColors.amber800 : RakshaSetuColors.emerald800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isElevated ? 'Check-In Complete • Support Flagged' : 'Check-In Complete',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: RakshaSetuColors.slate900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isElevated
                  ? 'Your baseline indicates high operational fatigue. A confidential conversation with your unit welfare officer is available whenever you are ready.'
                  : 'Your check-in has been encrypted and recorded securely. Zero HR exposure.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12, height: 1.45, color: RakshaSetuColors.slate600),
            ),
            const SizedBox(height: 24),
            if (isElevated) ...[
              OutlinedButton.icon(
                onPressed: () => context.push('/crisis'),
                icon: const Icon(Icons.emergency_rounded, color: RakshaSetuColors.rose600, size: 18),
                label: const Text('Connect with 24x7 Helpline', style: TextStyle(color: RakshaSetuColors.rose600, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: RakshaSetuColors.rose600),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ObsidianButton(
              label: 'Done',
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
