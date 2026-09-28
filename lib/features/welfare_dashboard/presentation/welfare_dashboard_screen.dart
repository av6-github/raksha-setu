// lib/features/welfare_dashboard/presentation/welfare_dashboard_screen.dart
// Welfare Officer Console: Pseudonymised tiers, escalations, proactive outreach, and family pipeline
// Engineered with Arctic Frost glassmorphism, persistent RakshaSetu branding, and zero-overflow layouts

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/aura_background.dart';
import '../../../shared/widgets/floating_dock.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
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
                        subtitle: 'Welfare Officer Console • Armed Forces Care Grid',
                        showBackButton: true,
                        onSignOut: () => authVm?.signOut(),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 19, color: RakshaSetuColors.azure),
                          tooltip: 'Refresh',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          onPressed: () => vm?.loadAll(),
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
                          Tab(icon: Icon(Icons.people_alt_rounded, size: 16), text: 'Tiers & Rosters'),
                          Tab(icon: Icon(Icons.warning_amber_rounded, size: 16), text: 'Escalations'),
                          Tab(icon: Icon(Icons.family_restroom_rounded, size: 16), text: 'Family Pipeline'),
                        ],
                      ),
                    ),

                    // Welfare Firewall Guarantee Notice
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xB3CFFAFE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x6606B6D4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_rounded, size: 15, color: Color(0xFF0E7490)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pseudonymised Console: Operating under strict Welfare-HR Firewall. Therapy notes are quarantined.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0E7490),
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
                              _buildTiersTab(context, vm),
                              _buildEscalationsTab(context, vm),
                              _buildFamilyPipelineTab(context, vm),
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
                  child: FloatingDock(currentRoute: '/welfare'),
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
        builder: (context, _) => buildContent(),
      );
    }

    return buildContent();
  }

  Widget _buildTiersTab(BuildContext context, WelfareViewModel? vm) {
    final officers = vm?.officers ?? [];
    final selectedTier = vm?.selectedTierFilter;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
      children: [
        // Filter chips row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip('All Tiers', selectedTier == null, () => vm?.filterByTier(null)),
              const SizedBox(width: 6),
              _buildFilterChip('Red Tier', selectedTier == RiskTier.red, () => vm?.filterByTier(RiskTier.red), badgeColor: Colors.red),
              const SizedBox(width: 6),
              _buildFilterChip('Orange Tier', selectedTier == RiskTier.orange, () => vm?.filterByTier(RiskTier.orange), badgeColor: Colors.orange),
              const SizedBox(width: 6),
              _buildFilterChip('Yellow Tier', selectedTier == RiskTier.yellow, () => vm?.filterByTier(RiskTier.yellow), badgeColor: Colors.amber),
              const SizedBox(width: 6),
              _buildFilterChip('Green Tier', selectedTier == RiskTier.green, () => vm?.filterByTier(RiskTier.green), badgeColor: Colors.green),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (officers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No personnel found in this tier.',
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 13, color: RakshaSetuColors.slate500),
              ),
            ),
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

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LiquidGlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(14),
                borderLeftColor: tierColor,
                borderLeftWidth: 3.5,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_pin_rounded, color: tierColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  officer.displayIdentifier,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Public Sans',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: RakshaSetuColors.slate900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: tierColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  officer.currentTier.name.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: tierColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Unit: ${officer.unitCode} • Hardship: ${officer.hardshipPostingGrade}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, color: RakshaSetuColors.slate600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'In Tier: ${officer.daysInTier} days • Consent: ${officer.consentToDiscloseName ? "Disclosed" : "Pseudonymised"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Public Sans', fontSize: 10.5, fontWeight: FontWeight.w600, color: tierColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onSelected, {Color? badgeColor}) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A1F2C) : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? const Color(0xFF0A1F2C) : const Color(0x6622D3EE),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : RakshaSetuColors.slate700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEscalationsTab(BuildContext context, WelfareViewModel? vm) {
    final escalations = vm?.escalations ?? [];

    if (escalations.isEmpty) {
      return const Center(
        child: Text(
          'No active escalations pending outreach.',
          style: TextStyle(fontFamily: 'Public Sans', fontSize: 13, color: RakshaSetuColors.slate500),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
      itemCount: escalations.length,
      itemBuilder: (context, index) {
        final esc = escalations[index];
        final isPending = esc.status == OutreachStatus.pending;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            borderLeftColor: isPending ? RakshaSetuColors.rose600 : RakshaSetuColors.azure,
            borderLeftWidth: 3.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Officer ${esc.pseudoId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: RakshaSetuColors.slate900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPending ? const Color(0x26F43F5E) : const Color(0x2606B6D4),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: isPending ? const Color(0x66F43F5E) : const Color(0x6606B6D4),
                        ),
                      ),
                      child: Text(
                        esc.status.name.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isPending ? RakshaSetuColors.rose600 : RakshaSetuColors.azure,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Trigger: ${esc.triggerReason}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: RakshaSetuColors.slate700),
                ),
                if (esc.actionLogNotes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Outreach Note: ${esc.actionLogNotes}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF0E7490),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: isPending
                      ? SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.phone_forwarded_rounded, size: 14, color: Colors.white),
                            label: const Text(
                              'Log Outreach Contact',
                              style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A1F2C),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                            ),
                            onPressed: () {
                              vm?.logOutreach(
                                escalationId: esc.id,
                                status: OutreachStatus.contacted,
                                notes: 'Welfare check completed by regimental welfare officer.',
                              );
                            },
                          ),
                        )
                      : SizedBox(
                          height: 32,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 14, color: RakshaSetuColors.azure),
                            label: const Text(
                              'Facilitate Respite Leave',
                              style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, fontWeight: FontWeight.w700, color: RakshaSetuColors.azure),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0x660891B2)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                            ),
                            onPressed: () {
                              vm?.logOutreach(
                                escalationId: esc.id,
                                status: OutreachStatus.respiteLeaveFacilitated,
                                notes: 'Respite leave coordinated with company commander.',
                              );
                            },
                          ),
                        ),
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
      return const Center(
        child: Text(
          'No family welfare requests pending.',
          style: TextStyle(fontFamily: 'Public Sans', fontSize: 13, color: RakshaSetuColors.slate500),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            borderLeftColor: const Color(0xFF0D9488),
            borderLeftWidth: 3.5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0x2614B8A6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volunteer_activism_rounded, color: Color(0xFF0F766E), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.requestType.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: RakshaSetuColors.slate900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          item.status == 'under_review'
                              ? SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A1F2C),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                    ),
                                    child: const Text('Verify', style: TextStyle(fontFamily: 'Public Sans', fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w700)),
                                    onPressed: () => vm?.updateFamilyStatus(itemId: item.id, newStatus: 'verified'),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0x2610B981),
                                    borderRadius: BorderRadius.circular(9999),
                                    border: Border.all(color: const Color(0x6610B981)),
                                  ),
                                  child: const Text('Verified', style: TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
                                ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Dep ID: ${item.familyMemberPseudoId} • Officer: ${item.officerPseudoId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11, color: RakshaSetuColors.slate600),
                      ),
                      Text(
                        'Remarks: ${item.remarks}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11, color: RakshaSetuColors.slate700),
                      ),
                      if (item.grantAmount != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Grant Amount: ₹${item.grantAmount!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            color: Color(0xFF0E7490),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
