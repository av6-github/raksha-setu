// lib/features/trust/presentation/privacy_firewall_screen.dart
// Explainer screen for the Welfare-HR Firewall and ACR separation

import 'package:flutter/material.dart';

class PrivacyFirewallScreen extends StatelessWidget {
  const PrivacyFirewallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welfare-HR Firewall'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.security, size: 64, color: Colors.green.shade800),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The Welfare-HR Firewall',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Strict architectural and legal separation between welfare support and personnel management.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),

          _ruleCard(
            Icons.block,
            Colors.red,
            'No ACR / Promotion Impact',
            'Your check-in answers, PHQ/GAD scores, and counselling sessions are technically quarantined. They cannot be queried or ingested into ACR reports, promotion boards, or disciplinary panels.',
          ),
          const SizedBox(height: 12),

          _ruleCard(
            Icons.group_work,
            Colors.blue,
            'Commander Sees Aggregate Only',
            'Commanders only see company or battalion-level trends when grouped with at least 10 officers (k-anonymity). Individual stress reasons are never visible to commanding officers.',
          ),
          const SizedBox(height: 12),

          _ruleCard(
            Icons.person_pin,
            Colors.purple,
            'Human Support Over Automated Action',
            'AI only flags deviations to trigger human outreach from welfare staff. The system never automatically downgrades duty status or initiates administrative proceedings.',
          ),
          const SizedBox(height: 12),

          _ruleCard(
            Icons.handshake,
            Colors.teal,
            'Granular & Revocable Consent',
            'Family sharing and wearable biometric sync require your explicit opt-in and can be revoked at any moment with immediate effect.',
          ),
        ],
      ),
    );
  }

  Widget _ruleCard(IconData icon, Color color, String title, String body) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(body, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
