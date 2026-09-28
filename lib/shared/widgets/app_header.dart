// lib/shared/widgets/app_header.dart
// Consistent RakshaSetu Header with Crest, Prominent Branding, Firewall Pulse, and Navigation
// Engineered to ensure full name visibility with auto-scaling typography and zero overflow

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/rakshasetu_theme.dart';
import 'welfare_banner.dart';

class AppHeader extends StatelessWidget {
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onSignOut;
  final bool showCrisisButton;
  final Widget? trailing;

  const AppHeader({
    super.key,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.onSignOut,
    this.showCrisisButton = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isVeryNarrow = availableWidth < 360;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Back button (if present) + Crest + Bold Brand Name & Subtitle
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showBackButton) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20, color: RakshaSetuColors.slate800),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        tooltip: 'Back',
                        onPressed: onBack ?? () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/dashboard');
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                    ],

                    // Crest Emblem matching military crest in specification
                    InkWell(
                      onTap: () => context.go('/dashboard'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x6622D3EE), width: 1.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F06B6D4),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            'assets/images/rakshasetu_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              decoration: const BoxDecoration(
                                gradient: RakshaSetuColors.obsidianGradient,
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                size: 21,
                                color: Color(0xFF67E8F9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Brand Typography: FittedBox ensures full name visibility without clipping
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'Public Sans',
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      color: Color(0xFF0A1F2C),
                                    ),
                                    children: [
                                      TextSpan(text: 'Raksha'),
                                      TextSpan(
                                        text: 'Setu',
                                        style: TextStyle(
                                          color: Color(0xFF0891B2), // cyan-600
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (availableWidth >= 385 && !showBackButton && trailing == null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xB3CFFAFE), // cyan-accent-tag
                                      borderRadius: BorderRadius.circular(9999),
                                      border: Border.all(color: const Color(0x4D06B6D4), width: 1.0),
                                    ),
                                    child: const Text(
                                      'AF-WELFARE',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0E7490),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            subtitle ?? 'India’s Armed Forces Wellbeing Grid',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                              color: Color(0xFF475569), // slate-600
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right: Optional Trailing, Welfare Firewall Badge, Crisis & SignOut
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailing != null) ...[
                    trailing!,
                    const SizedBox(width: 4),
                  ],
                  if (availableWidth >= 350) const WelfareBanner(compact: true),
                  if (showCrisisButton && !isVeryNarrow) ...[
                    const SizedBox(width: 3),
                    IconButton(
                      icon: const Icon(Icons.emergency_rounded, color: RakshaSetuColors.rose600, size: 19),
                      tooltip: '24x7 Crisis Support',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: () => context.push('/crisis'),
                    ),
                  ],
                  if (onSignOut != null) ...[
                    const SizedBox(width: 2),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: RakshaSetuColors.slate600, size: 18),
                      tooltip: 'Sign Out',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: onSignOut,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
