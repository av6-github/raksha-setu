// lib/shared/widgets/rakshasetu_scaffold.dart
// Unified Scaffold for RakshaSetu pages providing consistent Header, Aura Gradient, and Floating Dock

import 'package:flutter/material.dart';
import '../../core/theme/rakshasetu_theme.dart';
import 'app_header.dart';
import 'aura_background.dart';
import 'floating_dock.dart';

class RakshaSetuScaffold extends StatelessWidget {
  final Widget body;
  final String currentRoute;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onSignOut;
  final bool showCrisisButton;
  final bool showFloatingDock;
  final Widget? trailing;
  final Widget? floatingActionButton;

  const RakshaSetuScaffold({
    super.key,
    required this.body,
    required this.currentRoute,
    this.subtitle,
    this.showBackButton = true,
    this.onBack,
    this.onSignOut,
    this.showCrisisButton = true,
    this.showFloatingDock = true,
    this.trailing,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RakshaSetuColors.background,
      floatingActionButton: floatingActionButton,
      body: AuraBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    children: [
                      // Consistent RakshaSetu Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                        child: AppHeader(
                          subtitle: subtitle,
                          showBackButton: showBackButton,
                          onBack: onBack,
                          onSignOut: onSignOut,
                          showCrisisButton: showCrisisButton,
                          trailing: trailing,
                        ),
                      ),

                      // Body Content
                      Expanded(
                        child: body,
                      ),
                    ],
                  ),
                ),
              ),

              // Pinned Floating Dock at Bottom
              if (showFloatingDock)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 6,
                  child: FloatingDock(currentRoute: currentRoute),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
