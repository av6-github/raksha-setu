// lib/shared/widgets/floating_dock.dart
// Simplified, elegant Arctic Frost Floating Dock
// Role-aware dock items and portal-specific 3-dots directory

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/rakshasetu_theme.dart';

enum PortalRole {
  officer,
  welfare,
  counsellor,
  family,
}

class FloatingDock extends StatefulWidget {
  final String currentRoute;

  const FloatingDock({
    super.key,
    required this.currentRoute,
  });

  @override
  State<FloatingDock> createState() => _FloatingDockState();
}

class _FloatingDockState extends State<FloatingDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: -3.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  PortalRole _detectRole(String route) {
    if (route.startsWith('/welfare') ||
        route.startsWith('/organisational-signals') ||
        route.startsWith('/governance') ||
        route.startsWith('/data-retention')) {
      return PortalRole.welfare;
    } else if (route.startsWith('/counsellor') ||
        route.startsWith('/assessments') ||
        route.startsWith('/crisis') ||
        route.startsWith('/team-cohesion') ||
        route.startsWith('/baseline-trends') ||
        route.startsWith('/access-log')) {
      return PortalRole.counsellor;
    } else if (route.startsWith('/family')) {
      return PortalRole.family;
    }
    return PortalRole.officer;
  }

  void _openPortalSheet(BuildContext context) {
    final role = _detectRole(widget.currentRoute);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PortalDirectorySheet(
        initialRole: role,
        currentRoute: widget.currentRoute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVeryNarrow = screenWidth < 350;
    final isNarrow = screenWidth < 385;

    final itemHPad = isVeryNarrow ? 8.0 : (isNarrow ? 10.0 : 13.0);
    final itemVPad = isVeryNarrow ? 6.0 : 7.5;
    final gap = isVeryNarrow ? 2.0 : (isNarrow ? 4.0 : 6.0);
    final iconSize = isVeryNarrow ? 18.0 : (isNarrow ? 19.5 : 21.0);

    final role = _detectRole(widget.currentRoute);

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F06B6D4), // Soft Arctic Cyan Glow
                blurRadius: 24,
                offset: Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Color(0x140C2340),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.98),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._buildRoleDockItems(role, iconSize, itemHPad, itemVPad, gap),
                    SizedBox(width: gap),
                    // 3-Dots Portal Menu Action
                    _DockIconButton(
                      icon: Icons.more_horiz_rounded,
                      label: 'Menu',
                      iconSize: iconSize,
                      hPad: itemHPad,
                      vPad: itemVPad,
                      isActive: false,
                      isSpecial: true,
                      onTap: () => _openPortalSheet(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleDockItems(
    PortalRole role,
    double iconSize,
    double itemHPad,
    double itemVPad,
    double gap,
  ) {
    switch (role) {
      case PortalRole.welfare:
        return [
          _DockIconButton(
            icon: Icons.health_and_safety_rounded,
            label: 'Welfare',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/welfare-dashboard' || widget.currentRoute == '/welfare',
            onTap: () => context.go('/welfare-dashboard'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.trending_up_rounded,
            label: 'Pulse',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/organisational-signals',
            onTap: () => context.push('/organisational-signals'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.support_agent_rounded,
            label: 'Schemes',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/welfare-assistant',
            onTap: () => context.push('/welfare-assistant'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.report_problem_outlined,
            label: 'Reports',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/anonymous-reporting',
            onTap: () => context.push('/anonymous-reporting'),
          ),
        ];

      case PortalRole.counsellor:
        return [
          _DockIconButton(
            icon: Icons.psychology_rounded,
            label: 'Clinical',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/counsellor-dashboard' || widget.currentRoute == '/counsellor',
            onTap: () => context.go('/counsellor-dashboard'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.assignment_outlined,
            label: 'Battery',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/assessments',
            onTap: () => context.push('/assessments'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.headset_mic_rounded,
            label: 'Care Hub',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/support-hub',
            onTap: () => context.push('/support-hub'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.groups_rounded,
            label: 'Cohesion',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/team-cohesion',
            onTap: () => context.push('/team-cohesion'),
          ),
        ];

      case PortalRole.family:
        return [
          _DockIconButton(
            icon: Icons.family_restroom_rounded,
            label: 'Family',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/family-dashboard' || widget.currentRoute == '/family',
            onTap: () => context.go('/family-dashboard'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.favorite_rounded,
            label: 'Vault',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/morale-vault',
            activeColor: RakshaSetuColors.rose600,
            onTap: () => context.push('/morale-vault'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.support_agent_rounded,
            label: 'Grants',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/welfare-assistant',
            onTap: () => context.push('/welfare-assistant'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.emergency_rounded,
            label: 'Helpline',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/support-hub',
            activeColor: RakshaSetuColors.rose600,
            onTap: () => context.push('/support-hub'),
          ),
        ];

      case PortalRole.officer:
      default:
        return [
          _DockIconButton(
            icon: Icons.home_rounded,
            label: 'Home',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/dashboard',
            onTap: () => context.go('/dashboard'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.fact_check_rounded,
            label: 'Check-In',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/checkin',
            onTap: () => context.push('/checkin'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.support_agent_rounded,
            label: 'Schemes',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/welfare-assistant',
            onTap: () => context.push('/welfare-assistant'),
          ),
          SizedBox(width: gap),
          _DockIconButton(
            icon: Icons.favorite_rounded,
            label: 'Vault',
            iconSize: iconSize,
            hPad: itemHPad,
            vPad: itemVPad,
            isActive: widget.currentRoute == '/morale-vault',
            activeColor: RakshaSetuColors.rose600,
            onTap: () => context.push('/morale-vault'),
          ),
        ];
    }
  }
}

class _DockIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isSpecial;
  final Color? activeColor;
  final double iconSize;
  final double hPad;
  final double vPad;
  final VoidCallback onTap;

  const _DockIconButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isSpecial = false,
    this.activeColor,
    required this.iconSize,
    required this.hPad,
    required this.vPad,
    required this.onTap,
  });

  @override
  State<_DockIconButton> createState() => _DockIconButtonState();
}

class _DockIconButtonState extends State<_DockIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeThemeColor = widget.activeColor ?? RakshaSetuColors.cyan400;

    final bgColor = widget.isActive
        ? const Color(0xE6CFFAFE) // cyan-100 with 90% opacity
        : (_isHovered ? Colors.white.withValues(alpha: 0.95) : Colors.transparent);

    final iconColor = widget.isActive
        ? const Color(0xFF0E7490) // deep cyan-800
        : (widget.isSpecial
            ? RakshaSetuColors.navy
            : (_isHovered ? const Color(0xFF0891B2) : RakshaSetuColors.slate700));

    return Tooltip(
      message: widget.label,
      preferBelow: false,
      verticalOffset: 24,
      decoration: BoxDecoration(
        color: RakshaSetuColors.navy,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      textStyle: const TextStyle(
        fontFamily: 'Public Sans',
        color: Colors.white,
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: widget.hPad, vertical: widget.vPad),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: widget.isActive
                  ? Border.all(color: const Color(0x8022D3EE), width: 1.0)
                  : (widget.isSpecial
                      ? Border.all(color: RakshaSetuColors.slate200, width: 1.0)
                      : null),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: iconColor,
                ),
                const SizedBox(height: 2),
                Container(
                  width: 3.5,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: widget.isActive ? activeThemeColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dynamic 3-Dots Directory Modal tailored to portal users with 1-tap switching
class _PortalDirectorySheet extends StatefulWidget {
  final PortalRole initialRole;
  final String currentRoute;

  const _PortalDirectorySheet({
    required this.initialRole,
    required this.currentRoute,
  });

  @override
  State<_PortalDirectorySheet> createState() => _PortalDirectorySheetState();
}

class _PortalDirectorySheetState extends State<_PortalDirectorySheet> {
  late PortalRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: RakshaSetuColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x330C2340),
            blurRadius: 32,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: RakshaSetuColors.slate400.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),

          // Header with Title and Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: RakshaSetuColors.crestGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.grid_view_rounded, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portal Navigation & Directory',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: RakshaSetuColors.slate900,
                          ),
                        ),
                        Text(
                          'Tailored services by user role and operational portal',
                          style: TextStyle(
                            fontSize: 11,
                            color: RakshaSetuColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Role Selector Tabs (Pills)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRolePill(
                    role: PortalRole.officer,
                    label: 'Officer / Jawan',
                    icon: Icons.shield_rounded,
                    color: const Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 8),
                  _buildRolePill(
                    role: PortalRole.welfare,
                    label: 'Welfare Officer',
                    icon: Icons.health_and_safety_rounded,
                    color: const Color(0xFF0F766E),
                  ),
                  const SizedBox(width: 8),
                  _buildRolePill(
                    role: PortalRole.counsellor,
                    label: 'Counsellor',
                    icon: Icons.psychology_rounded,
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 8),
                  _buildRolePill(
                    role: PortalRole.family,
                    label: 'Veer Parivar',
                    icon: Icons.family_restroom_rounded,
                    color: const Color(0xFFE11D48),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Portal-Specific Services & Grid
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
              children: [
                ..._buildPortalSections(context, _selectedRole),
                const SizedBox(height: 18),
                _buildCategoryHeader('ALL-ROLE RESILIENCE & CRISIS GRID'),
                _buildNavigationTile(
                  context,
                  icon: Icons.phone_in_talk_rounded,
                  title: '24x7 CAPF Tele-MANAS Crisis Helpline',
                  subtitle: 'Immediate, confidential clinical emergency hotline',
                  route: '/crisis',
                  color: RakshaSetuColors.rose600,
                ),
                _buildNavigationTile(
                  context,
                  icon: Icons.security_rounded,
                  title: 'HR Privacy Firewall & Consent',
                  subtitle: 'Zero-knowledge boundary isolating welfare from ACR / postings',
                  route: '/privacy-firewall',
                  color: RakshaSetuColors.emerald800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePill({
    required PortalRole role,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : RakshaSetuColors.slate200,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : RakshaSetuColors.slate800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPortalSections(BuildContext context, PortalRole role) {
    switch (role) {
      case PortalRole.welfare:
        return [
          _buildCategoryHeader('WELFARE OFFICER SUITE'),
          _buildNavigationTile(
            context,
            icon: Icons.health_and_safety_rounded,
            title: 'Welfare Officer Command Hub',
            subtitle: 'Discretionary funds, welfare grant claims & unit support circles',
            route: '/welfare-dashboard',
            color: const Color(0xFF0F766E),
          ),
          _buildNavigationTile(
            context,
            icon: Icons.trending_up_rounded,
            title: 'Organisational Signals & Unit Pulse',
            subtitle: 'Aggregated battalion morale, operational fatigue & shift strain',
            route: '/organisational-signals',
            color: RakshaSetuColors.azure,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.support_agent_rounded,
            title: 'Welfare Schemes RAG Assistant',
            subtitle: 'Authoritative Ayushman CAPF, PMSS, housing & grant verification',
            route: '/welfare-assistant',
            color: Colors.teal,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.report_problem_rounded,
            title: 'Anonymous Grievance Escalations',
            subtitle: 'Secure triage queue for hazardous conditions & hazing prevention',
            route: '/anonymous-reporting',
            color: RakshaSetuColors.rose600,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.gavel_rounded,
            title: 'Governance, DPDP & Ethical Center',
            subtitle: 'Compliance verification, data audit logs & fairness transparency',
            route: '/governance-trust',
            color: RakshaSetuColors.navy,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.auto_delete_rounded,
            title: 'Data Retention & Purge Policy',
            subtitle: 'Statutory 30-day ephemeral logs & cryptographic record shredding',
            route: '/data-retention',
            color: RakshaSetuColors.slate700,
          ),
        ];

      case PortalRole.counsellor:
        return [
          _buildCategoryHeader('CLINICAL COUNSELLOR DESK'),
          _buildNavigationTile(
            context,
            icon: Icons.psychology_rounded,
            title: 'Counsellor Clinical Dashboard',
            subtitle: 'Active caseload, PHQ/GAD triage, session notes & break-glass audit',
            route: '/counsellor-dashboard',
            color: const Color(0xFF6366F1),
          ),
          _buildNavigationTile(
            context,
            icon: Icons.quiz_rounded,
            title: 'Clinical Assessment Battery',
            subtitle: 'Standardized PHQ-9 & GAD-7 inventories with severity scoring',
            route: '/assessments',
            color: Colors.deepPurple,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.headset_mic_rounded,
            title: 'Support Hub & Interventions',
            subtitle: 'Clinical session bookings, stress management & voluntary leaves',
            route: '/support-hub',
            color: Colors.teal.shade800,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.groups_rounded,
            title: 'Unit Cohesion & Social Dynamics',
            subtitle: 'Platoon bonding indicators, isolated personnel identification',
            route: '/team-cohesion',
            color: RakshaSetuColors.emerald800,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.insights_rounded,
            title: 'Baseline Trends & Equilibrium Engine',
            subtitle: 'CUSUM statistical shift alerts across 6-week recovery horizons',
            route: '/baseline-trends',
            color: Colors.deepOrange,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.history_edu_rounded,
            title: 'Access Audit Ledger & Break-Glass Log',
            subtitle: 'Tamper-evident record of all clinical interventions & requests',
            route: '/access-log',
            color: RakshaSetuColors.slate700,
          ),
        ];

      case PortalRole.family:
        return [
          _buildCategoryHeader('VEER PARIVAR FAMILY SERVICES'),
          _buildNavigationTile(
            context,
            icon: Icons.family_restroom_rounded,
            title: 'Veer Parivar Family Care Portal',
            subtitle: 'Dependents resource grid, education grants & home support',
            route: '/family-dashboard',
            color: const Color(0xFFE11D48),
          ),
          _buildNavigationTile(
            context,
            icon: Icons.favorite_rounded,
            title: 'Morale Vault (Letters & Voice Notes)',
            subtitle: 'Encrypted offline voice notes, photos & messages to the field',
            route: '/morale-vault',
            color: RakshaSetuColors.rose600,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.school_rounded,
            title: 'Education Grants & Family Welfare',
            subtitle: 'Step-by-step guidance on children scholarships & medical reimbursements',
            route: '/welfare-assistant',
            color: Colors.teal,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.contact_phone_rounded,
            title: 'Family Support & Emergency Hub',
            subtitle: '24x7 liaison officer helpline & urgent welfare relief assistance',
            route: '/support-hub',
            color: RakshaSetuColors.navy,
          ),
        ];

      case PortalRole.officer:
      default:
        return [
          _buildCategoryHeader('OFFICER & JAWAN CORE PORTAL'),
          _buildNavigationTile(
            context,
            icon: Icons.shield_rounded,
            title: 'Officer Operational Dashboard',
            subtitle: 'Operational health status, baseline alerts & welfare summary',
            route: '/dashboard',
            color: RakshaSetuColors.navy,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.fact_check_rounded,
            title: 'Biweekly Wellness Check-In',
            subtitle: 'PHQ-2, GAD-2, sleep recovery & operational load index (~2 min)',
            route: '/checkin',
            color: Colors.blue,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.quiz_rounded,
            title: 'Clinical Evaluation Battery',
            subtitle: 'Standardized psychological evaluation battery (PHQ-9 / GAD-7)',
            route: '/assessments',
            color: Colors.deepPurple,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.support_agent_rounded,
            title: 'Welfare Schemes RAG Assistant',
            subtitle: 'AI assistant for Ayushman CAPF, PMSS, housing & pension queries',
            route: '/welfare-assistant',
            color: Colors.teal,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.favorite_rounded,
            title: 'Family & Morale Vault',
            subtitle: 'Encrypted audio notes, letters from home & resilient memories',
            route: '/morale-vault',
            color: RakshaSetuColors.rose600,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.military_tech_rounded,
            title: 'Hall of Fame & Unit Events',
            subtitle: 'Wall of Commendation, activities calendar & wellness camps',
            route: '/bulletin',
            color: Colors.amber.shade800,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.report_gmailerrorred_rounded,
            title: 'Anonymous Secure Reporting',
            subtitle: 'Safe channel for hazing, safety breaches & grievances',
            route: '/anonymous-reporting',
            color: RakshaSetuColors.rose600,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.watch_rounded,
            title: 'Biometrics & HRV Telemetry',
            subtitle: 'Personal baseline, HRV telemetry, sleep stages (100% opt-in)',
            route: '/biometrics',
            color: Colors.indigo,
          ),
          _buildNavigationTile(
            context,
            icon: Icons.badge_rounded,
            title: 'Officer Identity & Credentials',
            subtitle: 'Service credentials, force ID & encrypted identity proof',
            route: '/profile',
            color: RakshaSetuColors.slate700,
          ),
        ];
    }
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: RakshaSetuColors.slate500,
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
  }) {
    final isCurrent = widget.currentRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? const Color(0xFF86EFAC) : RakshaSetuColors.slate200,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080C2340),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13.5,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                  color: isCurrent ? const Color(0xFF166534) : RakshaSetuColors.slate900,
                ),
              ),
            ),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: RakshaSetuColors.slate600,
            height: 1.25,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13,
          color: RakshaSetuColors.slate400,
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (!isCurrent) {
            context.push(route);
          }
        },
      ),
    );
  }
}
