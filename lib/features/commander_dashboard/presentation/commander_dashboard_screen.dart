// lib/features/commander_dashboard/presentation/commander_dashboard_screen.dart
// Commander Unit Overview: Aggregate readiness, fatigue indicators, roster recommendations, and binary availability

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../domain/roster_recommendation.dart';
import 'commander_view_model.dart';

class CommanderDashboardScreen extends StatelessWidget {
  final CommanderViewModel? viewModel;

  const CommanderDashboardScreen({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final authVm = context.watch<AuthViewModel?>();

    Widget buildScaffold() {
      final metrics = vm?.metrics;
      final recommendations = vm?.recommendations ?? [];
      final roster = vm?.availabilityRoster ?? {};

      return Scaffold(
        appBar: AppBar(
          title: const Text('Commander Unit Overview'),
          backgroundColor: Colors.blueGrey.shade900,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => vm?.loadUnitData(vm.selectedUnitCode),
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Sign Out',
              onPressed: () => authVm?.signOut(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Command Transparency Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blueGrey.shade50,
              child: Row(
                children: [
                  Icon(Icons.policy_outlined, size: 20, color: Colors.blueGrey.shade900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Welfare-HR Firewall Guard: Command view is strictly restricted to aggregate unit readiness '
                      'and binary operational availability. Zero individual stress scores or clinical diagnoses exist in this console.',
                      style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade900),
                    ),
                  ),
                ],
              ),
            ),
            if (vm?.isLoading ?? false)
              const LinearProgressIndicator(),

            // Unit Switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Selected Unit: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Charlie Co (84 pers)'),
                      selected: vm?.selectedUnitCode == '12-BN-CHARLIE',
                      onSelected: (_) => vm?.loadUnitData('12-BN-CHARLIE'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Forward Det (6 pers)'),
                      selected: vm?.selectedUnitCode == 'FORWARD-DET-SMALL',
                      onSelected: (_) => vm?.loadUnitData('FORWARD-DET-SMALL'),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: metrics == null
                  ? const Center(child: Text('Loading unit operational data...'))
                  : metrics.isSuppressed
                      // Privacy Suppression Banner for k < 10
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Card(
                              color: Colors.amber.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.visibility_off_rounded, size: 48, color: Colors.amber.shade900),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Aggregate Metrics Suppressed',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Unit "${metrics.unitName}" has only ${metrics.totalPersonnel} personnel, '
                                      'which violates the minimum group size threshold (k >= 10).\n\n'
                                      'To prevent mathematical re-identification of individual officers, aggregate stress and fatigue indicators are suppressed.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Unit Readiness Indicators Card
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            metrics.unitName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Chip(
                                          label: Text('${metrics.totalPersonnel} Personnel'),
                                          backgroundColor: Colors.blueGrey.shade100,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _SummaryItem(
                                          label: 'Readiness Index',
                                          value: '${metrics.aggregateReadinessScore.toStringAsFixed(1)}%',
                                          color: Colors.teal.shade800,
                                        ),
                                        _SummaryItem(
                                          label: 'Fatigue Roster',
                                          value: '${metrics.highFatigueRosterPercent.toStringAsFixed(1)}%',
                                          color: metrics.highFatigueRosterPercent > 20
                                              ? Colors.orange.shade800
                                              : Colors.teal,
                                        ),
                                        _SummaryItem(
                                          label: 'Consecutive Duty',
                                          value: '${metrics.consecutiveDutyFlagCount} flags',
                                          color: metrics.consecutiveDutyFlagCount > 10
                                              ? Colors.red.shade800
                                              : Colors.blueGrey,
                                        ),
                                        _SummaryItem(
                                          label: 'Leave Friction',
                                          value: '${(metrics.leaveFrictionIndex * 100).toStringAsFixed(0)}%',
                                          color: Colors.blueGrey.shade800,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Algorithmic Roster Recommendations
                            const Text(
                              'Operational Roster Recommendations',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),

                            if (recommendations.isEmpty)
                              const Text('No pending roster interventions required.')
                            else
                              ...recommendations.map(
                                (rec) => Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                rec.title,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                rec.priority.displayName,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: rec.priority == RecommendationPriority.urgent
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              backgroundColor: rec.priority == RecommendationPriority.urgent
                                                  ? Colors.red
                                                  : Colors.amber.shade200,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(rec.rationale, style: const TextStyle(fontSize: 12)),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Action: ${rec.suggestedAction}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: rec.isAcknowledged
                                              ? const Chip(
                                                  label: Text('Acknowledged', style: TextStyle(fontSize: 10)),
                                                  backgroundColor: Colors.greenAccent,
                                                )
                                              : OutlinedButton(
                                                  child: const Text('Acknowledge & Apply'),
                                                  onPressed: () => vm?.acknowledgeRecommendation(rec.id),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Operational Availability Roster (Strictly Available / Medically Unavailable)
                            const Text(
                              'Unit Operational Availability Roster',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Only binary duty availability is shown. Clinical diagnosis and mental health assessments are strictly quarantined.',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),

                            ...roster.entries.map((entry) {
                              final isAvailable = entry.value == 'available';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 6),
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(
                                    isAvailable ? Icons.check_circle : Icons.do_not_disturb_on,
                                    color: isAvailable ? Colors.green : Colors.grey,
                                  ),
                                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  trailing: Chip(
                                    label: Text(
                                      isAvailable ? 'AVAILABLE' : 'MEDICALLY UNAVAILABLE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isAvailable ? Colors.green.shade900 : Colors.grey.shade900,
                                      ),
                                    ),
                                    backgroundColor: isAvailable ? Colors.green.shade50 : Colors.grey.shade200,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                          ],
                        ),
            ),
          ],
        ),
      );
    }

    if (vm != null) {
      return ListenableBuilder(
        listenable: vm,
        builder: (context, _) => buildScaffold(),
      );
    }

    return buildScaffold();
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
