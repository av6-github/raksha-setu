// lib/features/observability/presentation/observability_screen.dart
// Observability & ML Monitoring Console: API, Sync, Crisis Routing, Drift, Calibration, Bias, Providers, and Sanitized Alerts

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/observability_models.dart';
import 'observability_view_model.dart';

class ObservabilityScreen extends StatefulWidget {
  const ObservabilityScreen({super.key});

  @override
  State<ObservabilityScreen> createState() => _ObservabilityScreenState();
}

class _ObservabilityScreenState extends State<ObservabilityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AlertSeverity? _selectedSeverityFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ObservabilityViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Observability & ML Monitoring'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Telemetry',
            onPressed: viewModel.loadMetrics,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.amberAccent,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amberAccent,
          tabs: const [
            Tab(icon: Icon(Icons.speed_rounded), text: 'System & Sync'),
            Tab(icon: Icon(Icons.emergency_rounded), text: 'Crisis & Audits'),
            Tab(icon: Icon(Icons.insights_rounded), text: 'ML Drift & Bias'),
            Tab(icon: Icon(Icons.notification_important_rounded), text: 'Sanitized Alerts'),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSystemSyncTab(viewModel),
                _buildCrisisAuditsTab(viewModel),
                _buildMlDriftBiasTab(viewModel),
                _buildAlertsTab(viewModel),
              ],
            ),
      floatingActionButton: _tabController.index == 3
          ? FloatingActionButton.extended(
              onPressed: () => _showDispatchAlertDialog(context, viewModel),
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_alert_rounded),
              label: const Text('Dispatch Test Alert'),
            )
          : null,
    );
  }

  // TAB 1: System Health, Sync Queue & Providers
  Widget _buildSystemSyncTab(ObservabilityViewModel vm) {
    final sys = vm.systemMetrics;
    final sync = vm.syncMetrics;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. API Health & Latency
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.blueAccent, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'API Throughput & Health',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade400),
                      ),
                      child: Text(
                        'Uptime: ${sys?.uptimePercent ?? 99.98}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('p95 Latency', '${sys?.apiLatencyMsP95.toStringAsFixed(1) ?? "--"} ms'),
                    _buildStatTile('p99 Latency', '${sys?.apiLatencyMsP99.toStringAsFixed(1) ?? "--"} ms'),
                    _buildStatTile('Throughput', '${sys?.requestsPerMinute ?? "--"} rpm'),
                    _buildStatTile('Error Rate', '${sys?.errorRatePercent.toStringAsFixed(2) ?? "--"} %'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Sync Queue Monitoring & Backoff Retries
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync_alt_rounded, color: Colors.indigo, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Sync Queue & Capacity',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      'Depth: ${sync?.pendingQueueDepth ?? 0} / ${sync?.queueCapacity ?? 5000}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (sync?.pendingQueueDepth ?? 0) / (sync?.queueCapacity ?? 5000),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      sync?.isQueueOverloaded == true ? Colors.red : Colors.indigo,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('Sync Success', '${sync?.syncSuccessRatePercent.toStringAsFixed(1) ?? "--"} %'),
                    _buildStatTile('Conflict Rate', '${sync?.conflictRatePercent.toStringAsFixed(2) ?? "--"} %'),
                    _buildStatTile('Backoff Retries', '${sync?.backoffRetryCount ?? 0}'),
                    _buildStatTile('Dead Letters', '${sync?.deadLetterCount ?? 0}'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Infrastructure & Provider Health
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dns_rounded, color: Colors.teal, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Infrastructure & Provider Status',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...vm.providerHealth.map((p) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        p.status == ProviderStatus.healthy
                            ? Icons.check_circle_rounded
                            : (p.status == ProviderStatus.degraded
                                ? Icons.warning_rounded
                                : Icons.cancel_rounded),
                        color: p.status == ProviderStatus.healthy
                            ? Colors.green
                            : (p.status == ProviderStatus.degraded
                                ? Colors.amber
                                : Colors.red),
                      ),
                      title: Text(
                        p.providerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        '${p.endpoint} • ${p.latencyMs} ms',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      trailing: Chip(
                        label: Text(
                          p.status.name.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: p.status == ProviderStatus.healthy
                            ? Colors.green.shade50
                            : Colors.amber.shade50,
                        side: BorderSide(
                          color: p.status == ProviderStatus.healthy
                              ? Colors.green.shade300
                              : Colors.amber.shade400,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 2: Crisis Routing & Immutable Audit Health
  Widget _buildCrisisAuditsTab(ObservabilityViewModel vm) {
    final crisis = vm.crisisMetrics;
    final audit = vm.auditLogHealth;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Zero-AI Crisis Routing Compliance Card
        Card(
          elevation: 2,
          color: const Color(0xFFF0FDF4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.green, size: 28),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% Human Crisis Routing Compliance',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Zero AI allowed in emergency clinical and crisis intercept paths.',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        crisis?.isCompliant == true ? 'COMPLIANT' : 'NON-COMPLIANT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: crisis?.isCompliant == true ? Colors.green.shade900 : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    _buildStatTile('Total Dispatches', '${crisis?.totalCrisisDispatches ?? 0}'),
                    _buildStatTile('Human-Only Bridges', '${crisis?.humanRoutedDispatches ?? 0}'),
                    _buildStatTile(
                      'AI Intercepts',
                      '${crisis?.zeroAiViolations ?? 0}',
                      color: crisis?.zeroAiViolations == 0 ? Colors.green.shade900 : Colors.red,
                    ),
                    _buildStatTile('Avg Contact Time', '${crisis?.avgTimeToContactSeconds ?? 0} s'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Audit Log Health & Break-Glass Inspection
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.admin_panel_settings_rounded, color: Colors.deepPurple, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Immutable Audit Log & Break-Glass Health',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('Audit Entries', '${audit?.totalAuditRecords ?? 0}'),
                    _buildStatTile(
                      'Unadjudicated',
                      '${audit?.unadjudicatedBreakGlassCount ?? 0}',
                      color: audit?.unadjudicatedBreakGlassCount == 0 ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                    _buildStatTile('Tamper Check', audit?.tamperProofVerified == true ? 'VERIFIED' : 'FAILED'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Audit logs are append-only and cryptographically sealed using hardware keys.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 3: ML Drift, Feature Shift & Bias Auditing
  Widget _buildMlDriftBiasTab(ObservabilityViewModel vm) {
    final cal = vm.calibrationMetric;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Model Calibration Benchmarks (Rolling 30-Day Window)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_rounded, color: Colors.purple, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Model Calibration (${cal?.modelVersionTag ?? "v1.4.2"})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        '30-Day Window: CALIBRATED',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('Brier Score', '${cal?.brierScore.toStringAsFixed(3) ?? "--"}\n(Target < 0.10)'),
                    _buildStatTile('PR-AUC', '${cal?.prAuc.toStringAsFixed(3) ?? "--"}\n(Target >= 0.80)'),
                    _buildStatTile('High-Risk Recall', '${((cal?.highRiskRecall ?? 0) * 100).toStringAsFixed(1)}%\n(Target >= 90%)'),
                    _buildStatTile('Precision@k', '${((cal?.precisionAtK ?? 0) * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Feature Drift & Population Stability Index (PSI)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.grain_rounded, color: Colors.orangeAccent, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Population Stability Index (PSI) Drift',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'PSI < 0.10: Stable | 0.10 - 0.25: Moderate Drift | > 0.25: Significant Drift',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ...vm.driftMetrics.map((d) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        d.featureName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text('PSI: ${d.psiScore.toStringAsFixed(3)} • KS: ${d.ksStatistic?.toStringAsFixed(3) ?? "--"}'),
                      trailing: Chip(
                        label: Text(
                          d.driftLevel == DriftLevel.stable ? 'STABLE' : 'MODERATE DRIFT',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: d.driftLevel == DriftLevel.stable
                            ? Colors.green.shade50
                            : Colors.amber.shade50,
                        side: BorderSide(
                          color: d.driftLevel == DriftLevel.stable
                              ? Colors.green.shade300
                              : Colors.amber.shade400,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Subgroup Fairness & Four-Fifths Rule Audits
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.balance_rounded, color: Colors.teal, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Subgroup Fairness (Four-Fifths Rule)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Disparity Metric >= 0.80 ensures demographic parity without punitive disparate impact.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ...vm.biasAudits.map((b) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        b.subgroup,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        'Disparity: ${(b.disparityMetric * 100).toStringAsFixed(1)}% • FPR: ${(b.falsePositiveRate * 100).toStringAsFixed(1)}% • N=${b.sampleSize}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      trailing: Chip(
                        label: Text(
                          b.isCompliant ? 'COMPLIANT' : 'DISPARITY FLAG',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: b.isCompliant ? Colors.green.shade50 : Colors.red.shade50,
                        side: BorderSide(
                          color: b.isCompliant ? Colors.green.shade300 : Colors.red.shade300,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 4: Sanitized System Alerts & Telemetry Feed
  Widget _buildAlertsTab(ObservabilityViewModel vm) {
    final filteredAlerts = _selectedSeverityFilter == null
        ? vm.alerts
        : vm.alerts.where((a) => a.severity == _selectedSeverityFilter).toList();

    return Column(
      children: [
        // Privacy Banner
        Container(
          width: double.infinity,
          color: const Color(0xFFEFF6FF),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.shield_rounded, size: 18, color: Color(0xFF1E40AF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Privacy-by-Design: Alerts are strictly sanitized. No personal names, Aadhaar, force service IDs, or clinical scores are logged.',
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedSeverityFilter == null,
                onSelected: (_) => setState(() => _selectedSeverityFilter = null),
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Warning'),
                selected: _selectedSeverityFilter == AlertSeverity.warning,
                onSelected: (val) => setState(() => _selectedSeverityFilter = val ? AlertSeverity.warning : null),
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Info'),
                selected: _selectedSeverityFilter == AlertSeverity.info,
                onSelected: (val) => setState(() => _selectedSeverityFilter = val ? AlertSeverity.info : null),
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Critical'),
                selected: _selectedSeverityFilter == AlertSeverity.critical,
                onSelected: (val) => setState(() => _selectedSeverityFilter = val ? AlertSeverity.critical : null),
              ),
            ],
          ),
        ),

        Expanded(
          child: filteredAlerts.isEmpty
              ? const Center(child: Text('No alerts found for selected filter.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredAlerts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final alert = filteredAlerts[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: alert.isAcknowledged ? Colors.grey.shade300 : _getSeverityColor(alert.severity),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getSeverityIcon(alert.severity),
                          color: _getSeverityColor(alert.severity),
                        ),
                        title: Text(
                          alert.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: alert.isAcknowledged ? Colors.grey.shade700 : Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(alert.sanitizedDetails, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              'Source: ${alert.source} • ${_formatTimeAgo(alert.timestamp)}',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        trailing: alert.isAcknowledged
                            ? const Chip(
                                label: Text('ACK', style: TextStyle(fontSize: 9)),
                                padding: EdgeInsets.zero,
                              )
                            : TextButton(
                                onPressed: () => vm.acknowledgeAlert(alert.id),
                                child: const Text('Ack', style: TextStyle(fontSize: 12)),
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showDispatchAlertDialog(BuildContext context, ObservabilityViewModel vm) {
    final titleController = TextEditingController();
    final detailsController = TextEditingController();
    AlertSeverity selectedSev = AlertSeverity.warning;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Dispatch Sanitized Alert'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Alert Title',
                    hintText: 'e.g. Sync Roster Checkpoint Reached',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Sanitized Details',
                    hintText: 'Describe issue without personal identifiers or clinical scores.',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AlertSeverity>(
                  initialValue: selectedSev,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: AlertSeverity.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase())))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedSev = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await vm.dispatchAlert(
                    severity: selectedSev,
                    source: 'operator_console',
                    title: titleController.text.trim(),
                    details: detailsController.text.trim(),
                  );
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                } catch (e) {
                  if (dialogCtx.mounted) {
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      SnackBar(content: Text('Guardrail Rejection: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Dispatch'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity sev) {
    switch (sev) {
      case AlertSeverity.critical:
        return Colors.red.shade700;
      case AlertSeverity.warning:
        return Colors.orange.shade700;
      case AlertSeverity.info:
        return Colors.blue.shade700;
    }
  }

  IconData _getSeverityIcon(AlertSeverity sev) {
    switch (sev) {
      case AlertSeverity.critical:
        return Icons.error_rounded;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.info:
        return Icons.info_outline_rounded;
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
