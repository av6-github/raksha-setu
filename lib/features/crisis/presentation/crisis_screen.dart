// lib/features/crisis/presentation/crisis_screen.dart
// Permanent 24x7 crisis handoff screen — AI/LLMs STRICTLY FORBIDDEN in this flow

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/cssrs_screener.dart';
import 'crisis_view_model.dart';

class CrisisScreen extends StatelessWidget {
  final CrisisViewModel? viewModel;

  const CrisisScreen({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;

    Widget buildScaffold(BuildContext context) {
      return PopScope(
        canPop: true,
        child: Scaffold(
        backgroundColor: const Color(0xFF7F1D1D), // Deep Red
        appBar: AppBar(
          backgroundColor: const Color(0xFF7F1D1D),
          foregroundColor: Colors.white,
          title: const Text(
            '24×7 Immediate Human Support',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Reassurance header
                const Column(
                  children: [
                    Icon(
                      Icons.health_and_safety_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'You are not alone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You will be connected directly to a trained human responder — '
                      'no automated responses, zero AI, and zero data recorded for ACR or performance review.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.3),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Dispatched Alert Banner (if triggered)
                if (vm?.isAlertSent ?? false) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Safety Alert Dispatched',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
                              ),
                              Text(
                                'A regimental duty welfare officer has been notified for immediate check-in.',
                                style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 1. Primary Crisis Action — Tele-MANAS
                _CrisisActionButton(
                  icon: Icons.phone_rounded,
                  label: 'Call Tele-MANAS (14416)',
                  subtitle: 'National Mental Health Helpline — Free, Toll-Free, 24x7',
                  color: Colors.white,
                  textColor: const Color(0xFF7F1D1D),
                  onTap: () async {
                    final uri = Uri.parse('tel:14416');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      // Web fallback — phone dialing not supported in browser
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dial 14416 (Tele-MANAS, Toll-Free, 24x7) on your phone.'),
                            duration: Duration(seconds: 5),
                            backgroundColor: Color(0xFF7F1D1D),
                          ),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 12),

                // 2. Regimental Medical Officer / Force Counsellor Desk
                _CrisisActionButton(
                  icon: Icons.support_agent_rounded,
                  label: 'Call Regimental Medical Desk',
                  subtitle: 'Direct line to force medical officer / on-duty counsellor',
                  color: Colors.white24,
                  textColor: Colors.white,
                  onTap: () async {
                    // Static CRPF/BSF Medical Helpline
                    final uri = Uri.parse('tel:01126192999');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Call Regimental Medical Desk: 011-26192999'),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 12),

                // 3. Send Immediate Safety Alert
                _CrisisActionButton(
                  icon: Icons.notification_important_rounded,
                  label: 'Send Immediate Safety Alert',
                  subtitle: 'Alerts duty officer for immediate human presence and check-in',
                  color: Colors.white24,
                  textColor: Colors.white,
                  onTap: () async {
                    if (vm != null) {
                      await vm.triggerDirectSafetyAlert(severity: 'imminent');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Priority safety alert dispatched to duty officer.')),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 20),

                // 4. Safety Plan Quick Access
                ElevatedButton.icon(
                  onPressed: () => _showSafetyPlanBottomSheet(context, vm),
                  icon: const Icon(Icons.bookmark_border_rounded, size: 20),
                  label: const Text('View My Personal Safety Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 10),

                // 5. C-SSRS Quick Screener
                OutlinedButton.icon(
                  onPressed: () => _showCssrsDialog(context, vm),
                  icon: const Icon(Icons.psychology_outlined, size: 20),
                  label: const Text('Clinical Triage Screener (C-SSRS)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 28),

                // Absolute Rule Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock_clock_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'HARD ARCHITECTURAL GUARANTEE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'AI, LLMs, and conversational chatbots are strictly forbidden from this route. '
                        'Every action connects you directly with certified human clinical professionals or trusted peers. '
                        'No crisis disclosure will ever appear on an ACR or influence posting or promotion.',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

    if (vm != null) {
      return ListenableBuilder(
        listenable: vm,
        builder: (context, _) => buildScaffold(context),
      );
    }

    return buildScaffold(context);
  }

  void _showSafetyPlanBottomSheet(BuildContext context, CrisisViewModel? vm) {
    final plan = vm?.safetyPlan;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Personal Safety Plan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('1. Tactical Internal Coping Strategies:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...?plan?.internalCopingStrategies.map((s) => Text('• $s', style: const TextStyle(fontSize: 13))),
            const SizedBox(height: 14),
            const Text('2. Emergency Contacts:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...?plan?.trustedContacts.map((c) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${c['role']} • ${c['phone']}'),
                  trailing: const Icon(Icons.phone, color: Colors.green),
                  onTap: () async {
                      final phone = c['phone'] ?? '';
                      final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Call ${c['name']}: $phone')),
                        );
                      }
                    },
                )),
            const SizedBox(height: 14),
            const Text('3. Environmental Safety Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...?plan?.environmentalSafetySteps.map((s) => Text('• $s', style: const TextStyle(fontSize: 13))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCssrsDialog(BuildContext context, CrisisViewModel? vm) {
    final answers = <int, bool>{};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('C-SSRS Triage Screener', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Answer honestly to help human clinicians prioritize response level:',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                ...CssrsScreener.questions.map((q) => CheckboxListTile(
                      dense: true,
                      title: Text(q.text, style: const TextStyle(fontSize: 12)),
                      subtitle: Text(q.clinicalRationale, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      value: answers[q.number] ?? false,
                      onChanged: (val) {
                        setState(() {
                          answers[q.number] = val ?? false;
                        });
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                if (vm != null) {
                  final severity = await vm.submitCssrs(answers);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('C-SSRS submitted. Triage priority level: $severity')),
                    );
                  }
                }
              },
              child: const Text('Submit to Clinical Team'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrisisActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _CrisisActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}
