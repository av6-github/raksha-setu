// lib/shared/screens/placeholder_screens.dart
// Scaffold placeholder screens for roles not yet fully implemented (Phase 11: Vigilance Cell)

import 'package:flutter/material.dart';
import '../../features/auth/presentation/auth_view_model.dart';
import 'package:provider/provider.dart';

class VigilanceDashboardScreen extends StatelessWidget {
  const VigilanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vigilance & Oversight Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AuthViewModel>().signOut(),
          )
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 64, color: Colors.blueGrey),
            SizedBox(height: 16),
            Text('Vigilance Portal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Anonymous reporting, inquiry pipelines, and technical isolation\ncoming in Phase 11.',
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
