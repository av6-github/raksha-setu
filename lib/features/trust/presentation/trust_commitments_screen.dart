// lib/features/trust/presentation/trust_commitments_screen.dart
// Display of institutional trust commitments and anti-stigmatisation guarantees

import 'package:flutter/material.dart';

class TrustCommitmentsScreen extends StatelessWidget {
  const TrustCommitmentsScreen({super.key});

  static const List<Map<String, String>> commitments = [
    {
      'title': '1. Welfare Over Surveillance',
      'body': 'This tool exists solely to protect your health and morale. It is never used for surveillance or punitive scoring.',
    },
    {
      'title': '2. Personal Baseline First',
      'body': 'You are evaluated against your own historical baseline, not against generic population averages.',
    },
    {
      'title': '3. Explainability by Default',
      'body': 'Every recommendation or flag is backed by plain-language SHAP explanations visible to you.',
    },
    {
      'title': '4. Human Decisions Always',
      'body': 'Algorithms recommend; only qualified doctors and welfare officers make decisions regarding care.',
    },
    {
      'title': '5. Crisis is Human-Only',
      'body': 'AI never interacts during an active crisis. Direct connection to 24x7 human responders is guaranteed.',
    },
    {
      'title': '6. Hard Welfare-HR Firewall',
      'body': 'No wellness data enters ACR or influences promotion, postings, or disciplinary actions.',
    },
    {
      'title': '7. Minimum Exposure Principle',
      'body': 'Only the absolute minimum required data is exposed to authorised support staff with immutable logging.',
    },
    {
      'title': '8. Granular & Revocable Family Consent',
      'body': 'Family involvement is completely under your control, granular per person, and instantly revocable.',
    },
    {
      'title': '9. Offline-First Security',
      'body': 'Your local data is encrypted with device keys. No screenshots are permitted in sensitive views.',
    },
    {
      'title': '10. Right to Data Deletion',
      'body': 'You retain the right to request deletion of voluntary biometrics and morale vault media at any time.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institutional Trust Commitments'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: commitments.length,
        itemBuilder: (context, index) {
          final item = commitments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['body']!,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
