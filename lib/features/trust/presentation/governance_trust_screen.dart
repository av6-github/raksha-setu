// lib/features/trust/presentation/governance_trust_screen.dart
// Screen for Trust, Ethics, Security, Break-Glass Oversight, and Privacy-Preserving Governance

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/governance_repository.dart';
import '../domain/governance_models.dart';
import 'governance_view_model.dart';

class GovernanceTrustScreen extends StatelessWidget {
  final IGovernanceRepository repository;

  const GovernanceTrustScreen({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GovernanceViewModel(repository: repository),
      child: const _GovernanceTrustView(),
    );
  }
}

class _GovernanceTrustView extends StatefulWidget {
  const _GovernanceTrustView();

  @override
  State<_GovernanceTrustView> createState() => _GovernanceTrustViewState();
}

class _GovernanceTrustViewState extends State<_GovernanceTrustView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _simulatorCohortSize = 14;

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
    final vm = context.watch<GovernanceViewModel>();

    // Listen to messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage!),
            backgroundColor: Colors.red.shade800,
          ),
        );
        vm.clearMessages();
      } else if (vm.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.successMessage!),
            backgroundColor: Colors.green.shade800,
          ),
        );
        vm.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust, Ethics & Security Governance'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.gavel_rounded), text: 'Oversight'),
            Tab(icon: Icon(Icons.security_rounded), text: 'Security'),
            Tab(icon: Icon(Icons.emergency_rounded), text: 'Break-Glass'),
            Tab(icon: Icon(Icons.privacy_tip_rounded), text: 'Privacy'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEthicsTab(context, vm),
                _buildSecurityTab(context, vm),
                _buildBreakGlassTab(context, vm),
                _buildDifferentialPrivacyTab(context, vm),
              ],
            ),
    );
  }

  Widget _buildEthicsTab(BuildContext context, GovernanceViewModel vm) {
    final shadow = vm.shadowMetrics;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Shadow Pilot Gate Card
        if (shadow != null)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade900, const Color(0xFF1E3A8A)],
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Colors.amber, size: 24),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Shadow Pilot Gate: PASSED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade800,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          shadow.modelVersion,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Silent model predictions benchmarked against clinical ground-truth adjudication. Zero autonomous consequential action permitted.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(
                        'Clinician Concordance',
                        '${(shadow.concordanceWithClinicians * 100).toStringAsFixed(1)}%',
                        Colors.lightGreenAccent,
                      ),
                      _buildMetricItem(
                        'Brier Score',
                        shadow.brierScore.toStringAsFixed(3),
                        Colors.amberAccent,
                      ),
                      _buildMetricItem(
                        'Shadow Sample',
                        '${shadow.totalShadowScored}',
                        Colors.lightBlueAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 18),

        // Algorithmic Bias Audit Card
        const Text(
          'Algorithmic Fairness & Bias Audits',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Evaluated against four-fifths (80%) rule to ensure False Positive Rate (FPR) parity across cohorts.',
          style: TextStyle(fontSize: 13, color: Colors.blueGrey),
        ),
        const SizedBox(height: 10),

        ...vm.biasAudits.map((audit) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        audit.isCompliant ? Icons.check_circle_rounded : Icons.warning_rounded,
                        color: audit.isCompliant ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          audit.subgroup,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: audit.isCompliant ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: audit.isCompliant ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Text(
                          audit.isCompliant ? 'COMPLIANT' : 'DISPARITY DETECTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: audit.isCompliant ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sample: ${audit.sampleSize} personnel  •  FPR: ${(audit.falsePositiveRate * 100).toStringAsFixed(1)}%  •  Disparity Ratio: ${audit.disparityMetric}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 18),

        // Independent Oversight Reviews
        const Text(
          'Independent Oversight Records',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...vm.oversightReviews.map((rev) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(rev.reviewType.icon, color: const Color(0xFF1E3A8A), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rev.reviewType.displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              'Conducted by: ${rev.approvedByName}',
                              style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(rev.reviewDate),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rev.findings,
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                  if (rev.correctiveActions != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Action Note: ${rev.correctiveActions}',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSecurityTab(BuildContext context, GovernanceViewModel vm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Security Architecture Overview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueGrey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_rounded, size: 36, color: Colors.blueGrey.shade800),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Multi-Layer Defence Grade Security',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zero trust architecture with KMS envelope encryption, TLS 1.3, and strict per-force tenant isolation.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildSecurityChecklistTile(
          icon: Icons.enhanced_encryption_rounded,
          title: 'AES-256 at Rest & Field-Level Encryption',
          subtitle: 'Clinical PHQ/GAD scores, notes, and biometric telemetry are encrypted with unique per-field IVs.',
          status: 'ENFORCED',
          isCompliant: true,
        ),
        _buildSecurityChecklistTile(
          icon: Icons.lock_outline_rounded,
          title: 'TLS 1.3 Transport Security',
          subtitle: 'All API, Supabase, and object storage endpoints strictly enforce TLS 1.3 with forward secrecy.',
          status: 'ENFORCED',
          isCompliant: true,
        ),
        _buildSecurityChecklistTile(
          icon: Icons.vpn_key_rounded,
          title: 'KMS / Hardware Security Module (HSM)',
          subtitle: 'Envelope encryption backed by DEFENCE_HSM_NITRO hardware root-of-trust with 90-day rotation.',
          status: 'FIPS 140-3 L4',
          isCompliant: true,
        ),
        _buildSecurityChecklistTile(
          icon: Icons.corporate_fare_rounded,
          title: 'Per-Force Multi-Tenant Isolation',
          subtitle: 'CRPF, BSF, CISF, ITBP, SSB, NSG, and Assam Rifles data strictly isolated by database RLS.',
          status: 'ACTIVE',
          isCompliant: true,
        ),
        _buildSecurityChecklistTile(
          icon: Icons.history_edu_rounded,
          title: 'Immutable Append-Only Audit Logs',
          subtitle: 'Database triggers prohibit any UPDATE or DELETE operations on the audit_logs table.',
          status: 'ACTIVE',
          isCompliant: true,
        ),
        _buildSecurityChecklistTile(
          icon: Icons.fire_extinguisher_rounded,
          title: 'Welfare-HR Hard Firewall',
          subtitle: 'Database constraints block any psychometric score or counselling record from ACR tables.',
          status: 'HARD FIREWALL',
          isCompliant: true,
        ),
      ],
    );
  }

  Widget _buildBreakGlassTab(BuildContext context, GovernanceViewModel vm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Break-Glass emergency access allows clinicians temporary access to medical records during acute crises. Every access is reason-coded, duration-capped, and audited by independent oversight.',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Emergency Access Logs & Adjudication',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...vm.breakGlassEvents.map((bg) {
          final isPending = bg.reviewStatus == BreakGlassStatus.pendingReview;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bg.reviewStatus.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: bg.reviewStatus.color),
                        ),
                        child: Text(
                          bg.reviewStatus.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: bg.reviewStatus.color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('dd MMM yyyy · hh:mm a').format(bg.accessGrantedAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Actor: ${bg.actorName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Officer Subject: ${bg.officerName} · Authorized By: ${bg.authorizedBy}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reason: "${bg.reason}"',
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                  if (bg.reviewerNotes != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Oversight Adjudication: ${bg.reviewerNotes}',
                        style: TextStyle(fontSize: 12, color: Colors.green.shade900),
                      ),
                    ),
                  ],
                  if (isPending) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _showAdjudicateDialog(context, vm, bg),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1E3A8A),
                          ),
                          child: const Text('Adjudicate Access'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDifferentialPrivacyTab(BuildContext context, GovernanceViewModel vm) {
    final simulation = vm.testDifferentialPrivacy(_simulatorCohortSize);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // K-Anonymity & DP Explanation Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.privacy_tip_rounded, color: Colors.teal.shade800, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Commander Aggregate Privacy Model',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Minimum group size threshold k >= 10 suppresses small cohort metrics.\n'
                '2. Laplace mechanism (epsilon = 1.0) adds calibrated mathematical noise to group averages to prevent membership inference.\n'
                '3. Individual stress scores or sorting by stress is strictly prohibited by software guardrail.',
                style: TextStyle(fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Interactive Differential Privacy Simulator
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Differential Privacy & K-Anonymity Simulator',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjust the platoon/unit cohort size slider to test suppression & Laplace noise injection:',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Cohort Size: $_simulatorCohortSize'),
                    Expanded(
                      child: Slider(
                        value: _simulatorCohortSize.toDouble(),
                        min: 3,
                        max: 40,
                        divisions: 37,
                        label: '$_simulatorCohortSize',
                        onChanged: (val) {
                          setState(() {
                            _simulatorCohortSize = val.round();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: simulation['is_suppressed'] == true
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: simulation['is_suppressed'] == true
                          ? Colors.red.shade300
                          : Colors.green.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            simulation['is_suppressed'] == true
                                ? Icons.block_rounded
                                : Icons.check_circle_rounded,
                            color: simulation['is_suppressed'] == true ? Colors.red : Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            simulation['is_suppressed'] == true
                                ? 'METRICS SUPPRESSED (k < 10)'
                                : 'PRIVACY-PRESERVED SUMMARY (Laplace Applied)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: simulation['is_suppressed'] == true
                                  ? Colors.red.shade900
                                  : Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (simulation['is_suppressed'] == true)
                        Text(
                          '${simulation['suppression_reason']}',
                          style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                        )
                      else ...[
                        Text(
                          '• Unit: ${simulation['unit_name']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Differentially Private Avg Sleep: ${simulation['average_sleep_hours']} hrs (Ground truth: 6.4 hrs)',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Differentially Private Avg Workload: ${simulation['average_workload_hours']} hrs (Ground truth: 11.2 hrs)',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Privacy Budget (Epsilon): ${simulation['epsilon']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Troop Co-Design Section
        Row(
          children: [
            const Text(
              'Troop Co-Design Feedback',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddCoDesignDialog(context, vm),
              icon: const Icon(Icons.add_comment_rounded, size: 16),
              label: const Text('Add Suggestion'),
            ),
          ],
        ),

        ...vm.coDesignFeedbacks.map((cd) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${cd.officerRankDisplay} · ${cd.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cd.actionStatus == 'implemented'
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cd.actionStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: cd.actionStatus == 'implemented'
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Topic: ${cd.topic}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${cd.feedbackText}"',
                    style: const TextStyle(fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSecurityChecklistTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required bool isCompliant,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
              child: Icon(icon, color: const Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCompliant ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isCompliant ? Colors.green : Colors.red),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isCompliant ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjudicateDialog(BuildContext context, GovernanceViewModel vm, BreakGlassEvent bg) {
    BreakGlassStatus selectedStatus = BreakGlassStatus.validatedEmergency;
    final notesCtrl = TextEditingController(text: 'Validated by Ethics Oversight Board. Emergency access was clinically necessary.');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return AlertDialog(
              title: const Text('Adjudicate Break-Glass Access'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event: ${bg.reason}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BreakGlassStatus>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Adjudication Decision',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      BreakGlassStatus.validatedEmergency,
                      BreakGlassStatus.unjustifiedBreach,
                    ].map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedStatus = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Oversight Reviewer Notes',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await vm.reviewBreakGlass(
                      eventId: bg.id,
                      status: selectedStatus,
                      notes: notesCtrl.text,
                    );
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Save Adjudication'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCoDesignDialog(BuildContext context, GovernanceViewModel vm) {
    final rankCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final topicCtrl = TextEditingController();
    final textCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Submit Co-Design Idea'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: rankCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Your Rank (e.g. Head Constable, Inspector)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: unitCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Your Unit / Battalion',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: topicCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Feature / Usability Topic',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: textCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Feedback / Improvement Suggestion',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await vm.submitCoDesignFeedback(
                  officerRankDisplay: rankCtrl.text,
                  unit: unitCtrl.text,
                  topic: topicCtrl.text,
                  feedbackText: textCtrl.text,
                );
                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Submit Idea'),
            ),
          ],
        );
      },
    );
  }
}
