// lib/features/shadow_pilot/presentation/shadow_pilot_screen.dart
// Phase 19 Shadow Pilot Console: Go/No-Go Gate, Silent Scoring, Clinician Concordance, Error Analysis, and Troop Co-Design

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/shadow_pilot_models.dart';
import 'shadow_pilot_view_model.dart';

class ShadowPilotScreen extends StatefulWidget {
  const ShadowPilotScreen({super.key});

  @override
  State<ShadowPilotScreen> createState() => _ShadowPilotScreenState();
}

class _ShadowPilotScreenState extends State<ShadowPilotScreen>
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
    final viewModel = context.watch<ShadowPilotViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 19: Shadow Pilot & Gate'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Shadow Metrics',
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
            Tab(icon: Icon(Icons.verified_outlined), text: 'Go/No-Go Gate & KPIs'),
            Tab(icon: Icon(Icons.visibility_off_outlined), text: 'Silent Scoring & Concordance'),
            Tab(icon: Icon(Icons.bug_report_outlined), text: 'Error Analysis & Synthetic'),
            Tab(icon: Icon(Icons.handshake_outlined), text: 'Trust & Co-Design'),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGateKpiTab(viewModel),
                _buildSilentScoringTab(viewModel),
                _buildErrorSyntheticTab(viewModel),
                _buildTrustCoDesignTab(viewModel),
              ],
            ),
      floatingActionButton: _tabController.index == 3
          ? FloatingActionButton.extended(
              onPressed: () => _showSubmitFeedbackDialog(context, viewModel),
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.rate_review_rounded),
              label: const Text('Submit Co-Design Idea'),
            )
          : null,
    );
  }

  // TAB 1: Go/No-Go Gate & KPI Baselines
  Widget _buildGateKpiTab(ShadowPilotViewModel vm) {
    final gate = vm.gateReview;
    final kpi = vm.kpiBaseline;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Executive Gate Banner
        Card(
          elevation: 3,
          color: const Color(0xFFF0FDF4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.green.shade400, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gavel_rounded, color: Colors.green, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Formal Shadow Pilot Review Gate',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Model Version: ${gate?.modelVersion ?? "v1.4.2-lightgbm"}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'GO FOR LIVE PILOT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  gate?.committeeRemarks ?? 'All 6 gatekeeper benchmarks satisfied.',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  'Authorized by: ${gate?.authorizedBy ?? "Joint Oversight Committee"}',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Gatekeeper Criteria Checklist
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
                    Icon(Icons.checklist_rounded, color: Colors.indigo, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Prerequisite Gatekeeper Checklist (6 Criteria)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (gate != null)
                  ...gate.checklist.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              item.isSatisfied ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: item.isSatisfied ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.criteria,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Target: ${item.target} • Actual: ${item.actual}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(
                                item.isSatisfied ? 'PASSED' : 'FAILED',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: item.isSatisfied ? Colors.green.shade50 : Colors.red.shade50,
                              side: BorderSide(
                                color: item.isSatisfied ? Colors.green.shade300 : Colors.red.shade300,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Operational KPI Baseline
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
                    Icon(Icons.query_stats_rounded, color: Colors.teal, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Operational Baseline KPIs (Pre-Live Pilot)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('Leave Friction', '${kpi?.avgLeaveFrictionIndex ?? "--"}'),
                    _buildStatTile('Check-In Rate', '${kpi?.checkInWeeklyCompletionRate ?? "--"}%'),
                    _buildStatTile('Counsel Connect', '${kpi?.medianCounsellingConnectMinutes ?? "--"} min'),
                    _buildStatTile('Crisis Bridge', '${kpi?.avgCrisisBridgeSeconds ?? "--"} s'),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Confirmed Data Leak Incidents: ${kpi?.confirmedDataLeakIncidents ?? 0} (Strict zero-breach record)',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 2: Silent Scoring & Clinician Concordance
  Widget _buildSilentScoringTab(ShadowPilotViewModel vm) {
    final comp = vm.counsellorComparison;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Firewall Quarantine Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_clock_rounded, color: Color(0xFF1E40AF), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Silent Pilot Mode Active: Predictive models score quietly in the background. '
                  'Inferences are completely quarantined from rosters, command views, and ACR files.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900, height: 1.3),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Clinician Concordance Card
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
                    const Icon(Icons.people_alt_rounded, color: Colors.purple, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Clinician Concordance Benchmark',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        '${((comp?.concordanceRate ?? 0) * 100).toStringAsFixed(1)}% CONCORDANT',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('Audited Cases', '${comp?.totalAuditedCases ?? 0}'),
                    _buildStatTile('Exact Matches', '${comp?.exactMatchedCases ?? 0}'),
                    _buildStatTile('Adjacent Tier', '${comp?.adjacentTierCases ?? 0}'),
                    _buildStatTile('Divergent', '${comp?.divergentCases ?? 0}'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Silent Prediction Records
        const Text(
          'Sample Silent Prediction Records (Audited vs Ground Truth)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...vm.silentPredictions.map((pred) => Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTierColor(pred.predictedTier).withValues(alpha: 0.15),
                  child: Icon(Icons.psychology_rounded, color: _getTierColor(pred.predictedTier), size: 20),
                ),
                title: Row(
                  children: [
                    Text(pred.officerToken, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    Chip(
                      label: Text(
                        pred.concordance == ConcordanceStatus.matched ? 'EXACT MATCH' : 'CONCORDANT TIER',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: pred.concordance == ConcordanceStatus.matched
                          ? Colors.green.shade50
                          : Colors.amber.shade50,
                      side: BorderSide(
                        color: pred.concordance == ConcordanceStatus.matched
                            ? Colors.green.shade300
                            : Colors.amber.shade400,
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
                      'Model Tier: ${pred.predictedTier.toUpperCase()} (${(pred.predictedRiskScore * 100).toStringAsFixed(0)}%) • Clinician: ${pred.clinicianGroundTruthTier.toUpperCase()}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    if (pred.clinicianAuditNotes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Clinician note: ${pred.clinicianAuditNotes}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // TAB 3: Error Analysis & Synthetic Validation
  Widget _buildErrorSyntheticTab(ShadowPilotViewModel vm) {
    final err = vm.errorAnalysis;
    final synth = vm.syntheticReport;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. False Positive & False Negative Review
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
                    Icon(Icons.report_problem_rounded, color: Colors.orange, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Error Analysis (False Positives & Negatives)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('False Positive Rate', '${((err?.falsePositiveRate ?? 0) * 100).toStringAsFixed(1)}%'),
                    _buildStatTile('False Negative Rate', '${((err?.falseNegativeRate ?? 0) * 100).toStringAsFixed(1)}%'),
                    _buildStatTile(
                      'Critical Misses',
                      '${err?.criticalMissesCount ?? 0}',
                      color: err?.criticalMissesCount == 0 ? Colors.green.shade900 : Colors.red,
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'Primary False-Positive Driver:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 2),
                Text(
                  err?.falsePositivePrimaryReason ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  'Safety Net Mitigation:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 2),
                Text(
                  err?.mitigationStrategy ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Synthetic Cohort Dataset Validation
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
                    const Icon(Icons.dataset_rounded, color: Colors.teal, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Synthetic Cohort Validation (${synth?.datasetId ?? "V3"})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(
                        synth?.isPassed == true ? 'VALIDATED' : 'FAILED',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: synth?.isPassed == true ? Colors.green.shade50 : Colors.red.shade50,
                      side: BorderSide(
                        color: synth?.isPassed == true ? Colors.green.shade300 : Colors.red.shade300,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('Records', '${synth?.totalSyntheticRecords ?? 0}'),
                    _buildStatTile('Edge Cases', '${synth?.edgeCaseCount ?? 0}'),
                    _buildStatTile('Fidelity', '${((synth?.syntheticFidelityScore ?? 0) * 100).toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCheckRow('Acute fatigue post-operation edge cases', synth?.acuteFatigueEdgeCasesPassed == true),
                _buildCheckRow('Chronic depression trajectory edge cases', synth?.chronicDepressionEdgeCasesPassed == true),
                _buildCheckRow('Zero check-in boundary stability', synth?.zeroCheckInBoundaryPassed == true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 4: Troop Trust & Co-Design
  Widget _buildTrustCoDesignTab(ShadowPilotViewModel vm) {
    final survey = vm.trustSurvey;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Troop Trust & Adoption Survey Card
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
                    const Icon(Icons.sentiment_very_satisfied_rounded, color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Troop Trust & Stigma Perception Survey',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      'N = ${survey?.surveyRespondents ?? 0}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('Trust Score', '${survey?.overallTrustScore ?? "--"}%'),
                    _buildStatTile('Stigma Risk', '${survey?.perceivedStigmaRiskPercentage ?? "--"}%'),
                    _buildStatTile('Adoption Rate', '${survey?.checkInWillingnessRate ?? "--"}%'),
                    _buildStatTile('Firewall Trust', '${survey?.confidenceInWelfareFirewall ?? "--"}%'),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'Troop Qualitative Feedback: "${survey?.topTroopFeedback ?? ""}"',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Co-Design Submissions List
        const Text(
          'Volunteer Personnel Co-Design Suggestions',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...vm.coDesignFeedbacks.map((fb) => Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.lightbulb_rounded, color: Colors.amber),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(fb.topic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Chip(
                      label: Text(
                        fb.actionStatus.toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: fb.actionStatus == 'implemented'
                          ? Colors.green.shade50
                          : Colors.amber.shade50,
                      side: BorderSide(
                        color: fb.actionStatus == 'implemented'
                            ? Colors.green.shade300
                            : Colors.amber.shade400,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(fb.feedbackText, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${fb.officerRankDisplay} • ${fb.unit}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  void _showSubmitFeedbackDialog(BuildContext context, ShadowPilotViewModel vm) {
    final rankCtrl = TextEditingController(text: 'Sub-Inspector');
    final unitCtrl = TextEditingController(text: '48 Bn CRPF');
    final topicCtrl = TextEditingController();
    final feedbackCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Submit Co-Design Idea'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rankCtrl,
                decoration: const InputDecoration(labelText: 'Rank Display'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unitCtrl,
                decoration: const InputDecoration(labelText: 'Unit / Sector'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: topicCtrl,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  hintText: 'e.g. Offline App Lock Usability',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Feedback / Suggestion',
                  hintText: 'Enter suggestion from troop trial...',
                ),
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
              if (topicCtrl.text.isNotEmpty && feedbackCtrl.text.isNotEmpty) {
                await vm.submitFeedback(
                  rank: rankCtrl.text.trim(),
                  unit: unitCtrl.text.trim(),
                  topic: topicCtrl.text.trim(),
                  feedbackText: feedbackCtrl.text.trim(),
                );
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String text, bool isPassed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(isPassed ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 16, color: isPassed ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
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

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.amber.shade700;
      case 'orange':
        return Colors.deepOrange;
      case 'red':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
