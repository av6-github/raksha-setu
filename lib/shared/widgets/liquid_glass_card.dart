// lib/shared/widgets/liquid_glass_card.dart
// Liquid Glass Panels (.lux-glass-card, .lux-glass-inner, .lux-glass-pill),
// Bespoke Obsidian Primary Buttons (.lux-obsidian-btn),
// Circular Secondary Buttons (.lux-secondary-btn), and
// Liquid Glass Voice Assistant Buttons (.liquid-glass-lens)

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/rakshasetu_theme.dart';

/// Lux Glass Card: Frosted blur, high-refraction borders, cyan-tinted drop-shadow
/// Matches `.lux-glass-card`
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? borderLeftColor;
  final double borderLeftWidth;
  final VoidCallback? onTap;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 22.0,
    this.borderLeftColor,
    this.borderLeftWidth = 4.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1706B6D4), // 0 14px 34px -8px rgba(6, 182, 212, 0.09)
            blurRadius: 34,
            offset: Offset(0, 14),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: Color(0x0A0F172A), // 0 4px 12px -2px rgba(15, 23, 42, 0.04)
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: RakshaSetuColors.glassCardBackground,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: RakshaSetuColors.glassCardBorder,
                width: 1.0,
              ),
            ),
            child: borderLeftColor != null
                ? Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: borderLeftColor!,
                          width: borderLeftWidth,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 12.0),
                    child: child,
                  )
                : child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: RakshaSetuColors.cyan400.withValues(alpha: 0.15),
          highlightColor: RakshaSetuColors.azure.withValues(alpha: 0.08),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Lux Glass Inner Card: Frosted nested container for internal metrics & flags
/// Matches `.lux-glass-inner`
class LiquidGlassInner extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const LiquidGlassInner({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12.0),
    this.borderRadius = 16.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget inner = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: RakshaSetuColors.glassInnerBackground,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: RakshaSetuColors.glassInnerBorder,
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F06B6D4), // 0 4px 14px -3px rgba(6, 182, 212, 0.06)
                blurRadius: 14,
                offset: Offset(0, 4),
                spreadRadius: -3,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: inner,
      );
    }

    return inner;
  }
}

/// Lux Glass Pill: Frosted pill tag/badge for statuses, labels, and firewall indicators
/// Matches `.lux-glass-pill`
class LiquidGlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const LiquidGlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget pill = ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: RakshaSetuColors.glassPillBackground,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: RakshaSetuColors.glassPillBorder,
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1406B6D4), // 0 2px 8px rgba(6, 182, 212, 0.08)
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: onTap,
        child: pill,
      );
    }
    return pill;
  }
}

/// Bespoke Obsidian Primary Action Button
/// Matches `.lux-obsidian-btn`
class ObsidianButton extends StatefulWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final double? width;
  final EdgeInsetsGeometry padding;

  const ObsidianButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
  });

  @override
  State<ObsidianButton> createState() => _ObsidianButtonState();
}

class _ObsidianButtonState extends State<ObsidianButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.985 : (_isHovered ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              gradient: RakshaSetuColors.obsidianGradient,
              border: Border.all(
                color: _isHovered
                    ? const Color(0xA622D3EE) // rgba(34, 211, 238, 0.65)
                    : const Color(0x6122D3EE), // rgba(34, 211, 238, 0.38)
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0x6106B6D4) // rgba(6, 182, 212, 0.38)
                      : const Color(0x4706B6D4), // rgba(6, 182, 212, 0.28)
                  blurRadius: _isHovered ? 28 : 22,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
                const BoxShadow(
                  color: Color(0x730A1F2C), // rgba(10, 31, 44, 0.45)
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: Stack(
                children: [
                  // Top subtle glass reflection rim
                  Positioned(
                    top: 0,
                    left: 20,
                    right: 20,
                    height: 14,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x4DFFFFFF), Color(0x00FFFFFF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(9999)),
                      ),
                    ),
                  ),
                  // Button Content
                  Padding(
                    padding: widget.padding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: 9),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tactical Circular Secondary Action Button (44x44)
/// Matches `.lux-secondary-btn`
class CircularSecondaryButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  const CircularSecondaryButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 44.0,
  });

  @override
  State<CircularSecondaryButton> createState() => _CircularSecondaryButtonState();
}

class _CircularSecondaryButtonState extends State<CircularSecondaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isHovered ? Colors.white : const Color(0xE0FFFFFF),
              border: Border.all(
                color: _isHovered
                    ? const Color(0x8C06B6D4) // rgba(6, 182, 212, 0.55)
                    : const Color(0x400E7490), // rgba(14, 116, 144, 0.25)
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0x3806B6D4)
                      : const Color(0x1F06B6D4), // 0 4px 12px -2px rgba(6, 182, 212, 0.12)
                  blurRadius: _isHovered ? 16 : 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: widget.icon),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Authentic Liquid Glass Lens Button for Voice Assistant and primary glass CTAs
/// Matches `.liquid-glass-lens` & `.liquid-glass-btn-wrapper`
class LiquidGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double? width;

  const LiquidGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
    this.width,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : (_isHovered ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0x4006B6D4) // rgba(6, 182, 212, 0.25)
                      : const Color(0x2906B6D4), // 0 10px 26px rgba(6, 182, 212, 0.16)
                  blurRadius: _isHovered ? 28 : 22,
                  offset: const Offset(0, 8),
                ),
                const BoxShadow(
                  color: Color(0x5222D3EE), // 0 0 0 1px rgba(34, 211, 238, 0.32)
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RakshaSetuColors.liquidGlassLensGradient,
                    borderRadius: BorderRadius.all(Radius.circular(9999)),
                    border: Border.fromBorderSide(
                      BorderSide(color: Color(0xFAFFFFFF), width: 1.0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top rim light
                      Positioned(
                        top: 1,
                        left: 20,
                        right: 20,
                        height: 14,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFAFFFFFF), Color(0x26FFFFFF)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(9999)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: widget.padding,
                        child: Center(child: widget.child),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Metal Button for backwards compatibility across existing forms,
/// now powered by the bespoke Obsidian button aesthetic
class MetalButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final double? width;
  final EdgeInsetsGeometry padding;

  const MetalButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
  });

  @override
  Widget build(BuildContext context) {
    return ObsidianButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      width: width,
      padding: padding,
    );
  }
}
