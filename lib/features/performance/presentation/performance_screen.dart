// lib/features/performance/presentation/performance_screen.dart
// Presentation screen for operational performance, encouraging coaching, and ACR firewall enforcement

import 'package:flutter/material.dart';
import '../data/performance_repository.dart';
import '../domain/acr_context_note.dart';
import '../domain/performance_record.dart';
import '../domain/progress_update.dart';
import 'performance_view_model.dart';

class PerformanceScreen extends StatefulWidget {
  final IPerformanceRepository repository;
  final String officerId;

  const PerformanceScreen({
    super.key,
    required this.repository,
    this.officerId = 'mock-officer-uuid-001',
  });

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  late final PerformanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PerformanceViewModel(
      repository: widget.repository,
      officerId: widget.officerId,
    );
    _viewModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Performance & ACR Firewall'),
            backgroundColor: Colors.indigo.shade900,
            foregroundColor: Colors.white,
          ),
          body: _viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => _viewModel.loadData(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Top Firewall Banner
                      _buildFirewallBanner(),
                      const SizedBox(height: 16),

                      // Overall Performance Card
                      if (_viewModel.latestRecord != null) ...[
                        _buildPerformanceCard(_viewModel.latestRecord!),
                        const SizedBox(height: 16),
                      ],

                      // Encouraging AI Feedback Card
                      if (_viewModel.encouragingFeedback != null) ...[
                        _buildEncouragingFeedbackCard(_viewModel.encouragingFeedback!),
                        const SizedBox(height: 16),
                      ],

                      // Commander Non-Clinical Progress Updates
                      _buildProgressUpdatesSection(_viewModel.progressUpdates),
                      const SizedBox(height: 16),

                      // ACR Context Notes Section
                      _buildAcrNotesSection(_viewModel.acrNotes),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFirewallBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade300, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: Colors.indigo.shade900, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welfare-HR & ACR Firewall Active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stress scores, psychometric inventories (PHQ/GAD), and clinical therapy notes are strictly prohibited from ACR records. Evaluated metrics cover non-clinical operational drills only.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.indigo.shade900,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(PerformanceRecord record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Operational Performance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade400),
                  ),
                  child: Text(
                    '${record.overallPerformanceScore.toStringAsFixed(1)} / 100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Evaluated Competencies (Non-Clinical):',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            ...record.evaluatedAreas.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 13)),
                        Text('${entry.value.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / 100.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.value >= 85 ? Colors.teal : (entry.value >= 70 ? Colors.blue : Colors.orange),
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              );
            }),

            if (record.improvementSuggestions != null) ...[
              const SizedBox(height: 8),
              Text(
                'Development Focus: ${record.improvementSuggestions}',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEncouragingFeedbackCard(String feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber.shade900, size: 20),
              const SizedBox(width: 8),
              Text(
                'Encouraging Coaching Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            feedback,
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.verified, size: 14, color: Colors.green.shade800),
              const SizedBox(width: 4),
              Text(
                'Vetted Operational Template • Zero Clinical Advice',
                style: TextStyle(fontSize: 11, color: Colors.green.shade900, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressUpdatesSection(List<ProgressUpdate> updates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operational Progress Updates',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (updates.isEmpty)
          const Text('No recent progress updates.')
        else
          ...updates.map((u) {
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  u.statusIndicator == 'improving' ? Icons.trending_up : Icons.horizontal_rule,
                  color: u.statusIndicator == 'improving' ? Colors.teal : Colors.blueGrey,
                ),
                title: Text(u.publicContextNote ?? 'Status: ${u.statusIndicator}', style: const TextStyle(fontSize: 13)),
                subtitle: Text('ACR Synced: ${u.acrSynced ? "Yes (Non-Clinical)" : "No"} • ${_formatDate(u.createdAt)}', style: const TextStyle(fontSize: 11)),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAcrNotesSection(List<AcrContextNote> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACR Non-Clinical Context Notes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _showAddAcrNoteDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add ACR Note'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (notes.isEmpty)
          const Text('No ACR context notes recorded for this period.')
        else
          ...notes.map((n) {
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Year: ${n.reportingPeriodYear}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: const Text('Firewall Verified', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(n.nonClinicalHrContext, style: const TextStyle(fontSize: 12.5)),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showAddAcrNoteDialog() {
    final noteController = TextEditingController();
    String? localError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add ACR Non-Clinical Context'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Context notes must relate solely to administrative and non-clinical operational achievements. Mentions of stress, therapy, or psychometrics will be blocked.',
                  style: TextStyle(fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Commended for radio communications proficiency under sub-zero climate...',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (localError != null) ...[
                  const SizedBox(height: 8),
                  Text(localError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final text = noteController.text.trim();
                  if (text.isEmpty) {
                    setDialogState(() => localError = 'Please provide context note.');
                    return;
                  }

                  final success = await _viewModel.addAcrContextNote(
                    reportingPeriodYear: DateTime.now().year,
                    nonClinicalHrContext: text,
                  );

                  if (success) {
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  } else {
                    setDialogState(() => localError = _viewModel.errorMessage);
                  }
                },
                child: const Text('Verify & Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
