// lib/features/welfare_dashboard/presentation/welfare_dashboard_screen.dart
// Welfare Officer Console: Pseudonymised tiers, escalations, proactive outreach, and family pipeline

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../../risk/domain/risk_score.dart';
import '../domain/welfare_escalation.dart';
import 'welfare_view_model.dart';

class WelfareDashboardScreen extends StatefulWidget {
  final WelfareViewModel? viewModel;

  const WelfareDashboardScreen({super.key, this.viewModel});

  @override
  State<WelfareDashboardScreen> createState() => _WelfareDashboardScreenState();
}

class _WelfareDashboardScreenState extends State<WelfareDashboardScreen> with SingleTickerProviderStateMixin {
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

    Widget buildContent() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Welfare Officer Console'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => vm?.loadAll(),
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Sign Out',
              onPressed: () => authVm?.signOut(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.people_alt_outlined), text: 'Tiers'),
              Tab(icon: Icon(Icons.warning_amber_rounded), text: 'Escalations'),
              Tab(icon: Icon(Icons.family_restroom_rounded), text: 'Family Pipeline'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Welfare Firewall Guarantee Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.teal.shade50,
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, size: 20, color: Colors.teal.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pseudonymised Console: Operating under strict Welfare-HR Firewall. '
                      'Clinical therapy notes and unconsented identities are strictly quarantined.',
                      style: TextStyle(fontSize: 11, color: Colors.teal.shade900),
                    ),
                  ),
                ],
              ),
            ),
            if (vm?.isLoading ?? false)
              const LinearProgressIndicator(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTiersTab(context, vm),
                  _buildEscalationsTab(context, vm),
                  _buildFamilyPipelineTab(context, vm),
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
        builder: (context, _) => buildContent(),
      );
    }

    return buildContent();
  }

  Widget _buildTiersTab(BuildContext context, WelfareViewModel? vm) {
    final officers = vm?.officers ?? [];
    final selectedTier = vm?.selectedTierFilter;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All Tiers'),
                selected: selectedTier == null,
                onSelected: (_) => vm?.filterByTier(null),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Red Tier'),
                selected: selectedTier == RiskTier.red,
                selectedColor: Colors.red.shade100,
                onSelected: (_) => vm?.filterByTier(RiskTier.red),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Orange Tier'),
                selected: selectedTier == RiskTier.orange,
                selectedColor: Colors.orange.shade100,
                onSelected: (_) => vm?.filterByTier(RiskTier.orange),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Yellow Tier'),
                selected: selectedTier == RiskTier.yellow,
                selectedColor: Colors.amber.shade100,
                onSelected: (_) => vm?.filterByTier(RiskTier.yellow),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Green Tier'),
                selected: selectedTier == RiskTier.green,
                selectedColor: Colors.green.shade100,
                onSelected: (_) => vm?.filterByTier(RiskTier.green),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (officers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('No personnel found in this tier.')),
          )
        else
          ...officers.map((officer) {
            Color tierColor;
            switch (officer.currentTier) {
              case RiskTier.red:
                tierColor = Colors.red;
                break;
              case RiskTier.orange:
                tierColor = Colors.deepOrange;
                break;
              case RiskTier.yellow:
                tierColor = Colors.amber.shade800;
                break;
              case RiskTier.green:
                tierColor = Colors.green;
                break;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tierColor.withValues(alpha: 0.15),
                  child: Icon(Icons.person_pin_rounded, color: tierColor),
                ),
                title: Text(
                  officer.displayIdentifier,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unit: ${officer.unitCode} • Hardship: ${officer.hardshipPostingGrade}',
                        style: const TextStyle(fontSize: 12)),
                    Text(
                      'Current Tier: ${officer.currentTier.name.toUpperCase()} (${officer.daysInTier} days) • '
                      'Consent: ${officer.consentToDiscloseName ? "Disclosed" : "Pseudonymised"}',
                      style: TextStyle(fontSize: 11, color: tierColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    officer.currentTier.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: tierColor,
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEscalationsTab(BuildContext context, WelfareViewModel? vm) {
    final escalations = vm?.escalations ?? [];

    if (escalations.isEmpty) {
      return const Center(child: Text('No active escalations pending outreach.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: escalations.length,
      itemBuilder: (context, index) {
        final esc = escalations[index];
        final isPending = esc.status == OutreachStatus.pending;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Officer ${esc.pseudoId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Chip(
                      label: Text(
                        esc.status.name.toUpperCase(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: isPending ? Colors.red.shade50 : Colors.teal.shade50,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Trigger: ${esc.triggerReason}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
                if (esc.actionLogNotes != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Outreach Note: ${esc.actionLogNotes}',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.teal),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.phone_forwarded, size: 16),
                        label: const Text('Log Outreach Contact'),
                        onPressed: () {
                          vm?.logOutreach(
                            escalationId: esc.id,
                            status: OutreachStatus.contacted,
                            notes: 'Welfare check completed by regimental welfare officer.',
                          );
                        },
                      )
                    else
                      OutlinedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Facilitate Respite Leave'),
                        onPressed: () {
                          vm?.logOutreach(
                            escalationId: esc.id,
                            status: OutreachStatus.respiteLeaveFacilitated,
                            notes: 'Respite leave coordinated with company commander.',
                          );
                        },
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

  Widget _buildFamilyPipelineTab(BuildContext context, WelfareViewModel? vm) {
    final items = vm?.familyItems ?? [];

    if (items.isEmpty) {
      return const Center(child: Text('No family welfare requests pending.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.volunteer_activism, color: Colors.white),
            ),
            title: Text(
              item.requestType.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dependent ID: ${item.familyMemberPseudoId} • Officer: ${item.officerPseudoId}',
                    style: const TextStyle(fontSize: 12)),
                Text('Remarks: ${item.remarks}', style: const TextStyle(fontSize: 12)),
                if (item.grantAmount != null)
                  Text('Grant Amount: ₹${item.grantAmount!.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
              ],
            ),
            trailing: item.status == 'under_review'
                ? ElevatedButton(
                    child: const Text('Verify'),
                    onPressed: () => vm?.updateFamilyStatus(itemId: item.id, newStatus: 'verified'),
                  )
                : const Chip(
                    label: Text('Verified', style: TextStyle(color: Colors.white, fontSize: 11)),
                    backgroundColor: Colors.teal,
                  ),
          ),
        );
      },
    );
  }
}
