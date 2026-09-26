// lib/features/interventions/presentation/support_hub_screen.dart
// Voluntary human support choices, confidential counselling scheduling, and RTD tracking

import 'package:flutter/material.dart';
import '../../../shared/widgets/welfare_banner.dart';
import '../domain/support_intervention.dart';
import 'intervention_view_model.dart';

class SupportHubScreen extends StatelessWidget {
  final InterventionViewModel viewModel;

  const SupportHubScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final interventions = viewModel.interventions;
        final bookings = viewModel.bookings;
        final rtd = viewModel.rtdPlan;
        final commanderStatus = viewModel.commanderDisclosedStatus;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Support & Human Interventions'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Support Options',
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

                    // 1. Human-in-the-Loop Trust Commitment Card
                    Card(
                      color: Colors.blue.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.verified_user_outlined, color: Colors.blue, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '100% Voluntary · Zero Automated Consequences',
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'The system cannot punish, ground, or demote. Every support path is offered for your choice. '
                                    'Only licensed medical officers can recommend temporary off-duty respite.',
                                    style: TextStyle(fontSize: 12, color: Colors.blue.shade900, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Officer Support Choices Section
                    Text(
                      'Personalized Welfare & Workload Options',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    if (interventions.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No active intervention proposals. Your operational tempo and wellness indicators are in standard equilibrium.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ...interventions.map((item) {
                        final isProposed = item.status == InterventionStatus.proposed;
                        final isAccepted = item.status == InterventionStatus.accepted;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1.5,
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
                                        item.interventionType.displayName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isAccepted ? Colors.green.shade100 : (isProposed ? Colors.orange.shade100 : Colors.grey.shade200),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.status.displayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isAccepted ? Colors.green.shade900 : (isProposed ? Colors.orange.shade900 : Colors.grey.shade800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.notes != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    item.notes!,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.3),
                                  ),
                                ],
                                if (isProposed) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => viewModel.acceptIntervention(item.id),
                                          icon: const Icon(Icons.check, size: 16),
                                          label: const Text('Accept Option'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green.shade700,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () => viewModel.declineIntervention(item.id),
                                        child: const Text('Decline'),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 20),

                    // 3. Confidential Human Counselling Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Confidential Counselling Sessions',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            viewModel.scheduleCounselling(
                              sessionDate: DateTime.now().add(const Duration(days: 2)),
                              sessionType: 'tele_counselling',
                              isTeleCounselling: true,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Scheduled confidential Tele-MANAS consultation.')),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Book Session'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    ...bookings.map((booking) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade50,
                              child: const Icon(Icons.support_agent, color: Colors.purple),
                            ),
                            title: Text(booking.sessionTypeDisplay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(
                              '${booking.counsellorName}\nDate: ${booking.sessionDate.toIso8601String().split('T').first}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                booking.status.toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        )),

                    const SizedBox(height: 20),

                    // 4. Return-to-Duty (RTD) Plan (If active)
                    if (rtd != null) ...[
                      Text(
                        'Gradual Return-to-Duty (RTD) Plan',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 1.5,
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
                                      rtd.clinicianName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: rtd.clinicianClearanceGranted ? Colors.green.shade100 : Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      rtd.clinicianClearanceGranted ? 'Cleared for Full Duty' : 'Gradual Reintegration Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: rtd.clinicianClearanceGranted ? Colors.green.shade900 : Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rest Period: ${rtd.offDutyStart.toIso8601String().split('T').first} to ${rtd.expectedReturnDate.toIso8601String().split('T').first}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                              const Divider(height: 20),
                              const Text('Prescribed Recovery Steps:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 6),
                              ...rtd.gradedSteps.map((step) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text(step, style: const TextStyle(fontSize: 12))),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 5. Commander Disclosed Status Transparency Card
                    Text(
                      'Command Disclosure Transparency Inspector',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Status Disclosed to Commander:',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: commanderStatus == 'available' ? Colors.green.shade100 : Colors.blueGrey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    commanderStatus.toUpperCase().replaceAll('_', ' '),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: commanderStatus == 'available' ? Colors.green.shade900 : Colors.blueGrey.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Strict Minimum Necessary Privacy Guarantee: Your commanding officer can only view operational availability ("${commanderStatus.replaceAll('_', ' ')}"). '
                              'Zero psychological risk scores, clinical notes, check-in questionnaires, or stress factors are ever shared with command staff.',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
        );
      },
    );
  }
}
