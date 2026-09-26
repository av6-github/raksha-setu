// lib/features/hrms/presentation/organisational_signals_screen.dart
// Transparent review of organizational signals: leave history, duty rhythm, and operational hardship

import 'package:flutter/material.dart';
import '../../../shared/widgets/welfare_banner.dart';
import 'hrms_view_model.dart';

class OrganisationalSignalsScreen extends StatelessWidget {
  final HrmsViewModel viewModel;

  const OrganisationalSignalsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final signal = viewModel.signal;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Organisational Signals & Rhythm'),
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

                    // Systemic Friction Overview Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Systemic Operational Friction',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (signal?.frictionIndex ?? 0) >= 0.5 ? Colors.orange.shade100 : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Index: ${(signal?.frictionIndex ?? 0).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (signal?.frictionIndex ?? 0) >= 0.5 ? Colors.orange.shade900 : Colors.green.shade900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'The algorithm evaluates organizational strain rather than individual weakness. '
                              'High friction indicates the system owes you rest, leave, or rotation.',
                              style: TextStyle(fontSize: 12, height: 1.4),
                            ),
                            const Divider(height: 24),
                            Text('Primary Contributing Strain Factors:', style: theme.textTheme.labelMedium),
                            const SizedBox(height: 8),
                            ...?signal?.contributingFactors.map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.arrow_right, size: 18, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Leave History Section
                    Text('Leave Applications & Operational Decisions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    ...viewModel.leaves.map((leave) {
                      final isOpDenial = leave.isOperationalRejection;
                      final isApproved = leave.status.toLowerCase() == 'approved';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      leave.leaveType,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isApproved ? Colors.green.shade100 : (isOpDenial ? Colors.amber.shade100 : Colors.red.shade100),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      leave.statusDisplay,
                                      style: TextStyle(
                                        color: isApproved ? Colors.green.shade900 : (isOpDenial ? Colors.amber.shade900 : Colors.red.shade900),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${leave.startDate.toIso8601String().split('T').first} to ${leave.endDate.toIso8601String().split('T').first} (${leave.durationDays} days)',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                              if (leave.rejectionReason != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Reason: ${leave.rejectionReason}',
                                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Deployment Hardship Section
                    Text('Deployment Exposure & Hardship Postings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    ...viewModel.deployments.map((d) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: d.isHighHazard ? Colors.red.shade100 : Colors.blue.shade100,
                            child: Icon(
                              d.isHighHazard ? Icons.terrain : Icons.location_on,
                              color: d.isHighHazard ? Colors.red : Colors.blue,
                            ),
                          ),
                          title: Text(d.location, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                            '${d.operationName ?? "General Deployment"} • ${d.durationMonths} months sustained exposure'
                            '${d.isHighHazard ? "\nHigh-Hazard Hardship Index: ${d.hardshipScore}/10" : ""}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          isThreeLine: d.isHighHazard,
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
