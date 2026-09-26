// lib/features/expansion/presentation/expansion_screen.dart
// Presentation screen for Phase 22: Multi-Sector Expansion, Workforce Adaptation, and Universal Firewall Verification

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/expansion_models.dart';
import 'expansion_view_model.dart';

class ExpansionScreen extends StatefulWidget {
  const ExpansionScreen({super.key});

  @override
  State<ExpansionScreen> createState() => _ExpansionScreenState();
}

class _ExpansionScreenState extends State<ExpansionScreen>
    with SingleTickerProviderStateMixin {
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
    final vm = context.watch<ExpansionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 22: Multi-Sector Expansion'),
        backgroundColor: const Color(0xFF1E1B4B), // Deep Indigo
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Expansion Metrics',
            onPressed: vm.loadMetrics,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amberAccent,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amberAccent,
          tabs: const [
            Tab(icon: Icon(Icons.domain_add_rounded), text: 'Sector Horizons'),
            Tab(icon: Icon(Icons.tune_rounded), text: 'Dynamic Adapter'),
            Tab(icon: Icon(Icons.verified_user_rounded), text: 'Universal Firewall'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSectorsTab(vm),
                _buildAdapterTab(vm),
                _buildFirewallTab(vm),
              ],
            ),
    );
  }

  // TAB 1: Sector Horizons & Workforce Reach
  Widget _buildSectorsTab(ExpansionViewModel vm) {
    final audit = vm.audit;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overview Summary Card
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
                    Icon(Icons.public_rounded, color: Colors.indigo, size: 26),
                    SizedBox(width: 8),
                    Text(
                      'National High-Stress Workforce Horizons',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Raksha Welfare architecture is built with domain-agnostic telemetry layers and configurable organizational hierarchies, enabling plug-and-play expansion to state police, disaster rescue, emergency response, and heavy civil workforces.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatTile('Cataloged Sectors', '${audit?.totalSectorsCataloged ?? 6} High-Stress Sectors'),
                    _buildStatTile('Projected Reach', '${audit?.aggregateWorkforceReach ?? 645000} Personnel'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Target Expansion Sector Profiles',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ...vm.profiles.map((p) => Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          child: Icon(_getSectorIcon(p.sector), color: Colors.indigo.shade800),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('${p.projectedPersonnel} Personnel • Plug & Play', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
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
                            '${p.readinessScore}% FIT',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(p.description, style: const TextStyle(fontSize: 12, height: 1.3)),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // TAB 2: Dynamic Sector Adapter Test Bench
  Widget _buildAdapterTab(ExpansionViewModel vm) {
    final active = vm.activeProfile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sector Selection Chips
        const Text(
          'Select Active Sector Profile to Demonstrate Adaptation:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: vm.profiles.map((p) {
              final isSelected = active?.sector == p.sector;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(p.title),
                  selected: isSelected,
                  onSelected: (_) => vm.selectSector(p.sector),
                  selectedColor: Colors.indigo.shade100,
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        if (active != null) ...[
          // Active Sector Header
          Card(
            elevation: 2,
            color: const Color(0xFFEEF2FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.indigo.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(_getSectorIcon(active.sector), color: Colors.indigo, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Active Adaptation: ${active.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('Crisis Routing: ${active.crisisHotline}', style: const TextStyle(fontSize: 12, color: Colors.indigo)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sector Stressors
          _buildSectionCard(
            title: 'Sector-Specific Operational Stressors',
            icon: Icons.psychology_rounded,
            items: active.operationalStressors,
          ),

          const SizedBox(height: 12),

          // Hierarchy Ranks
          _buildSectionCard(
            title: 'Mapped Organizational Rank Hierarchy',
            icon: Icons.military_tech_rounded,
            items: active.hierarchyRanks,
          ),

          const SizedBox(height: 12),

          // Custom Welfare Schemes
          _buildSectionCard(
            title: 'Integrated Welfare Schemes & Funds',
            icon: Icons.volunteer_activism_rounded,
            items: active.welfareSchemes,
          ),
        ],
      ],
    );
  }

  // TAB 3: Universal Welfare-HR Firewall & Governance
  Widget _buildFirewallTab(ExpansionViewModel vm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Universal Non-Negotiable Firewall Card
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
                    Icon(Icons.shield_rounded, color: Colors.green, size: 26),
                    SizedBox(width: 8),
                    Text(
                      'Universal Non-Negotiable Firewall Mandate',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF14532D)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Every expansion sector profile must legally enforce an unbreachable Welfare-HR firewall. '
                  'No check-in score, clinical assessment, or psychological disclosure may enter the employee’s '
                  'Annual Confidential Report (ACR), service book, annual appraisal dossier, or disciplinary records.',
                  style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF14532D)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Sector-Specific Statutory Firewall Guarantees',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ...vm.profiles.map((p) => Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.gavel_rounded, color: Colors.indigo, size: 22),
                title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    p.firewallStatutoryRule,
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ),
                trailing: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
              ),
            )),
      ],
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.indigo, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const Divider(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  IconData _getSectorIcon(ExpansionSector sector) {
    switch (sector) {
      case ExpansionSector.statePolice:
        return Icons.local_police_rounded;
      case ExpansionSector.disasterResponse:
        return Icons.crisis_alert_rounded;
      case ExpansionSector.emergencyServices:
        return Icons.fire_truck_rounded;
      case ExpansionSector.highStressGovernment:
        return Icons.train_rounded;
      case ExpansionSector.corporateWellness:
        return Icons.business_rounded;
      case ExpansionSector.internationalSecurity:
        return Icons.public_rounded;
    }
  }
}
