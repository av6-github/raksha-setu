// lib/features/analytics/presentation/baseline_trends_screen.dart
// Interactive personal baseline inspection, CUSUM change-point deviation alerts, and k-anonymized unit insights

import 'package:flutter/material.dart';
import '../../../shared/widgets/welfare_banner.dart';
import 'baseline_view_model.dart';

class BaselineTrendsScreen extends StatelessWidget {
  final BaselineViewModel viewModel;

  const BaselineTrendsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final base = viewModel.baseline;
        final deviations = viewModel.deviations;
        final unitSig = viewModel.unitAggregate;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Personal Baseline & Analytics'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Analytics',
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

                    // 1. Personal Baseline Calibration Card
                    Card(
                      elevation: 2,
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
                                    'Calibrated Personal Baseline',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (base?.isColdStart ?? true) ? Colors.blue.shade50 : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (base?.isColdStart ?? true) ? Colors.blue.shade300 : Colors.green.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    'v${base?.version ?? 1} • ${(base?.isColdStart ?? true) ? "Bayesian Prior" : "Mature Baseline"}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: (base?.isColdStart ?? true) ? Colors.blue.shade900 : Colors.green.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'The engine learns your unique physiological and operational normal rather than judging you against an arbitrary population threshold.',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700, height: 1.4),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _BaselineStat(
                                  label: 'Sleep Norm',
                                  value: '${base?.sleepMean.toStringAsFixed(1)}h',
                                  subValue: '±${base?.sleepStd.toStringAsFixed(1)}h',
                                  icon: Icons.bedtime_outlined,
                                  color: Colors.indigo,
                                ),
                                _BaselineStat(
                                  label: 'Duty Norm',
                                  value: '${base?.dutyHoursMean.toStringAsFixed(1)}h',
                                  subValue: '±${base?.dutyHoursStd.toStringAsFixed(1)}h',
                                  icon: Icons.work_outline,
                                  color: Colors.brown,
                                ),
                                _BaselineStat(
                                  label: 'Distress Norm',
                                  value: '${base?.checkInDistressMean.toStringAsFixed(1)}/6',
                                  subValue: 'PHQ-2+GAD-2',
                                  icon: Icons.favorite_border,
                                  color: Colors.teal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. CUSUM Change-Point Deviations Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CUSUM Change-Point Alerts',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (deviations.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${deviations.length} Active Shifts',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (deviations.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'All monitored dimensions are currently within your personal baseline equilibrium.',
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...deviations.map((d) {
                        final isElevated = d.direction.toLowerCase() == 'elevated';
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
                                        d.featureDisplayName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isElevated ? Colors.red.shade100 : Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${isElevated ? "▲ Elevated" : "▼ Depressed"} (${d.magnitude.toStringAsFixed(1)}σ)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: isElevated ? Colors.red.shade900 : Colors.blue.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Baseline: ${d.baselineValue.toStringAsFixed(1)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('Observed: ${d.currentValue.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text('${d.durationDays}d sustained', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    const SizedBox(width: 8),
                                    Text('(${(d.confidence * 100).toInt()}% conf)', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.info_outline, size: 14, color: Colors.blueGrey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          d.context,
                                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, height: 1.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 20),

                    // 3. Unit-Level Anonymous Operational Grouping Card
                    Text(
                      'Unit Operational Equilibrium (k-Anonymity Protected)',
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
                                    unitSig?.unitName ?? 'Unit Roster',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (unitSig?.isAnonymized ?? false) ? Colors.teal.shade50 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: (unitSig?.isAnonymized ?? false) ? Colors.teal.shade300 : Colors.grey.shade400),
                                  ),
                                  child: Text(
                                    'k=${unitSig?.kAnonymityThreshold ?? 5} Protected',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: (unitSig?.isAnonymized ?? false) ? Colors.teal.shade900 : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Data aggregated across ${unitSig?.totalOfficers ?? 0} officers. Zero individual stress metrics are exposed to commanding officers.',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                            ),
                            const Divider(height: 20),
                            Text('Systemic Balancing Insights:', style: theme.textTheme.labelMedium),
                            const SizedBox(height: 6),
                            ...?unitSig?.systemicRecommendations.map((rec) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.arrow_right, size: 16, color: Colors.teal),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(rec, style: const TextStyle(fontSize: 12, height: 1.3)),
                                      ),
                                    ],
                                  ),
                                )),
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

class _BaselineStat extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color color;

  const _BaselineStat({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(subValue, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
