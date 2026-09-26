// lib/features/counsellor_dashboard/presentation/counsellor_dashboard_screen.dart
// Clinical Counsellor Portal: Active cases, psychometric reviews, Stanley-Brown safety plans, and RTD notes

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/auth_view_model.dart';
import 'counsellor_view_model.dart';

class CounsellorDashboardScreen extends StatefulWidget {
  final CounsellorViewModel? viewModel;

  const CounsellorDashboardScreen({super.key, this.viewModel});

  @override
  State<CounsellorDashboardScreen> createState() => _CounsellorDashboardScreenState();
}

class _CounsellorDashboardScreenState extends State<CounsellorDashboardScreen> {
  final _noteController = TextEditingController();
  final _rtdController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _rtdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final authVm = context.watch<AuthViewModel?>();

    Widget buildScaffold() {
      final cases = vm?.cases ?? [];
      final selectedCase = vm?.selectedCase;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Clinical Counsellor Portal'),
          backgroundColor: Colors.indigo.shade900,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => vm?.loadCases(),
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
            // Clinical Confidentiality Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.indigo.shade50,
              child: Row(
                children: [
                  Icon(Icons.lock_person_outlined, size: 20, color: Colors.indigo.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Confidential Clinical Enclave: Authorized clinicians only. '
                      'Clinical notes and scores are strictly protected and never leaked to commanders or ACRs.',
                      style: TextStyle(fontSize: 11, color: Colors.indigo.shade900),
                    ),
                  ),
                ],
              ),
            ),
            if (vm?.isLoading ?? false)
              const LinearProgressIndicator(),

            // Content
            Expanded(
              child: cases.isEmpty
                  ? const Center(child: Text('No active clinical cases under management.'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Case Selector Horizontal Ribbon
                        const Text(
                          'Active Clinical Cases',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: cases.map((c) {
                              final isSelected = c.caseId == selectedCase?.caseId;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text('${c.rank} ${c.officerDisplayName}'),
                                  selected: isSelected,
                                  selectedColor: Colors.indigo.shade100,
                                  onSelected: (selected) {
                                    if (selected) {
                                      vm?.selectCase(c.caseId);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (selectedCase != null) ...[
                          // Case Summary Header Card
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
                                      Text(
                                        '${selectedCase.rank} ${selectedCase.officerDisplayName}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      Chip(
                                        label: Text(
                                          'C-SSRS: ${selectedCase.cssrsSeverity.toUpperCase()}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                        backgroundColor: selectedCase.cssrsSeverity == 'imminent' ||
                                                selectedCase.cssrsSeverity == 'high'
                                            ? Colors.red
                                            : Colors.indigo,
                                      ),
                                    ],
                                  ),
                                  Text('Unit: ${selectedCase.unit} • Case ID: ${selectedCase.caseId}',
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Active Concern: ${selectedCase.activeConcern}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),
                                  // Psychometric indicators row
                                  Row(
                                    children: [
                                      _MetricBadge(
                                        label: 'PHQ-9 Score',
                                        value: '${selectedCase.lastPhq9Score}/27',
                                        isElevated: selectedCase.lastPhq9Score >= 10,
                                      ),
                                      const SizedBox(width: 12),
                                      _MetricBadge(
                                        label: 'GAD-7 Score',
                                        value: '${selectedCase.lastGad7Score}/21',
                                        isElevated: selectedCase.lastGad7Score >= 10,
                                      ),
                                      const SizedBox(width: 12),
                                      _MetricBadge(
                                        label: 'Safety Plan',
                                        value: selectedCase.hasActiveSafetyPlan ? 'Active' : 'Missing',
                                        isElevated: !selectedCase.hasActiveSafetyPlan,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Safety Plan Action
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.security_rounded, color: Colors.indigo),
                              title: const Text('Stanley-Brown Safety Plan',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                selectedCase.hasActiveSafetyPlan
                                    ? 'Coping strategies, safe contacts, armory restriction codified'
                                    : 'Safety plan not yet initiated for this officer',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: OutlinedButton(
                                child: const Text('View Plan'),
                                onPressed: () {
                                  _showSafetyPlanDialog(context, vm);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Clinical Progress Notes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Clinical Session Notes & RTD',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.note_add_outlined, size: 16),
                                label: const Text('Add Note'),
                                onPressed: () {
                                  _showAddNoteDialog(context, vm, selectedCase.caseId);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (selectedCase.clinicalNotes.isEmpty)
                            const Text('No clinical notes recorded yet.')
                          else
                            ...selectedCase.clinicalNotes.map(
                              (note) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.comment_outlined, size: 18, color: Colors.indigo),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          note,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Emergency Break-Glass Action
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.crisis_alert_rounded, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Emergency Break-Glass Protocol',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'In circumstances of imminent threat to life or severe incapacity, licensed clinicians can trigger audited break-glass escalation to notify command/medical desks.',
                                  style: TextStyle(fontSize: 11, color: Colors.black87),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _showBreakGlassDialog(context, vm, selectedCase.officerId);
                                  },
                                  child: const Text('Trigger Emergency Break-Glass'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
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

  void _showAddNoteDialog(BuildContext context, CounsellorViewModel? vm, String caseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Clinical Follow-Up Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Session Observations',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rtdController,
              decoration: const InputDecoration(
                labelText: 'Return-to-Duty Recommendation',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Save Note'),
            onPressed: () {
              if (_noteController.text.isNotEmpty) {
                vm?.addFollowUpNote(
                  caseId: caseId,
                  note: _noteController.text.trim(),
                  rtdRecommendation: _rtdController.text.trim().isEmpty
                      ? 'Continue current duty status'
                      : _rtdController.text.trim(),
                );
                _noteController.clear();
                _rtdController.clear();
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSafetyPlanDialog(BuildContext context, CounsellorViewModel? vm) {
    final plan = vm?.currentSafetyPlan;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stanley-Brown Safety Plan'),
        content: plan == null
            ? const Text('Safety plan details not found.')
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Warning Signs:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...plan.warningSigns.map((w) => Text('• $w', style: const TextStyle(fontSize: 12))),
                    const SizedBox(height: 8),
                    const Text('Internal Coping:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...plan.internalCopingStrategies.map((c) => Text('• $c', style: const TextStyle(fontSize: 12))),
                    const SizedBox(height: 8),
                    const Text('Armory / Environmental Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...plan.environmentalSafetySteps.map((s) => Text('• $s', style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showBreakGlassDialog(BuildContext context, CounsellorViewModel? vm, String officerId) {
    final justController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Audited Emergency Break-Glass'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WARNING: This action is recorded permanently in the immutable audit log and reviewed by medical oversight.',
              style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: justController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Clinical Justification (min 15 chars)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Confirm Break-Glass'),
            onPressed: () {
              if (justController.text.trim().length >= 15) {
                vm?.triggerEmergencyBreakGlass(
                  targetOfficerId: officerId,
                  reasonCode: 'imminent_danger',
                  justification: justController.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audited emergency break-glass event recorded.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool isElevated;

  const _MetricBadge({
    required this.label,
    required this.value,
    required this.isElevated,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isElevated ? Colors.red.shade50 : Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isElevated ? Colors.red.shade300 : Colors.indigo.shade200),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isElevated ? Colors.red.shade800 : Colors.indigo.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
