// lib/shared/widgets/welfare_banner.dart
// Trust badge reminding users of the Welfare-HR Firewall and Privacy commitments

import 'package:flutter/material.dart';

class WelfareBanner extends StatelessWidget {
  const WelfareBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 16, color: Colors.green.shade800),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Welfare-HR Firewall Active • Stress data never impacts ACR or promotion',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
