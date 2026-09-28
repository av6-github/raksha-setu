// lib/features/trust/presentation/privacy_firewall_screen.dart
// Explainer screen for the Welfare-HR Firewall and ACR separation
// Upgraded with RakshaSetuScaffold, Arctic Frost aura gradient, LiquidGlassCards, and FloatingDock

import 'package:flutter/material.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/rakshasetu_scaffold.dart';

class PrivacyFirewallScreen extends StatelessWidget {
  const PrivacyFirewallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RakshaSetuScaffold(
      currentRoute: '/privacy-firewall',
      subtitle: 'HR Firewall & Cryptographic Boundary',
      showBackButton: true,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
        children: [
          // Hero Crest
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_rounded, size: 32, color: RakshaSetuColors.emerald800),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'The Welfare-HR Firewall',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: RakshaSetuColors.slate900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Strict architectural, cryptographic, and legal separation between personal welfare and HR management.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: RakshaSetuColors.slate600, height: 1.35),
          ),
          const SizedBox(height: 18),

          _buildRuleCard(
            Icons.block_rounded,
            RakshaSetuColors.rose600,
            const Color(0xFFFFE4E6),
            'No ACR / Promotion Impact',
            'Your check-in responses, PHQ/GAD scores, and counselling sessions are technically quarantined. They cannot be queried or ingested into ACR reports, promotion boards, or postings.',
          ),
          const SizedBox(height: 10),

          _buildRuleCard(
            Icons.groups_rounded,
            RakshaSetuColors.azure,
            const Color(0xE6E0F2FE),
            'Commanders See Aggregate Trends Only',
            'Commanders only see company or battalion-level trends when grouped with at least 10 personnel (k-anonymity). Individual stress flags are never visible to commanding officers.',
          ),
          const SizedBox(height: 10),

          _buildRuleCard(
            Icons.support_agent_rounded,
            Colors.deepPurple,
            const Color(0xFFF3E8FF),
            'Human Support Over Automated Action',
            'AI informs, humans decide. The platform only flags baseline deviations to trigger supportive human outreach. It never initiates administrative proceedings.',
          ),
          const SizedBox(height: 10),

          _buildRuleCard(
            Icons.vpn_key_rounded,
            RakshaSetuColors.emerald800,
            const Color(0xFFD1FAE5),
            'Granular & Revocable Consent',
            'Family morale pipelines and biometric sync require your explicit opt-in and can be revoked at any moment with immediate cryptographic deletion.',
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(IconData icon, Color color, Color bg, String title, String body) {
    return LiquidGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: RakshaSetuColors.slate900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 11.5,
                    color: RakshaSetuColors.slate600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
