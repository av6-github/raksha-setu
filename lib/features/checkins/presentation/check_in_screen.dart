// lib/features/checkins/presentation/check_in_screen.dart
// PHQ-2, GAD-2, sleep, workload biweekly check-in wizard with offline-first support

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Wellness Check-In'),
              leading: (viewModel.step == CheckInStep.intro || viewModel.step == CheckInStep.done)
                  ? null
                  : const CloseButton(),
            ),
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
          title: 'Workload',
          question: 'How manageable has your workload been over the last two weeks?',
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
        return const Center(child: CircularProgressIndicator());
      case CheckInStep.done:
        return _DoneStep(
          isElevated: viewModel.isElevated,
          onClose: () => context.pop(),
        );
      case CheckInStep.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Submission failed. Check-in saved for offline sync.'),
              const SizedBox(height: 8),
              Text(viewModel.errorMessage ?? '', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => context.pop(), child: const Text('Close')),
            ],
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.favorite_rounded, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            'Biweekly Wellness Check-In',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'This takes about 2 minutes. Your responses are:\n\n'
            '• Completely confidential\n'
            '• Never shared with HR or used in ACR\n'
            '• Protected by the Welfare-HR Firewall\n'
            '• Stored securely and accessible only to you and authorised welfare staff\n\n'
            'You can complete this offline — it will sync automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Start Check-In', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(question, style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 32),
          ...List.generate(scale ~/ 2 + 1, (i) {
            final value = i == 0 ? 0 : (i == 1 ? 2 : 4) + (i > 2 ? (i - 2) * 2 : 0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => onSelect(value),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(i < labels.length ? labels[i] : 'Score $value', style: const TextStyle(fontSize: 14)),
                ),
              ),
            );
          }),
          const Spacer(),
          Text(disclaimer, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(widget.question, style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.minLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(widget.maxLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Slider(
            value: _value.toDouble(),
            min: 1,
            max: widget.maxValue.toDouble(),
            divisions: widget.maxValue - 1,
            label: '$_value',
            onChanged: (v) => setState(() => _value = v.round()),
          ),
          Center(
            child: Text(
              'Rating: $_value / ${widget.maxValue}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => widget.onSelect(_value),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Next', style: TextStyle(fontSize: 16)),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text('Optional Note', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'Is there anything else you would like to share? This is completely optional and confidential.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Optional — your words are private and protected...',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => widget.onSubmit(_controller.text.isEmpty ? null : _controller.text),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Submit Check-In', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onSkip,
            child: const Text('Skip and Submit'),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            isElevated ? Icons.info_rounded : Icons.check_circle_rounded,
            size: 72,
            color: isElevated ? Colors.orange : Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            isElevated ? 'Check-In Complete' : 'Thank you!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            isElevated
                ? 'Your responses suggest you might benefit from a conversation with a welfare officer. '
                    'You will receive a private outreach at your convenience. '
                    'No action will be taken without your involvement.'
                : 'Your check-in has been recorded securely. '
                    'Your wellness matters. See you in two weeks.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 32),
          if (isElevated) ...[
            OutlinedButton.icon(
              onPressed: () => context.push('/crisis'),
              icon: const Icon(Icons.emergency),
              label: const Text('Immediate Support'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
          ],
          FilledButton(
            onPressed: onClose,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Done', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
