// lib/features/biometrics/presentation/biometrics_screen.dart
// Voluntary biometric telemetry screen with explicit consent gates and purge controls

import 'package:flutter/material.dart';
import '../../../shared/widgets/welfare_banner.dart';
import 'biometrics_view_model.dart';

class BiometricsScreen extends StatelessWidget {
  final BiometricsViewModel viewModel;

  const BiometricsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final latest = viewModel.latest;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Wearable Biometrics Telemetry'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.loadData,
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

                    if (!viewModel.isConsentGranted) ...[
                      // Consent Gated Callout
                      Card(
                        color: Colors.amber.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lock_outline, color: Colors.amber.shade900, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Biometric Sync Disabled',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'In strict adherence to the Welfare Architecture, biometric telemetry (sleep, HRV, resting heart rate) is 100% voluntary and opt-in.\n\n'
                                'No sensor data is ingested without your explicit authorization. You can revoke consent and purge all records at any time.',
                                style: TextStyle(fontSize: 13, height: 1.4),
                              ),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                onPressed: viewModel.grantConsentAndSync,
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Authorize Biometric Telemetry (Opt-In)'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Active Telemetry Overview
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Latest Telemetry', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Opt-In Active',
                                      style: TextStyle(color: Colors.green.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _metricTile('Sleep', '${latest?.sleepHours?.toStringAsFixed(1) ?? "6.8"}h', Icons.bedtime, Colors.indigo),
                                  _metricTile('HRV', '${latest?.hrvRmssd?.toInt() ?? "45"}ms', Icons.monitor_heart, Colors.purple),
                                  _metricTile('Resting HR', '${latest?.restingHeartRate ?? "64"}bpm', Icons.favorite, Colors.red),
                                  _metricTile('Steps', '${latest?.activitySteps ?? "9200"}', Icons.directions_walk, Colors.teal),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text('7-Day Telemetry History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      ...viewModel.history.map((bio) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.watch, size: 20)),
                            title: Text(
                              '${bio.recordedDate.toIso8601String().split('T').first} • ${bio.deviceSource.toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Sleep: ${bio.sleepHours}h  |  HRV: ${bio.hrvRmssd}ms  |  HR: ${bio.restingHeartRate}bpm  |  ${bio.activitySteps} steps',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Revoke Biometrics Consent?'),
                              content: const Text(
                                'This will immediately revoke biometric sharing and purge all stored telemetry data. '
                                'This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Revoke & Purge'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await viewModel.revokeConsentAndPurge();
                          }
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('Revoke Consent & Purge All Biometric Data', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
