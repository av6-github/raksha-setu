// lib/features/officer_dashboard/presentation/officer_dashboard_screen.dart
// RakshaSetu - Armed Forces Welfare & Resilience Platform
// Revamped Officer Dashboard with Hall of Fame, Activity Calendar,
// Symmetric Glass Panels, and Overflow-Free Architecture

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/networking/network_client.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/aura_background.dart';
import '../../../shared/widgets/floating_dock.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../auth/presentation/auth_view_model.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _expandedCapabilities = false;

  // Calendar activities dataset
  final Map<int, List<Map<String, dynamic>>> _activities = {
    DateTime.now().day: [
      {
        'title': 'Biweekly Wellness Check-In Due',
        'time': '09:00 - 18:00',
        'type': 'checkin',
        'color': RakshaSetuColors.azure,
        'icon': Icons.fact_check_rounded,
        'route': '/checkin',
      },
      {
        'title': 'Battalion Evening Cohesion Circle',
        'time': '17:30 - 18:30',
        'type': 'session',
        'color': RakshaSetuColors.emerald800,
        'icon': Icons.groups_rounded,
        'route': '/team-sessions',
      },
    ],
    DateTime.now().day + 1: [
      {
        'title': 'CAPF Tele-MANAS Wellness Camp',
        'time': '10:00 - 15:00',
        'type': 'camp',
        'color': RakshaSetuColors.gold,
        'icon': Icons.health_and_safety_rounded,
        'route': '/bulletin',
      },
    ],
    DateTime.now().day + 2: [
      {
        'title': 'High Load Roster Rotation Phase',
        'time': 'Full Day',
        'type': 'roster',
        'color': RakshaSetuColors.amber800,
        'icon': Icons.access_time_filled_rounded,
        'route': '/organisational-signals',
      },
    ],
  };

  // Hall of Fame / Commendation dataset
  final List<Map<String, dynamic>> _hallOfFame = [
    {
      'name': 'SI Rajesh Kumar',
      'unit': '14th Bn ITBP',
      'award': 'Distinguished Valour Commendation',
      'quote': 'Rescued 18 civilians during high-altitude avalanche near Mana Pass.',
      'tag': 'BRAVERY',
      'color': RakshaSetuColors.gold,
      'icon': Icons.military_tech_rounded,
    },
    {
      'name': 'Inspector Meena Devi',
      'unit': '88th Mahila Bn CRPF',
      'award': 'Welfare Peer Listener of the Month',
      'quote': 'Conducted 24 confidential peer support sessions with 100% resolution.',
      'tag': 'PEER MENTOR',
      'color': RakshaSetuColors.azure,
      'icon': Icons.workspace_premium_rounded,
    },
    {
      'name': 'Subedar Gurpreet Singh',
      'unit': '7th Assam Rifles',
      'award': 'Leadership Morale Anchor',
      'quote': 'Pioneered unit wellness circles and family morale video pipelines in remote outposts.',
      'tag': 'LEADERSHIP',
      'color': RakshaSetuColors.emerald800,
      'icon': Icons.shield_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.currentUser;
    final networkInfo = context.read<INetworkInfo>();

    return Scaffold(
      backgroundColor: RakshaSetuColors.background,
      body: AuraBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              FutureBuilder<bool>(
                future: networkInfo.isConnected,
                builder: (context, snapshot) {
                  final isOnline = snapshot.data ?? true;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
                        children: [
                          // 1. Consistent Header
                          AppHeader(
                            onSignOut: () => authVm.signOut(),
                          ),
                          const SizedBox(height: 12),

                          // Offline Banner if offline
                          if (!isOnline) ...[
                            _buildOfflineBanner(context),
                            const SizedBox(height: 12),
                          ],

                          // 2. Security & Guardrails Banner
                          _buildSecurityBanner(context),
                          const SizedBox(height: 14),

                          // 3. Hall of Fame (Prominently right at the top!)
                          _buildHallOfFameSection(context),
                          const SizedBox(height: 14),

                          // 4. Pending Tests & Evaluations (Due / Pending Action)
                          _buildPendingTestsSection(context),
                          const SizedBox(height: 14),

                          // 5. Activity & Operational Calendar
                          _buildActivityCalendarSection(context),
                          const SizedBox(height: 14),

                          // 5. Health Baseline & Shift Deviation Card
                          _buildHealthDeviationCard(context),
                          const SizedBox(height: 14),

                          // 6. Welfare Grid & Support Hub (Strictly Symmetric Cards)
                          _buildSymmetricWelfareGrid(context),
                          const SizedBox(height: 14),

                          // 7. Instant Welfare Voice Assistant
                          _buildInstantAssistanceSection(context),
                          const SizedBox(height: 14),

                          // 8. Officer Identity Snippet
                          _buildOfficerProfileSnippet(context, user),
                          const SizedBox(height: 14),

                          // 9. All 16 Capabilities Expandable Directory
                          _buildAllCapabilitiesAccordion(context),
                          const SizedBox(height: 16),

                          // 10. Firewall Statutory Trust Footer
                          _buildTrustFooter(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Pinned Floating Dock at bottom
              const Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: FloatingDock(currentRoute: '/dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Hall of Fame Section ---
  Widget _buildHallOfFameSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.military_tech_rounded, size: 18, color: RakshaSetuColors.gold),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'HALL OF FAME • WALL OF COMMENDATION',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: RakshaSetuColors.slate800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => context.push('/bulletin'),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: RakshaSetuColors.azure,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Horizontally scrolling cards with uniform symmetric height
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _hallOfFame.length,
            itemBuilder: (context, index) {
              final item = _hallOfFame[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: index == _hallOfFame.length - 1 ? 0 : 10,
                ),
                child: LiquidGlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(12),
                  onTap: () => context.push('/bulletin'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item['icon'] as IconData, size: 18, color: item['color'] as Color),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: RakshaSetuColors.slate900,
                                  ),
                                ),
                                Text(
                                  item['unit'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: RakshaSetuColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: (item['color'] as Color).withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              item['tag'] as String,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: item['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        item['award'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: RakshaSetuColors.slate800,
                        ),
                      ),
                      Text(
                        '“${item['quote']}”',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: RakshaSetuColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Pending Tests & Evaluations Section ---
  Widget _buildPendingTestsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.assignment_late_rounded, size: 17, color: Color(0xFFD97706)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'PENDING TESTS & EVALUATIONS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: RakshaSetuColors.slate800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0x33F59E0B),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: const Color(0x66F59E0B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 4.5),
                    const Text(
                      '2 PENDING',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Test Card 1: Biweekly Operational Check-In (Due Today)
        LiquidGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          borderLeftColor: const Color(0xFFF59E0B), // amber-500
          borderLeftWidth: 3.5,
          onTap: () => context.push('/checkin'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0x26F59E0B),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: const Color(0x4DF59E0B)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_rounded, size: 10, color: Color(0xFFB45309)),
                        SizedBox(width: 3.5),
                        Text(
                          'DUE TODAY • ~2 MINS • MANDATORY',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'CYCLE 14/26',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: RakshaSetuColors.slate500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Biweekly Operational Wellness Check-In',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: RakshaSetuColors.slate900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Screening PHQ-2 mood, GAD-2 anxiety, sleep rest quality, and duty workload manageability.',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 11.5,
                  color: RakshaSetuColors.slate600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 13, color: RakshaSetuColors.emerald500),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Isolated from ACR & Postings',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: RakshaSetuColors.emerald800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/checkin'),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF67E8F9)),
                      label: const Text(
                        'Start Check-In',
                        style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1F2C),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Test Card 2: Standardised Clinical Battery (PHQ-9 / GAD-7)
        LiquidGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          borderLeftColor: const Color(0xFF0891B2), // cyan-600
          borderLeftWidth: 3.5,
          onTap: () => context.push('/assessment'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xB3CFFAFE),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: const Color(0x6606B6D4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.psychology_rounded, size: 10, color: Color(0xFF0E7490)),
                        SizedBox(width: 3.5),
                        Text(
                          'CLINICAL BATTERY • ~3 MINS • RECOMMENDED',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0E7490),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'PHQ-9 / GAD-7',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: RakshaSetuColors.slate500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Clinical Psychological Battery',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: RakshaSetuColors.slate900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Full 9-item depression and 7-item anxiety diagnostic inventories with instant explainable severity tiering.',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 11.5,
                  color: RakshaSetuColors.slate600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.verified_user_rounded, size: 13, color: RakshaSetuColors.azure),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Welfare-HR Firewall Guarded',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/assessment'),
                      icon: const Icon(Icons.play_arrow_rounded, size: 14, color: RakshaSetuColors.azure),
                      label: const Text(
                        'Take Battery',
                        style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, fontWeight: FontWeight.w700, color: RakshaSetuColors.azure),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        side: const BorderSide(color: Color(0x660891B2)),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Activity & Operational Calendar Section ---
  Widget _buildActivityCalendarSection(BuildContext context) {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return LiquidGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 18, color: RakshaSetuColors.azure),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'OPERATIONAL & WELFARE CALENDAR',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: RakshaSetuColors.slate800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => context.push('/bulletin'),
                child: const Text(
                  'Full Calendar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: RakshaSetuColors.azure,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7 Days Weekly Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dayDate = now.add(Duration(days: i));
              final isSelected = dayDate.day == _selectedDate.day;
              final hasEvents = _activities.containsKey(dayDate.day);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = dayDate),
                child: Container(
                  width: 38,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? RakshaSetuColors.navy
                        : (hasEvents ? RakshaSetuColors.cyan100.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? RakshaSetuColors.azure
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                    boxShadow: isSelected
                        ? const [BoxShadow(color: Color(0x260C2340), blurRadius: 6, offset: Offset(0, 2))]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayNames[(dayDate.weekday - 1) % 7],
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white70 : RakshaSetuColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${dayDate.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : RakshaSetuColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: hasEvents
                              ? (isSelected ? RakshaSetuColors.cyan400 : RakshaSetuColors.azure)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Activities for selected day
          Builder(
            builder: (context) {
              final events = _activities[_selectedDate.day] ?? [];

              if (events.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Center(
                    child: Text(
                      'No operational flags or welfare sessions on this date.',
                      style: TextStyle(fontSize: 11, color: RakshaSetuColors.slate500),
                    ),
                  ),
                );
              }

              return Column(
                children: events.map((ev) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: InkWell(
                      onTap: () => context.push(ev['route'] as String),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (ev['color'] as Color).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(ev['icon'] as IconData, size: 16, color: ev['color'] as Color),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ev['title'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: RakshaSetuColors.slate900,
                                    ),
                                  ),
                                  Text(
                                    ev['time'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: RakshaSetuColors.slate500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 16, color: RakshaSetuColors.slate400),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Security Banner ---
  Widget _buildSecurityBanner(BuildContext context) {
    return LiquidGlassCard(
      borderLeftColor: const Color(0xFF0891B2), // cyan-600
      borderLeftWidth: 4.0,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      borderRadius: 22.0,
      onTap: () => context.push('/privacy-firewall'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xE6CFFAFE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Icon(Icons.shield_rounded, size: 14, color: Color(0xFF0E7490)),
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'GUARDRAILS & CONFIDENTIALITY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: RakshaSetuColors.defenceObsidian,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0x66A5F3FC)),
                ),
                child: const Text(
                  'ENCL-09/CONFIDENTIAL',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF164E63),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 11,
                height: 1.35,
                color: RakshaSetuColors.slate600,
              ),
              children: [
                TextSpan(
                  text: 'AI informs, humans decide. ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: RakshaSetuColors.slate900,
                  ),
                ),
                TextSpan(
                  text: 'Your baseline metrics are end-to-end encrypted and completely isolated from Service promotion, ACRs, and posting files.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Health Baseline Deviation Card ---
  Widget _buildHealthDeviationCard(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 22.0,
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: RakshaSetuColors.amber500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'BASELINE DEVIATION DETECTED',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: RakshaSetuColors.slate700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: RakshaSetuColors.amber100,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: const Text(
                  'Explainable AI Flag',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: RakshaSetuColors.amber900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Inner card using LiquidGlassInner (.lux-glass-inner)
          LiquidGlassInner(
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Sleep & Duty Recovery Gap',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: RakshaSetuColors.slate900,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '-34% vs Baseline',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: RakshaSetuColors.rose600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Continuous high night-shift cycle for 5 consecutive rotations with high physical load. Observed over last 72 hours.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: RakshaSetuColors.slate600,
                  ),
                ),
                const SizedBox(height: 10),

                // 3 Symmetric Sparks
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Avg Sleep',
                        value: '4.2 hrs',
                        sub: 'Base: 6.8h',
                        subColor: RakshaSetuColors.rose600,
                        bg: const Color(0xB3ECFEFF),
                        border: const Color(0xFFCFFAFE),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Check-in Vibe',
                        value: 'Fatigued',
                        sub: '3 Flags logged',
                        subColor: RakshaSetuColors.amber800,
                        bg: const Color(0xB3F0F9FF),
                        border: const Color(0xFFE0F2FE),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Firewall',
                        value: 'Protected',
                        sub: 'Zero HR Leak',
                        subColor: RakshaSetuColors.emerald800,
                        bg: const Color(0xB3ECFDF5),
                        border: const Color(0xFFD1FAE5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bespoke Obsidian Cyan Action Row (.lux-obsidian-btn & .lux-secondary-btn)
          Row(
            children: [
              Expanded(
                child: ObsidianButton(
                  label: 'Connect with Welfare Officer',
                  icon: const Icon(
                    Icons.people_alt_rounded,
                    size: 16,
                    color: Color(0xFF67E8F9),
                  ),
                  onPressed: () => context.push('/interventions'),
                ),
              ),
              const SizedBox(width: 10),
              CircularSecondaryButton(
                tooltip: 'View Explainable AI Deviation Log',
                onPressed: () => context.push('/baseline'),
                icon: const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: Color(0xFF0F2B48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String sub,
    required Color subColor,
    required Color bg,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, color: RakshaSetuColors.slate500)),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: RakshaSetuColors.slate800)),
          const SizedBox(height: 1),
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: subColor)),
        ],
      ),
    );
  }

  // --- Strictly Symmetric 2x2 Welfare Grid ---
  Widget _buildSymmetricWelfareGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WELFARE GRID & SUPPORT HUB',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: RakshaSetuColors.slate700,
                ),
              ),
              Text(
                'All Personnel Access',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: RakshaSetuColors.azure,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Row 1: Equal Symmetric Height
        Row(
          children: [
            Expanded(
              child: _buildSymmetricCard(
                icon: Icons.support_agent_rounded,
                iconBg: const Color(0xE6E0F2FE),
                iconColor: RakshaSetuColors.azure,
                title: 'Welfare RAG Assistant',
                description: 'Direct AI answers on education grants, medical loans & CSBF schemes.',
                actionText: 'Ask Query',
                actionColor: RakshaSetuColors.azure,
                onTap: () => context.push('/welfare-assistant'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSymmetricCard(
                icon: Icons.favorite_rounded,
                iconBg: RakshaSetuColors.amber100,
                iconColor: RakshaSetuColors.amber800,
                title: 'Family & Morale Vault',
                description: 'Encrypted audio letters, festive family notes & personal resilient anchors.',
                actionText: 'Consent Only',
                actionColor: RakshaSetuColors.amber800,
                onTap: () => context.push('/morale-vault'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row 2: Equal Symmetric Height
        Row(
          children: [
            Expanded(
              child: _buildSymmetricCard(
                icon: Icons.groups_rounded,
                iconBg: const Color(0xE6D1FAE5),
                iconColor: RakshaSetuColors.emerald800,
                title: 'Buddy Listener Network',
                description: 'Anonymous peer connection with certified battalion listeners.',
                actionText: '14 Active Buddies',
                actionColor: RakshaSetuColors.emerald800,
                onTap: () => context.push('/team-sessions'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSymmetricCard(
                icon: Icons.phone_in_talk_outlined,
                iconBg: RakshaSetuColors.purple100,
                iconColor: RakshaSetuColors.purple600,
                title: 'Tele-Manas Counsellor',
                description: '24x7 verified clinical support with full identity masking option.',
                actionText: '24/7 Helpline',
                actionColor: RakshaSetuColors.purple600,
                onTap: () => context.push('/crisis'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSymmetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required String actionText,
    required Color actionColor,
    required VoidCallback onTap,
  }) {
    // Fixed symmetric height (142dp) ensuring zero asymmetric ragged lengths
    return SizedBox(
      height: 142,
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 18,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: RakshaSetuColors.slate900,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                height: 1.3,
                color: RakshaSetuColors.slate500,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x24CBD5E1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: actionColor,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 14, color: actionColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Instant Voice Assistant Section ---
  Widget _buildInstantAssistanceSection(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 22.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          const Text(
            'INSTANT WELFARE ASSISTANCE',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: RakshaSetuColors.slate800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Speak or type confidentially. Human officers are notified only with your consent.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: RakshaSetuColors.slate600,
            ),
          ),
          const SizedBox(height: 12),
          LiquidGlassButton(
            onPressed: () => context.push('/welfare-assistant'),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_rounded, size: 19, color: Color(0xFF0891B2)),
                SizedBox(width: 9),
                Text(
                  'Activate Voice Assistant',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: Color(0xFF0E2A38),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Officer Profile Snippet ---
  Widget _buildOfficerProfileSnippet(BuildContext context, dynamic user) {
    return LiquidGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: () => context.push('/profile'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: RakshaSetuColors.navy,
            child: Text(
              (user?.firstName?.isNotEmpty == true ? user!.firstName![0] : 'O').toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'CAPF Officer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: RakshaSetuColors.slate900,
                  ),
                ),
                Text(
                  user?.serviceNumber ?? 'CAPF-749210-A • 14th Bn',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: RakshaSetuColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: RakshaSetuColors.slate100,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              user?.role.toDbString().replaceAll('_', ' ').toUpperCase() ?? 'OFFICER',
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: RakshaSetuColors.slate700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 16, color: RakshaSetuColors.slate400),
        ],
      ),
    );
  }

  // --- All 16 Capabilities Expandable Directory ---
  Widget _buildAllCapabilitiesAccordion(BuildContext context) {
    return Column(
      children: [
        LiquidGlassCard(
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          onTap: () => setState(() => _expandedCapabilities = !_expandedCapabilities),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _expandedCapabilities ? Icons.keyboard_arrow_up_rounded : Icons.apps_rounded,
                    size: 19,
                    color: RakshaSetuColors.azure,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Full Operational Capabilities Grid',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: RakshaSetuColors.slate800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: RakshaSetuColors.cyan100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _expandedCapabilities ? 'Hide' : '16 Services',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: RakshaSetuColors.navy,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_expandedCapabilities) ...[
          const SizedBox(height: 8),
          _buildCapabilityTile(
            icon: Icons.fact_check_rounded,
            color: Colors.blue,
            title: 'Biweekly Wellness Check-In',
            subtitle: 'PHQ-2 · GAD-2 · Sleep · Workload • ~2 minutes',
            onTap: () => context.push('/checkin'),
          ),
          _buildCapabilityTile(
            icon: Icons.trending_up_rounded,
            color: Colors.indigo,
            title: 'My Wellness Trends & Biometrics',
            subtitle: 'Personal baseline · Sleep & HRV telemetry · 100% Opt-In',
            onTap: () => context.push('/biometrics'),
          ),
          _buildCapabilityTile(
            icon: Icons.psychology_rounded,
            color: Colors.deepPurple,
            title: 'Clinical Assessment Battery',
            subtitle: 'PHQ-9 & GAD-7 validated inventories · Adaptive quarterly review',
            onTap: () => context.push('/assessment'),
          ),
          _buildCapabilityTile(
            icon: Icons.badge_outlined,
            color: Colors.blueGrey,
            title: 'Organisational Rhythm & Signals',
            subtitle: 'Roster rhythm · Leave history & operational friction',
            onTap: () => context.push('/organisational-signals'),
          ),
          _buildCapabilityTile(
            icon: Icons.insights_rounded,
            color: Colors.deepOrange,
            title: 'Personal Baseline & Analytics',
            subtitle: '4-6 week personal baseline · CUSUM change-point alerts',
            onTap: () => context.push('/baseline'),
          ),
          _buildCapabilityTile(
            icon: Icons.auto_graph_rounded,
            color: RakshaSetuColors.navy,
            title: 'Predictive Risk & Explainability',
            subtitle: 'Calibrated 30-60d tier · SHAP feature attribution',
            onTap: () => context.push('/risk-insights'),
          ),
          _buildCapabilityTile(
            icon: Icons.volunteer_activism_rounded,
            color: Colors.teal.shade700,
            title: 'Support Options & Human Interventions',
            subtitle: 'Voluntary workload options · Confidential counselling',
            onTap: () => context.push('/interventions'),
          ),
          _buildCapabilityTile(
            icon: Icons.military_tech_rounded,
            color: RakshaSetuColors.gold,
            title: 'Performance & ACR Context',
            subtitle: 'Operational competencies · Encouraging coaching',
            onTap: () => context.push('/performance'),
          ),
          _buildCapabilityTile(
            icon: Icons.report_gmailerrorred_rounded,
            color: RakshaSetuColors.rose600,
            title: 'Anonymous Reporting',
            subtitle: 'Bullying, harassment, unsafe conditions — identity protected',
            onTap: () => context.push('/anonymous-reporting'),
          ),
          _buildCapabilityTile(
            icon: Icons.event_rounded,
            color: RakshaSetuColors.emerald800,
            title: 'Bulletin Board & Recognitions',
            subtitle: 'Events, sports, wellness camps & wall of commendation',
            onTap: () => context.push('/bulletin'),
          ),
          _buildCapabilityTile(
            icon: Icons.history_rounded,
            color: RakshaSetuColors.slate600,
            title: 'Data Access Audit Log',
            subtitle: 'Cryptographic ledger of who accessed any aspect of your data',
            onTap: () => context.push('/access-log'),
          ),
          _buildCapabilityTile(
            icon: Icons.security_rounded,
            color: RakshaSetuColors.azure,
            title: 'Trust, Ethics & Security Governance',
            subtitle: 'DPDP compliance · Zero HR leak warranty',
            onTap: () => context.push('/governance-trust'),
          ),
          _buildCapabilityTile(
            icon: Icons.monitor_heart_rounded,
            color: Colors.blueAccent,
            title: 'Observability & ML Monitoring',
            subtitle: 'Model drift, latency telemetry, pipeline health',
            onTap: () => context.push('/observability'),
          ),
          _buildCapabilityTile(
            icon: Icons.verified_outlined,
            color: Colors.teal,
            title: 'Phase 19: Shadow Pilot & Gate',
            subtitle: 'Passive shadow telemetry validation & calibration check',
            onTap: () => context.push('/shadow-pilot'),
          ),
          _buildCapabilityTile(
            icon: Icons.flag_rounded,
            color: RakshaSetuColors.navy,
            title: 'Phase 20: Live Pilot & Field Scale',
            subtitle: 'Battalion-level randomized evaluation metrics',
            onTap: () => context.push('/live-pilot'),
          ),
          _buildCapabilityTile(
            icon: Icons.hub_rounded,
            color: Colors.deepPurple,
            title: 'Phase 21: Scale & Enterprise Architecture',
            subtitle: 'Multi-datacenter replication & offline mesh',
            onTap: () => context.push('/scale-architecture'),
          ),
          _buildCapabilityTile(
            icon: Icons.domain_add_rounded,
            color: RakshaSetuColors.navy,
            title: 'Phase 22: Multi-Sector Expansion',
            subtitle: 'State Police, NDRF, SDRF deployment',
            onTap: () => context.push('/expansion'),
          ),
        ],
      ],
    );
  }

  Widget _buildCapabilityTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: LiquidGlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: RakshaSetuColors.slate900,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: RakshaSetuColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 15, color: RakshaSetuColors.slate400),
          ],
        ),
      ),
    );
  }

  // --- Offline Banner ---
  Widget _buildOfflineBanner(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onTap: () => context.push('/offline-sync'),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 16, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline Mode Active — Check-ins will sync when reconnected.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.orange),
            ),
          ),
          Icon(Icons.chevron_right, size: 16, color: Colors.orange),
        ],
      ),
    );
  }

  // --- Trust Footer ---
  Widget _buildTrustFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        'This system is governed by a hard Welfare-HR Firewall. '
        'No stress score, check-in response, or counselling record will '
        'appear in your ACR or influence promotion, posting, or disciplinary action.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 10.5,
          height: 1.35,
          color: RakshaSetuColors.slate500,
        ),
      ),
    );
  }
}
