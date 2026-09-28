import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Kinetic liquid bouncing dots loader matching the kinetic-dots-loader physics:
/// - 4 liquid dots with cyan-to-blue gradient
/// - Specular highlight for liquid gloss
/// - Gravity bounce with squash & stretch (rubber morph)
/// - Reflective shadow breathing
/// - Floor ripple shockwave
class KineticDotsLoader extends StatefulWidget {
  final double size;
  final String? label;
  final Color? primaryColor;
  final Color? secondaryColor;

  const KineticDotsLoader({
    super.key,
    this.size = 20.0,
    this.label,
    this.primaryColor,
    this.secondaryColor,
  });

  /// Compact version for small cards or buttons
  const KineticDotsLoader.compact({
    super.key,
    this.size = 11.0,
    this.label,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<KineticDotsLoader> createState() => _KineticDotsLoaderState();
}

class _KineticDotsLoaderState extends State<KineticDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotCount = 4;
    final dotSize = widget.size;
    final spacing = dotSize * 0.9;
    final jumpHeight = dotSize * 1.8;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: jumpHeight + dotSize + 14,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(dotCount, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing * 0.4),
                  child: _KineticDotItem(
                    animation: _controller,
                    index: index,
                    totalDots: dotCount,
                    dotSize: dotSize,
                    jumpHeight: jumpHeight,
                    primaryColor: widget.primaryColor ?? const Color(0xFF67E8F9),
                    secondaryColor: widget.secondaryColor ?? const Color(0xFF2563EB),
                  ),
                );
              }),
            ),
          ),
          if (widget.label != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.label!,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: math.max(11.0, dotSize * 0.65),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0E7490),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KineticDotItem extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final int totalDots;
  final double dotSize;
  final double jumpHeight;
  final Color primaryColor;
  final Color secondaryColor;

  const _KineticDotItem({
    required this.animation,
    required this.index,
    required this.totalDots,
    required this.dotSize,
    required this.jumpHeight,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // 0.15s offset per dot over 1.4s period
    final double phaseOffset = (index * 0.15) / 1.4;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calculate current normalized cycle t in [0..1]
        double t = (animation.value - phaseOffset) % 1.0;
        if (t < 0) t += 1.0;

        // 1. Gravity Bounce: 0% = floor, 50% = peak, 100% = floor
        // Use smooth sine/parabolic curve for gravity
        final double jumpProgress = (t <= 0.5)
            ? Curves.easeOutCubic.transform(t * 2.0)
            : (1.0 - Curves.easeInCubic.transform((t - 0.5) * 2.0));

        final double translateY = -jumpProgress * jumpHeight;

        // 2. Rubber Morph (Squash & Stretch)
        double scaleX = 1.0;
        double scaleY = 1.0;

        if (t < 0.08 || t > 0.92) {
          // Impact: Squashed
          final factor = (t <= 0.08) ? (1.0 - t / 0.08) : ((t - 0.92) / 0.08);
          scaleX = 1.0 + (0.35 * factor);
          scaleY = 1.0 - (0.35 * factor);
        } else if (t < 0.25) {
          // Rebound stretch rising
          scaleX = 0.92;
          scaleY = 1.10;
        } else if (t > 0.75) {
          // Falling stretch
          scaleX = 0.92;
          scaleY = 1.10;
        } else {
          // Peak sphere
          scaleX = 1.0;
          scaleY = 1.0;
        }

        // 3. Reflective Shadow (breathes inverse to height)
        final double shadowScale = 1.3 - (0.7 * jumpProgress);
        final double shadowOpacity = (0.55 - (0.42 * jumpProgress)).clamp(0.05, 0.6);

        // 4. Floor Ripple (triggers on impact)
        double rippleOpacity = 0.0;
        double rippleScale = 0.6;
        if (t < 0.20) {
          final rProgress = t / 0.20;
          rippleOpacity = (1.0 - rProgress) * 0.6;
          rippleScale = 0.6 + (rProgress * 1.0);
        }

        return SizedBox(
          width: dotSize * 1.5,
          height: jumpHeight + dotSize + 10,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 4. Floor Ripple Shockwave
              if (rippleOpacity > 0.01)
                Positioned(
                  bottom: 2,
                  child: Opacity(
                    opacity: rippleOpacity,
                    child: Transform.scale(
                      scale: rippleScale,
                      child: Container(
                        width: dotSize * 1.8,
                        height: dotSize * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(dotSize * 0.9, dotSize * 0.25),
                          ),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // 3. Reflective Shadow
              Positioned(
                bottom: 3,
                child: Opacity(
                  opacity: shadowOpacity,
                  child: Transform.scale(
                    scaleX: shadowScale,
                    scaleY: 1.0,
                    child: Container(
                      width: dotSize * 1.1,
                      height: dotSize * 0.32,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(dotSize * 0.55, dotSize * 0.16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 1. The Bouncing Dot with 2. Rubber Morph
              Positioned(
                bottom: 8,
                child: Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scaleX: scaleX,
                    scaleY: scaleY,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [primaryColor, secondaryColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.6),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Specular Highlight for Liquid Look
                          Positioned(
                            top: dotSize * 0.18,
                            left: dotSize * 0.20,
                            child: Container(
                              width: dotSize * 0.28,
                              height: dotSize * 0.28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
