// lib/features/consent/presentation/consent_centre_screen.dart
// Officer Consent Centre for granular consent management and immediate revocation

import 'package:flutter/material.dart';
import '../../../shared/widgets/welfare_banner.dart';
import 'consent_view_model.dart';

class ConsentCentreScreen extends StatelessWidget {
  final ConsentViewModel viewModel;

  const ConsentCentreScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Consent & Privacy Centre'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.loadConsents,
              ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const WelfareBanner(),
                    const SizedBox(height: 16),

                    // Privacy commitment card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.gavel, color: Colors.blue.shade900),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Consent-First Architecture',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'All secondary data flows are strictly opt-in, granular, and revocable. '
                                    'Commanders cannot override your consent decisions.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade900,

                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Core Consents Section
                    Text(
                      'Core Privacy Permissions',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    ...viewModel.consents.map((consent) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      consent.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  Switch(
                                    value: consent.isGranted,
                                    onChanged: (val) => viewModel.toggleConsent(consent.consentType, val),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                consent.description,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    consent.isGranted ? Icons.check_circle : Icons.cancel_outlined,
                                    size: 14,
                                    color: consent.isGranted ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    consent.isGranted
                                        ? 'Active since ${consent.grantedAt.toIso8601String().split('T').first}'
                                        : (consent.revokedAt != null
                                            ? 'Revoked on ${consent.revokedAt!.toIso8601String().split('T').first}'
                                            : 'Not authorized'),
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                  const Spacer(),
                                  if (consent.isGranted)
                                    TextButton(
                                      onPressed: () => viewModel.revokeConsent(consent.consentType),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: const Text('Revoke Now', style: TextStyle(fontSize: 12)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Granular Family Consents Section
                    Text(
                      'Granular Family Support Sharing',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    if (viewModel.familyConsents.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No family members linked yet.'),
                        ),
                      )
                    else
                      ...viewModel.familyConsents.map((fc) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 16,
                                      child: Icon(Icons.person, size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${fc.familyMemberName} (${fc.relation})',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Flash Supportive Notifications', style: TextStyle(fontSize: 14)),
                                  subtitle: const Text('Sends generic, non-operational wellbeing updates', style: TextStyle(fontSize: 12)),
                                  value: fc.shareFlashNotifications,
                                  onChanged: (val) => viewModel.toggleFamilyFlashNotifications(fc.id, val),
                                ),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Morale Vault Media Messages', style: TextStyle(fontSize: 14)),
                                  subtitle: const Text('Permits uploading videos/voice notes after OPSEC review', style: TextStyle(fontSize: 12)),
                                  value: fc.shareMoraleMessages,
                                  onChanged: (val) => viewModel.toggleFamilyMoraleMessages(fc.id, val),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Notification Window: ${fc.notificationWindowStart ?? '08:00'} - ${fc.notificationWindowEnd ?? '21:00'}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
        );
      },
    );
  }
}
