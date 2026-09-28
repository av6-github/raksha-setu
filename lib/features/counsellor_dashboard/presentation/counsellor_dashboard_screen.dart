// lib/features/counsellor_dashboard/presentation/counsellor_dashboard_screen.dart
// Clinical Counsellor Portal: Active cases, psychometric reviews, Stanley-Brown safety plans,
// health test intake feed (PHQ-9/GAD-7), and emergency alerts
// Styled with Arctic Frost glassmorphism, persistent RakshaSetu branding, and zero-overflow layouts

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/aura_background.dart';
import '../../../shared/widgets/floating_dock.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../auth/presentation/auth_view_model.dart';
import 'counsellor_view_model.dart';

class CounsellorDashboardScreen extends StatefulWidget {
  final CounsellorViewModel? viewModel;

  const CounsellorDashboardScreen({super.key, this.viewModel});

  @override
  State<CounsellorDashboardScreen> createState() => _CounsellorDashboardScreenState();
}

class _CounsellorDashboardScreenState extends State<CounsellorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _noteController = TextEditingController();
  final _rtdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      final assessments = vm?.officerAssessments ?? [];
      final emergencies = vm?.emergencyAlerts ?? [];

      return Scaffold(
        backgroundColor: RakshaSetuColors.background,
        body: AuraBackground(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Consistent Header with RakshaSetu Branding
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                      child: AppHeader(
                        subtitle: 'Clinical Counsellor Portal • Authorized Care Enclave',
                        showBackButton: true,
                        onSignOut: () => authVm?.signOut(),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 19, color: RakshaSetuColors.azure),
                          tooltip: 'Refresh',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          onPressed: () => vm?.loadCases(),
                        ),
                      ),
                    ),

                    // Frosted TabBar Navigation
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: RakshaSetuColors.azure,
                        indicatorWeight: 3,
                        labelColor: RakshaSetuColors.navy,
                        unselectedLabelColor: RakshaSetuColors.slate500,
                        labelStyle: const TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 11),
                        tabs: const [
                          Tab(icon: Icon(Icons.medical_information_rounded, size: 16), text: 'Active Cases'),
                          Tab(icon: Icon(Icons.health_and_safety_rounded, size: 16), text: 'Test Results'),
                          Tab(icon: Icon(Icons.crisis_alert_rounded, size: 16), text: 'Emergency Alerts'),
                        ],
                      ),
                    ),

                    // Clinical Confidentiality Banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xB3E0F2FE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x660284C7)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_person_rounded, size: 15, color: RakshaSetuColors.azure),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Confidential Clinical Enclave: Therapy notes and scores are strictly protected and never leaked to ACRs.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (vm?.isLoading ?? false)
                      const LinearProgressIndicator(
                        minHeight: 2.5,
                        backgroundColor: Color(0x3322D3EE),
                        valueColor: AlwaysStoppedAnimation<Color>(RakshaSetuColors.azure),
                      ),

                    // Content View
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildCasesTab(cases, selectedCase, vm),
                              _buildAssessmentsTab(assessments),
                              _buildEmergenciesTab(emergencies, vm),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Pinned Bottom Dock
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: FloatingDock(currentRoute: '/counsellor'),
                ),
              ],
            ),
          ),
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

  Widget _buildCasesTab(List<dynamic> cases, dynamic selectedCase, CounsellorViewModel? vm) {
    if (cases.isEmpty) {
      return const Center(
        child: Text(
          'No active clinical cases under management.',
          style: TextStyle(fontFamily: 'Public Sans', fontSize: 13, color: RakshaSetuColors.slate500),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
      children: [
        // Case Selector Horizontal Ribbon
        const Text(
          'ACTIVE CLINICAL CASES',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 0.5,
            color: RakshaSetuColors.slate700,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: cases.map((c) {
              final isSelected = c.caseId == selectedCase?.caseId;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('${c.rank} ${c.officerDisplayName}', style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11.5)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0A1F2C),
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : RakshaSetuColors.slate700,
                  ),
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
        const SizedBox(height: 12),

        if (selectedCase != null) ...[
          // Case Summary Card
          LiquidGlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            borderLeftColor: selectedCase.cssrsSeverity == 'imminent' || selectedCase.cssrsSeverity == 'high'
                ? RakshaSetuColors.rose600
                : RakshaSetuColors.azure,
            borderLeftWidth: 3.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${selectedCase.rank} ${selectedCase.officerDisplayName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: RakshaSetuColors.slate900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: (selectedCase.cssrsSeverity == 'imminent' || selectedCase.cssrsSeverity == 'high')
                            ? const Color(0x26F43F5E)
                            : const Color(0x260284C7),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: (selectedCase.cssrsSeverity == 'imminent' || selectedCase.cssrsSeverity == 'high')
                              ? const Color(0x66F43F5E)
                              : const Color(0x660284C7),
                        ),
                      ),
                      child: Text(
                        'C-SSRS: ${selectedCase.cssrsSeverity.toUpperCase()}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: (selectedCase.cssrsSeverity == 'imminent' || selectedCase.cssrsSeverity == 'high')
                              ? RakshaSetuColors.rose600
                              : RakshaSetuColors.azure,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Unit: ${selectedCase.unit} • Case ID: ${selectedCase.caseId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Public Sans', color: RakshaSetuColors.slate500, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  'Active Concern: ${selectedCase.activeConcern}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w600, fontSize: 12, color: RakshaSetuColors.slate800),
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
                    const SizedBox(width: 6),
                    _MetricBadge(
                      label: 'GAD-7 Score',
                      value: '${selectedCase.lastGad7Score}/21',
                      isElevated: selectedCase.lastGad7Score >= 10,
                    ),
                    const SizedBox(width: 6),
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
          const SizedBox(height: 10),

          // Safety Plan Action Card
          LiquidGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0x260284C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security_rounded, color: RakshaSetuColors.azure, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stanley-Brown Safety Plan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 12.5, color: RakshaSetuColors.slate900),
                      ),
                      Text(
                        selectedCase.hasActiveSafetyPlan
                            ? 'Coping strategies & armory restriction codified'
                            : 'Safety plan not yet initiated for this officer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Public Sans', fontSize: 10.5, color: RakshaSetuColors.slate600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () => _showSafetyPlanDialog(context, vm),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0x660891B2)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    child: const Text('View Plan', style: TextStyle(fontFamily: 'Public Sans', fontSize: 10.5, fontWeight: FontWeight.w700, color: RakshaSetuColors.azure)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Clinical Progress Notes Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CLINICAL SESSION NOTES & RTD',
                style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5, color: RakshaSetuColors.slate700),
              ),
              SizedBox(
                height: 30,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.note_add_outlined, size: 14, color: Colors.white),
                  label: const Text('Add Note', style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1F2C),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  onPressed: () => _showAddNoteDialog(context, vm, selectedCase.caseId),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (selectedCase.clinicalNotes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No clinical notes recorded yet.',
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: RakshaSetuColors.slate500),
              ),
            )
          else
            ...selectedCase.clinicalNotes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: LiquidGlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.comment_outlined, size: 16, color: RakshaSetuColors.azure),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: RakshaSetuColors.slate800, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Emergency Break-Glass Action
          LiquidGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            borderLeftColor: RakshaSetuColors.rose600,
            borderLeftWidth: 3.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.crisis_alert_rounded, color: RakshaSetuColors.rose600, size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'EMERGENCY BREAK-GLASS PROTOCOL',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w800,
                          color: RakshaSetuColors.rose600,
                          fontSize: 11.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'In circumstances of imminent threat to life or severe incapacity, licensed clinicians can trigger audited break-glass escalation to notify command/medical desks.',
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, color: RakshaSetuColors.slate600, height: 1.35),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RakshaSetuColors.rose600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    onPressed: () => _showBreakGlassDialog(context, vm, selectedCase.officerId),
                    child: const Text('Trigger Emergency Break-Glass', style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildAssessmentsTab(List<Map<String, dynamic>> assessments) {
    if (assessments.isEmpty) {
      return const Center(
        child: Text(
          'No psychometric health assessments submitted yet.',
          style: TextStyle(fontFamily: 'Public Sans', fontSize: 13, color: RakshaSetuColors.slate500),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
      itemCount: assessments.length,
      itemBuilder: (context, index) {
        final a = assessments[index];
        final name = a['officer_name'] ?? 'Officer';
        final serviceNo = a['service_number'] ?? '—';
        final unit = a['unit'] ?? 'Unit';
        final type = a['assessment_type'] ?? 'Health Assessment';
        final score = a['total_score'] ?? 0;
        final maxScore = a['max_score'] ?? 27;
        final tier = (a['severity_tier'] ?? 'mild').toString().toUpperCase();
        final isCrisis = a['is_crisis_flagged'] == true || (a['phq9_item9_score'] ?? 0) > 0;
        final completedAt = DateTime.tryParse(a['completed_at'] ?? '') ?? DateTime.now();

        Color tierColor = RakshaSetuColors.emerald500;
        if (tier == 'MODERATE') tierColor = RakshaSetuColors.amber500;
        if (tier == 'SEVERE' || tier == 'CRISIS') tierColor = RakshaSetuColors.rose600;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            borderLeftColor: tierColor,
            borderLeftWidth: 3.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 14, color: RakshaSetuColors.slate900),
                          ),
                          Text(
                            '$serviceNo • $unit',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 10.5, color: RakshaSetuColors.slate500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '$tier TIER',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: tierColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700, fontSize: 12.5, color: RakshaSetuColors.slate800),
                      ),
                    ),
                    Text(
                      'Score: $score / $maxScore',
                      style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 13, color: tierColor),
                    ),
                  ],
                ),
                if (isCrisis) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0x26F43F5E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x66F43F5E)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: RakshaSetuColors.rose600, size: 15),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Item-9 Active Concern: Positive response indicating passive/active distress.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Public Sans', color: RakshaSetuColors.rose600, fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Completed: ${completedAt.day}/${completedAt.month}/${completedAt.year} at ${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontFamily: 'Public Sans', fontSize: 9.5, color: RakshaSetuColors.slate500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergenciesTab(List<Map<String, dynamic>> emergencies, CounsellorViewModel? vm) {
    if (emergencies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 44, color: RakshaSetuColors.emerald500),
            SizedBox(height: 10),
            Text(
              'No Active Crisis Alerts',
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 15, fontWeight: FontWeight.w800, color: RakshaSetuColors.slate900),
            ),
            SizedBox(height: 4),
            Text(
              'All personnel indicators are currently within acceptable thresholds.',
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, color: RakshaSetuColors.slate500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
      itemCount: emergencies.length,
      itemBuilder: (context, index) {
        final em = emergencies[index];
        final id = em['id'] ?? '';
        final name = em['officer_name'] ?? 'Officer';
        final serviceNo = em['service_number'] ?? '—';
        final unit = em['unit'] ?? 'Unit';
        final trigger = em['trigger_source'] ?? 'Emergency Trigger';
        final status = (em['status'] ?? 'escalated').toString().toUpperCase();
        final triggeredAt = DateTime.tryParse(em['triggered_at'] ?? '') ?? DateTime.now();
        final isAttending = status.contains('ATTENDING');

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            borderLeftColor: RakshaSetuColors.rose600,
            borderLeftWidth: 3.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.warning_rounded, color: RakshaSetuColors.rose600, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 14, color: RakshaSetuColors.slate900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAttending ? const Color(0x2610B981) : const Color(0x26F43F5E),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: isAttending ? const Color(0x6610B981) : const Color(0x66F43F5E),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isAttending ? RakshaSetuColors.emerald800 : RakshaSetuColors.rose600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('$serviceNo • $unit', style: const TextStyle(fontFamily: 'Public Sans', fontSize: 10.5, color: RakshaSetuColors.slate500)),
                const SizedBox(height: 6),
                Text(
                  'Trigger: $trigger',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w600, fontSize: 12, color: RakshaSetuColors.slate800),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Triggered: ${triggeredAt.hour.toString().padLeft(2, '0')}:${triggeredAt.minute.toString().padLeft(2, '0')} (${triggeredAt.day}/${triggeredAt.month})',
                      style: const TextStyle(fontFamily: 'Public Sans', fontSize: 10, color: RakshaSetuColors.slate500),
                    ),
                    if (!isAttending)
                      SizedBox(
                        height: 30,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 14, color: Colors.white),
                          label: const Text('Attend Alert', style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RakshaSetuColors.rose600,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                          ),
                          onPressed: () => vm?.acknowledgeCrisisAlert(id),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddNoteDialog(BuildContext context, CounsellorViewModel? vm, String caseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Clinical Follow-Up Note', style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 16)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A1F2C),
              foregroundColor: Colors.white,
            ),
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
        title: const Text('Stanley-Brown Safety Plan', style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 16)),
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
        title: const Text('Audited Emergency Break-Glass', style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WARNING: This action is recorded permanently in the immutable audit log and reviewed by medical oversight.',
              style: TextStyle(color: RakshaSetuColors.rose600, fontSize: 12, fontWeight: FontWeight.bold),
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
            style: ElevatedButton.styleFrom(backgroundColor: RakshaSetuColors.rose600, foregroundColor: Colors.white),
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isElevated ? const Color(0x26F43F5E) : const Color(0x260284C7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isElevated ? const Color(0x66F43F5E) : const Color(0x660284C7)),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 9.5, fontWeight: FontWeight.bold, color: RakshaSetuColors.slate600),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isElevated ? RakshaSetuColors.rose600 : RakshaSetuColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
