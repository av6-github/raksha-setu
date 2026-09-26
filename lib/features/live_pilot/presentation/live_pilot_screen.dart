// lib/features/live_pilot/presentation/live_pilot_screen.dart
// Phase 20 Live Pilot Dashboard: Pilot vs Control Deployments, Comparative KPIs, Live Incidents, and Scale Certification

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/live_pilot_models.dart';
import 'live_pilot_view_model.dart';

class LivePilotScreen extends StatefulWidget {
  const LivePilotScreen({super.key});

  @override
  State<LivePilotScreen> createState() => _LivePilotScreenState();
}

class _LivePilotScreenState extends State<LivePilotScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final viewModel = context.watch<LivePilotViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 20: Live Pilot & Certification'),
        backgroundColor: const Color(0xFF0F766E), // Deep Teal
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Live Pilot Data',
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
            Tab(icon: Icon(Icons.military_tech_rounded), text: 'Deployments & Units'),
            Tab(icon: Icon(Icons.compare_arrows_rounded), text: 'Pilot vs Control Impact'),
            Tab(icon: Icon(Icons.security_rounded), text: 'Live Incidents & Safety'),
            Tab(icon: Icon(Icons.workspace_premium_rounded), text: 'Trust & Certification'),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDeploymentsTab(viewModel),
                _buildImpactTab(viewModel),
                _buildIncidentsTab(viewModel),
                _buildTrustCertTab(viewModel),
              ],
            ),
    );
  }

  // TAB 1: Deployments & Battalion Units
  Widget _buildDeploymentsTab(LivePilotViewModel vm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live Pilot Overview Card
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
                    Icon(Icons.shield_rounded, color: Color(0xFF0F766E), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Operational Field Trial Structure',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '3 Operational Pilot Battalions (3,180 personnel) evaluated against 3 matching Control SOP Battalions (3,110 personnel) across Counter-Insurgency, Internal Security, and High-Altitude Border deployments.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('Pilot Battalions', '3 Units (3,180 Troops)'),
                    _buildStatTile('Control Battalions', '3 Units (3,110 Troops)'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Unit Cards List
        const Text(
          'Staged Battalion Formations',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...vm.units.map((u) => Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: u.isPilotUnit ? Colors.teal.shade300 : Colors.grey.shade300,
                  width: u.isPilotUnit ? 1.5 : 1.0,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: u.isPilotUnit
                      ? Colors.teal.shade50
                      : Colors.grey.shade200,
                  child: Icon(
                    u.isPilotUnit ? Icons.verified_user_rounded : Icons.groups_rounded,
                    color: u.isPilotUnit ? Colors.teal.shade800 : Colors.grey.shade700,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(u.unitName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Chip(
                      label: Text(
                        u.isPilotUnit ? 'PILOT UNIT' : 'CONTROL SOP',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: u.isPilotUnit ? Colors.teal.shade50 : Colors.grey.shade100,
                      side: BorderSide(
                        color: u.isPilotUnit ? Colors.teal.shade400 : Colors.grey.shade400,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Sector: ${u.locationSector}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Type: ${_formatDeployment(u.deploymentType)} • ${u.activePersonnelCount} active personnel',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // TAB 2: Pilot vs Control KPI Impact
  Widget _buildImpactTab(LivePilotViewModel vm) {
    final comp = vm.comparison;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Comparison Header Card
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
                    const Icon(Icons.insights_rounded, color: Colors.green, size: 26),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        comp?.comparisonPeriod ?? '6-Month Field Trial',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Empirical comparative data comparing Raksha Welfare pilot units against matched control SOP units without digital intervention.',
                  style: TextStyle(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Comparative Metric Cards
        if (comp != null)
          ...comp.metrics.map((m) => Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              m.metricName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              '+${m.percentageImprovement}% IMPACT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PILOT UNIT',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    m.pilotValueDisplay,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CONTROL SOP',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    m.controlValueDisplay,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        m.interpretation,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // TAB 3: Live Incident & Safety Log
  Widget _buildIncidentsTab(LivePilotViewModel vm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Zero-AI & Audit Guarantee Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.green, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Zero-AI & Human Responder Guarantee: All crisis intercepts and safety plan dispatches are strictly assigned to human medical desk personnel.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF14532D), height: 1.3),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Live Operational Incidents & Intercepts',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ...vm.incidents.map((inc) => Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: inc.isResolved ? Colors.grey.shade300 : _getSeverityColor(inc.severity),
                ),
              ),
              child: ListTile(
                leading: Icon(
                  _getSeverityIcon(inc.severity),
                  color: _getSeverityColor(inc.severity),
                  size: 24,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${inc.unitName} • ${_formatIncidentType(inc.incidentType)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Chip(
                      label: Text(
                        inc.isResolved ? 'RESOLVED' : 'ACTIVE',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: inc.isResolved ? Colors.green.shade50 : Colors.red.shade50,
                      side: BorderSide(
                        color: inc.isResolved ? Colors.green.shade300 : Colors.red.shade300,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(inc.summary, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      'Responder: ${inc.humanResponder} (0 AI)',
                      style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                    ),
                    if (inc.resolutionNotes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Action: ${inc.resolutionNotes}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
                trailing: inc.isResolved
                    ? null
                    : TextButton(
                        onPressed: () => _showResolveDialog(context, vm, inc.incidentId),
                        child: const Text('Resolve', style: TextStyle(fontSize: 12)),
                      ),
              ),
            )),
      ],
    );
  }

  // TAB 4: Trust Tracking & Scale Certification
  Widget _buildTrustCertTab(LivePilotViewModel vm) {
    final cert = vm.certification;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Executive Scale Certification Card
        Card(
          elevation: 3,
          color: const Color(0xFFF0FDF4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.green.shade500, width: 2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Colors.green, size: 32),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operational Scale Certification',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Formal clearance for force-wide scaling under Phase 21',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'CERTIFIED FOR SCALE',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  cert?.remarks ?? '',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const Divider(height: 24),
                const Text(
                  'Authorizing Governance Sign-Offs:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildSignoffRow(Icons.medical_services_rounded, 'Clinical Authority', cert?.clinicalChairpersonSignoff ?? ''),
                _buildSignoffRow(Icons.gavel_rounded, 'Ethics Ombudsman', cert?.defenceOmbudsmanSignoff ?? ''),
                _buildSignoffRow(Icons.military_tech_rounded, 'Executive Command', cert?.directorGeneralSignoff ?? ''),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Longitudinal Trust Tracking Table
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
                    Icon(Icons.timeline_rounded, color: Colors.teal, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Longitudinal Trust & Stigma Evolution',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1.0),
                    2: FlexColumnWidth(1.0),
                    3: FlexColumnWidth(1.0),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade100),
                      children: const [
                        Padding(padding: EdgeInsets.all(6), child: Text('Milestone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        Padding(padding: EdgeInsets.all(6), child: Text('Pilot Trust', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        Padding(padding: EdgeInsets.all(6), child: Text('Control Trust', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        Padding(padding: EdgeInsets.all(6), child: Text('Stigma Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      ],
                    ),
                    ...vm.trustMeasurements.map((t) => TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(6), child: Text(t.milestone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('${t.pilotTrustScore}%', style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('${t.controlTrustScore}%', style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('${t.perceivedStigmaRate}%', style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))),
                          ],
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showResolveDialog(BuildContext context, LivePilotViewModel vm, String incidentId) {
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Resolve Live Incident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Confirm action taken by human clinician or welfare officer:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Resolution Summary',
                hintText: 'e.g. Respite leave approved, follow-up scheduled.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (notesCtrl.text.isNotEmpty) {
                await vm.resolveIncident(incidentId, notesCtrl.text.trim());
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignoffRow(IconData icon, String role, String person) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.teal.shade800),
          const SizedBox(width: 6),
          Text('$role: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Expanded(child: Text(person, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDeployment(DeploymentType type) {
    switch (type) {
      case DeploymentType.counterInsurgency:
        return 'Counter-Insurgency';
      case DeploymentType.highAltitudeBorder:
        return 'High-Altitude Border';
      case DeploymentType.internalSecurity:
        return 'Internal Security';
      case DeploymentType.peaceStation:
        return 'Peace Station';
    }
  }

  String _formatIncidentType(IncidentType type) {
    switch (type) {
      case IncidentType.crisisIntercept:
        return 'Crisis Intercept';
      case IncidentType.breakGlassAccess:
        return 'Break-Glass Access';
      case IncidentType.opsecMediaQuarantine:
        return 'OPSEC Media Quarantine';
      case IncidentType.leaveFrictionSpike:
        return 'Leave Friction Spike';
    }
  }

  Color _getSeverityColor(IncidentSeverity sev) {
    switch (sev) {
      case IncidentSeverity.critical:
        return Colors.red.shade700;
      case IncidentSeverity.high:
        return Colors.deepOrange;
      case IncidentSeverity.medium:
        return Colors.amber.shade800;
      case IncidentSeverity.low:
        return Colors.blue.shade700;
    }
  }

  IconData _getSeverityIcon(IncidentSeverity sev) {
    switch (sev) {
      case IncidentSeverity.critical:
        return Icons.error_rounded;
      case IncidentSeverity.high:
        return Icons.warning_rounded;
      case IncidentSeverity.medium:
        return Icons.info_rounded;
      case IncidentSeverity.low:
        return Icons.check_circle_outline_rounded;
    }
  }
}
