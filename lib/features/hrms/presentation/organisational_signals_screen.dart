// lib/features/hrms/presentation/organisational_signals_screen.dart
// Transparent review of organizational signals: leave history, duty rhythm, operational hardship, and dynamic leave application

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
                tooltip: 'Refresh',
                onPressed: viewModel.loadData,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showApplyLeaveSheet(context, viewModel),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Apply for Leave'),
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
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
                                Expanded(
                                  child: Text(
                                    'Systemic Operational Friction',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
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

                    // Leave History Section Header with Quick Apply Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Leave Applications & Operational Decisions',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _showApplyLeaveSheet(context, viewModel),
                          icon: const Icon(Icons.post_add_rounded, size: 16),
                          label: const Text('Apply', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (viewModel.leaves.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No leave records found. Tap "Apply" above to submit a leave request.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ...viewModel.leaves.map((leave) {
                        final isOpDenial = leave.isOperationalRejection;
                        final isApproved = leave.status.toLowerCase() == 'approved';
                        final isApplied = leave.status.toLowerCase() == 'applied';

                        Color badgeBg;
                        Color badgeFg;
                        if (isApproved) {
                          badgeBg = Colors.green.shade100;
                          badgeFg = Colors.green.shade900;
                        } else if (isOpDenial) {
                          badgeBg = Colors.amber.shade100;
                          badgeFg = Colors.amber.shade900;
                        } else if (isApplied) {
                          badgeBg = Colors.blue.shade100;
                          badgeFg = Colors.blue.shade900;
                        } else {
                          badgeBg = Colors.red.shade100;
                          badgeFg = Colors.red.shade900;
                        }

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
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        leave.statusDisplay,
                                        style: TextStyle(
                                          color: badgeFg,
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
                                if (leave.rejectionReason != null && leave.rejectionReason!.isNotEmpty) ...[
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
                                            'Remarks: ${leave.rejectionReason}',
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
                    Text(
                      'Deployment Exposure & Hardship Postings',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    if (viewModel.deployments.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No historical deployment records on file.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
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
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(d.location, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                                if (d.isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: TextStyle(color: Colors.green.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'COMPLETED',
                                      style: TextStyle(color: Colors.grey.shade800, fontSize: 10),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '${d.operationName ?? "General Deployment"} • ${d.durationMonths} months sustained exposure'
                              '${d.isHighHazard ? "\nHigh-Hazard Hardship Index: ${d.hardshipScore}/10 (Severe Operational Strain)" : "\nPeace Area Hardship: ${d.hardshipScore}/10"}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }),
                  ],
                ),
        );
      },
    );
  }

  void _showApplyLeaveSheet(BuildContext context, HrmsViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ApplyLeaveBottomSheet(viewModel: vm),
    );
  }
}

class _ApplyLeaveBottomSheet extends StatefulWidget {
  final HrmsViewModel viewModel;

  const _ApplyLeaveBottomSheet({required this.viewModel});

  @override
  State<_ApplyLeaveBottomSheet> createState() => _ApplyLeaveBottomSheetState();
}

class _ApplyLeaveBottomSheetState extends State<_ApplyLeaveBottomSheet> {
  final _reasonController = TextEditingController();
  String _selectedLeaveType = 'Casual Leave (CL)';
  DateTime _startDate = DateTime.now().add(const Duration(days: 2));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isSubmitting = false;

  final List<String> _leaveTypes = [
    'Casual Leave (CL)',
    'Annual / Earned Leave (EL)',
    'Medical Rest & Recuperation',
    'Compassionate Family Respite',
    'Special Operational Compensation Leave',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int get _durationDays => _endDate.difference(_startDate).inDays + 1;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 3));
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _submitLeave() async {
    setState(() {
      _isSubmitting = true;
    });

    final success = await widget.viewModel.applyLeave(
      leaveType: _selectedLeaveType,
      startDate: _startDate,
      endDate: _endDate,
      reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave application submitted for $_durationDays day(s). Status: Under Review.'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage ?? 'Failed to submit leave'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.assignment_outlined, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              Text(
                'Apply for Leave / Operational Respite',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Leave Type Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedLeaveType,
            decoration: const InputDecoration(
              labelText: 'Select Leave Category',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _leaveTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedLeaveType = val);
            },
          ),
          const SizedBox(height: 14),

          // Date Selection Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('${_startDate.day}/${_startDate.month}/${_startDate.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEndDate,
                  icon: const Icon(Icons.event, size: 16),
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Date', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('${_endDate.day}/${_endDate.month}/${_endDate.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Requested Duration:', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                Text('$_durationDays Day(s)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Reason Field
          TextField(
            controller: _reasonController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Remarks / Reason (Optional)',
              hintText: 'e.g., Domestic obligation, family welfare, rest & recuperation',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Protected by Welfare Firewall: Leave applications are routed through official HRMS channels without disclosing wellness scores or clinical assessments.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submitLeave,
            icon: _isSubmitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded),
            label: Text(_isSubmitting ? 'Submitting to HRMS...' : 'Submit Leave Request'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
