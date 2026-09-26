// lib/features/officer_dashboard/presentation/officer_dashboard_screen.dart
// Role-gated officer dashboard: trends, check-in entry point, welfare firewall, consent access

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/networking/network_client.dart';
import '../../../features/auth/presentation/auth_view_model.dart';
import '../../../shared/widgets/welfare_banner.dart';

class OfficerDashboardScreen extends StatelessWidget {
  const OfficerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.currentUser;
    final networkInfo = context.read<INetworkInfo>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raksha Welfare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency, color: Colors.red),
            tooltip: '24x7 Crisis Support',
            onPressed: () => context.push('/crisis'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign Out',
            onPressed: () => authVm.signOut(),
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: networkInfo.isConnected,
        builder: (context, snapshot) {
          final isOnline = snapshot.data ?? true;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Officer identity card
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push('/profile'),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            (user?.firstName?.isNotEmpty == true
                                    ? user!.firstName![0]
                                    : 'O')
                                .toUpperCase(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Officer',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user?.serviceNumber ?? '—',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                user?.role.toDbString().replaceAll('_', ' ').toUpperCase() ?? '',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),

              // Offline badge
              if (!isOnline) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => context.push('/offline-sync'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Offline Mode — Check-ins will sync when reconnected. Tap to manage sync & fallback.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 16, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              InkWell(
                onTap: () => context.push('/privacy-firewall'),
                child: const WelfareBanner(),
              ),
              const SizedBox(height: 16),

              // Biweekly check-in card
              _DashboardActionCard(
                icon: Icons.favorite_border_rounded,
                color: Colors.blue,
                title: 'Biweekly Check-In',
                subtitle: 'PHQ-2 · GAD-2 · Sleep · Workload  •  ~2 minutes',
                badge: 'Due',
                badgeColor: Colors.orange,
                onTap: () => context.push('/checkin'),
              ),

              const SizedBox(height: 10),

              // Welfare RAG assistant
              _DashboardActionCard(
                icon: Icons.support_agent_rounded,
                color: Colors.teal,
                title: 'Welfare Scheme Assistant',
                subtitle: 'Ask about Ayushman CAPF, PMSS, housing, pensions & more',
                onTap: () => context.push('/welfare-assistant'),
              ),

              const SizedBox(height: 10),

              // My trends & biometrics
              _DashboardActionCard(
                icon: Icons.trending_up_rounded,
                color: Colors.indigo,
                title: 'My Wellness Trends & Biometrics',
                subtitle: 'Personal baseline · Sleep & HRV telemetry · 100% Opt-In',
                onTap: () => context.push('/biometrics'),
              ),

              const SizedBox(height: 10),

              // Clinical Assessment Battery
              _DashboardActionCard(
                icon: Icons.psychology_rounded,
                color: Colors.deepPurple,
                title: 'Clinical Assessment Battery',
                subtitle: 'PHQ-9 & GAD-7 validated inventories · Adaptive quarterly review',
                onTap: () => context.push('/assessment'),
              ),

              const SizedBox(height: 10),

              // Organisational Signals
              _DashboardActionCard(
                icon: Icons.badge_outlined,
                color: Colors.blueGrey,
                title: 'Organisational Rhythm & Signals',
                subtitle: 'Roster rhythm · Leave history & operational friction · Hardship postings',
                onTap: () => context.push('/organisational-signals'),
              ),

              const SizedBox(height: 10),

              // Personal Baseline & Analytics Engine
              _DashboardActionCard(
                icon: Icons.insights_rounded,
                color: Colors.deepOrange,
                title: 'Personal Baseline & Analytics',
                subtitle: '4-6 week personal baseline · CUSUM change-point alerts · Unit equilibrium',
                onTap: () => context.push('/baseline'),
              ),

              const SizedBox(height: 10),

              // Predictive Risk & Explainability
              _DashboardActionCard(
                icon: Icons.auto_graph_rounded,
                color: Colors.blueGrey.shade800,
                title: 'Predictive Risk & Explainability',
                subtitle: 'Calibrated 30-60d tier · SHAP feature attribution · Algorithmic oversight',
                onTap: () => context.push('/risk-insights'),
              ),

              const SizedBox(height: 10),

              // Support Options & Human Interventions
              _DashboardActionCard(
                icon: Icons.volunteer_activism_rounded,
                color: Colors.teal.shade700,
                title: 'Support Options & Human Interventions',
                subtitle: 'Voluntary workload options · Confidential counselling · Return-to-duty plans',
                onTap: () => context.push('/interventions'),
              ),

              const SizedBox(height: 10),

              // Family & consent settings
              _DashboardActionCard(
                icon: Icons.family_restroom_rounded,
                color: Colors.purple,
                title: 'Family & Consent Settings',
                subtitle: 'Manage granular sharing permissions and revocation',
                onTap: () => context.push('/consent'),
              ),


              const SizedBox(height: 10),

              // Morale vault
              _DashboardActionCard(
                icon: Icons.video_library_rounded,
                color: Colors.amber,
                title: 'Morale Vault',
                subtitle: 'Messages and videos from family and friends',
                onTap: () => context.push('/morale-vault'),
              ),

              const SizedBox(height: 10),

              // Team Cohesion & Psychoeducation
              _DashboardActionCard(
                icon: Icons.groups_rounded,
                color: Colors.teal.shade800,
                title: 'Team Cohesion & Psychoeducation',
                subtitle: 'Unit sessions · Roster-aligned scheduling · Confidential 1-on-1 alternative',
                onTap: () => context.push('/team-sessions'),
              ),

              const SizedBox(height: 10),

              // Operational Performance & ACR Context
              _DashboardActionCard(
                icon: Icons.military_tech_rounded,
                color: Colors.indigo.shade900,
                title: 'Performance & ACR Context',
                subtitle: 'Operational competencies · Encouraging coaching · Strict Welfare-HR firewall',
                onTap: () => context.push('/performance'),
              ),

              const SizedBox(height: 10),

              // Anonymous reporting
              _DashboardActionCard(
                icon: Icons.report_gmailerrorred_rounded,
                color: Colors.red,
                title: 'Anonymous Reporting',
                subtitle: 'Bullying, harassment, unsafe conditions — identity protected',
                onTap: () => context.push('/anonymous-reporting'),
              ),

              const SizedBox(height: 10),

              // Bulletin board
              _DashboardActionCard(
                icon: Icons.event_rounded,
                color: Colors.green,
                title: 'Bulletin Board & Recognitions',
                subtitle: 'Events, sports, wellness camps, wall of commendation & peer appreciation',
                onTap: () => context.push('/bulletin'),
              ),

              const SizedBox(height: 20),

              // Data access log
              TextButton.icon(
                onPressed: () => context.push('/access-log'),
                icon: const Icon(Icons.history_rounded, size: 16),
                label: const Text('View who accessed your data'),
              ),

              // Trust, Ethics & Security Governance
              TextButton.icon(
                onPressed: () => context.push('/governance-trust'),
                icon: const Icon(Icons.shield_outlined, size: 16),
                label: const Text('Trust, Ethics & Security Governance'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/observability'),
                icon: const Icon(Icons.monitor_heart_rounded, color: Colors.blueAccent),
                label: const Text('Observability & ML Monitoring'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/shadow-pilot'),
                icon: const Icon(Icons.verified_outlined, color: Colors.teal),
                label: const Text('Phase 19: Shadow Pilot & Gate'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/live-pilot'),
                icon: const Icon(Icons.military_tech_rounded, color: Colors.indigo),
                label: const Text('Phase 20: Live Pilot & Field Scale'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/scale-architecture'),
                icon: const Icon(Icons.hub_rounded, color: Colors.deepPurple),
                label: const Text('Phase 21: Scale & Enterprise Architecture'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/expansion'),
                icon: const Icon(Icons.domain_add_rounded, color: Colors.indigo),
                label: const Text('Phase 22: Multi-Sector Expansion'),
              ),

              const SizedBox(height: 4),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'This system is governed by a hard Welfare-HR Firewall. '
                  'No stress score, check-in response, or counselling record will '
                  'appear in your ACR or influence promotion, posting, or disciplinary action.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),

        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
          ],
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
