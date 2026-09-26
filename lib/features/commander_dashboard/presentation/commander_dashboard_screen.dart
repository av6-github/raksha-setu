// lib/features/commander_dashboard/presentation/commander_dashboard_screen.dart
// Commander Unit Overview: Aggregate readiness, fatigue indicators, roster recommendations,
// unit grievance/welfare reports, and binary operational availability

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../domain/roster_recommendation.dart';
import '../domain/unit_operational_metrics.dart';
import 'commander_view_model.dart';

class CommanderDashboardScreen extends StatefulWidget {
  final CommanderViewModel? viewModel;

  const CommanderDashboardScreen({super.key, this.viewModel});

  @override
  State<CommanderDashboardScreen> createState() => _CommanderDashboardScreenState();
}

class _CommanderDashboardScreenState extends State<CommanderDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final authVm = context.watch<AuthViewModel?>();

    Widget buildScaffold() {
      final metrics = vm?.metrics;
      final recommendations = vm?.recommendations ?? [];
      final roster = vm?.availabilityRoster ?? {};
      final unitReports = vm?.unitReports ?? [];

      return Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Commander Unit Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                'COL. RAJESH SHARMA • SECTOR BRIGADE HQ',
                style: TextStyle(fontSize: 10, color: Colors.amberAccent, letterSpacing: 1.1, fontWeight: FontWeight.w600),
              ),
            ],
          ),
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
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.amberAccent,
            labelColor: Colors.amberAccent,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard_rounded, size: 18), text: 'Readiness & Roster'),
              Tab(icon: Icon(Icons.assignment_outlined, size: 18), text: 'Unit Reports'),
              Tab(icon: Icon(Icons.timelapse_rounded, size: 18), text: 'Duty & Friction'),
            ],
          ),
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Readiness & Operational Roster
                  metrics == null
                      ? const Center(child: Text('Loading unit operational data...'))
                      : metrics.isSuppressed
                          ? _buildSuppressionCard(metrics)
                          : _buildReadinessTab(metrics, recommendations, roster, vm),

                  // Tab 2: Unit Anonymous Reports & Grievances
                  _buildUnitReportsTab(unitReports, vm),

                  // Tab 3: Duty & Leave Friction Analysis
                  _buildFrictionTab(metrics),
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

  Widget _buildSuppressionCard(UnitOperationalMetrics metrics) {
    return Padding(
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
    );
  }

  Widget _buildReadinessTab(
    UnitOperationalMetrics metrics,
    List<RosterRecommendation> recommendations,
    Map<String, String> roster,
    CommanderViewModel? vm,
  ) {
    return ListView(
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
              title: Text(
                entry.key,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green.shade50 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAvailable ? Colors.green.shade300 : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  isAvailable ? 'AVAILABLE' : 'MEDICALLY UNAVAILABLE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.green.shade900 : Colors.grey.shade900,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildUnitReportsTab(List<Map<String, dynamic>> reports, CommanderViewModel? vm) {
    if (reports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.blueGrey),
              SizedBox(height: 12),
              Text(
                'No Pending Unit Reports',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Zero active grievance or equipment deficiency reports submitted for this unit sector.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final r = reports[index];
        final id = r['id'] ?? '';
        final category = r['category'] ?? 'General Welfare';
        final text = r['report_text'] ?? '';
        final status = (r['status'] ?? 'submitted').toString().toUpperCase();
        final submittedAt = DateTime.tryParse(r['submitted_at'] ?? '') ?? DateTime.now();
        final isActionTaken = status == 'ACTION_TAKEN';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActionTaken ? Colors.green.shade900 : Colors.deepOrange.shade900,
                        ),
                      ),
                      backgroundColor: isActionTaken ? Colors.green.shade50 : Colors.deepOrange.shade50,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reported: ${submittedAt.day}/${submittedAt.month}/${submittedAt.year} • Protected Channel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ),
                    if (!isActionTaken) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 14),
                        label: const Text('Take Action', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: () => vm?.acknowledgeReport(id),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrictionTab(UnitOperationalMetrics? metrics) {
    if (metrics == null || metrics.isSuppressed) {
      return const Center(child: Text('Friction analytics suppressed for small detachments.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
                    SizedBox(width: 8),
                    Text(
                      'Unit Duty & Leave Friction Analysis',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Automated HRMS signals monitoring duty strain, night patrol rotations, and operational leave deferrals across ${metrics.unitName}.',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const Divider(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.nights_stay, color: Colors.white),
                  ),
                  title: const Text('High Fatigue Patrol Personnel'),
                  subtitle: const Text('Personnel exceeding 5 consecutive night rotations'),
                  trailing: Text(
                    '${metrics.highFatigueRosterPercent.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.event_busy, color: Colors.white),
                  ),
                  title: const Text('Consecutive Duty Violation Flags'),
                  subtitle: const Text('Personnel without mandatory 48-hour recuperative interval'),
                  trailing: Text(
                    '${metrics.consecutiveDutyFlagCount}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.beach_access, color: Colors.white),
                  ),
                  title: const Text('Leave Friction Index'),
                  subtitle: const Text('Ratio of operational leave applications denied or postponed'),
                  trailing: Text(
                    '${(metrics.leaveFrictionIndex * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
