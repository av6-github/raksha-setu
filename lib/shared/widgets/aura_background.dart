// lib/shared/widgets/aura_background.dart
// Arctic Frost Atmospheric Aura Gradient Background
// Precise 4-layer composition over #FAF8F2 backdrop

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/rakshasetu_theme.dart';

class AuraBackground extends StatelessWidget {
  final Widget child;

  const AuraBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RakshaSetuColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Aura gradient canvas layer (pointer events ignored)
          const Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _ArcticFrostPainter(),
                ),
              ),
            ),
          ),
          // Content layer (sits above blurred gradient layers)
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ArcticFrostPainter extends CustomPainter {
  const _ArcticFrostPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base background canvas (#FAF8F2)
    final bgPaint = Paint()..color = RakshaSetuColors.background;
    canvas.drawRect(rect, bgPaint);

    // Layer 1: Linear Gradient (135deg) Normal Blend
    // rgba(207,250,254,0.9) -> rgba(165,243,252,0.4) -> rgba(34,211,238,0.3)
    final layer1Paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xE6CFFAFE), // rgba(207, 250, 254, 0.9)
          Color(0x66A5F3FC), // rgba(165, 243, 252, 0.4)
          Color(0x4D22D3EE), // rgba(34, 211, 238, 0.3)
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36.0);
    canvas.drawRect(rect, layer1Paint);

    // Layer 2: Radial Gradient at (30%, 30%), Multiply Blend, opacity 0.84
    // rgba(81, 220, 245, 0.5) -> transparent 40%
    final radius2 = math.max(size.width, size.height) * 0.7;
    final center2 = Offset(size.width * 0.30, size.height * 0.30);
    final layer2Paint = Paint()
      ..blendMode = BlendMode.multiply
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.65,
        colors: [
          const Color(0x6B51DCF5).withValues(alpha: 0.5 * 0.84), // rgba(81, 220, 245, ~0.42)
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center2, radius: radius2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48.0);
    canvas.drawRect(rect, layer2Paint);

    // Layer 3: Radial Gradient at (70%, 70%), Multiply Blend, opacity 0.75
    // rgba(81, 183, 230, 0.4) -> transparent 35%
    final radius3 = math.max(size.width, size.height) * 0.65;
    final center3 = Offset(size.width * 0.70, size.height * 0.70);
    final layer3Paint = Paint()
      ..blendMode = BlendMode.multiply
      ..shader = RadialGradient(
        center: const Alignment(0.4, 0.4),
        radius: 0.6,
        colors: [
          const Color(0x4D51B7E6).withValues(alpha: 0.4 * 0.75), // rgba(81, 183, 230, 0.30)
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center3, radius: radius3))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45.0);
    canvas.drawRect(rect, layer3Paint);

    // Layer 4: Linear Gradient (45deg), Multiply Blend
    // rgba(255,255,255,0.6) -> rgba(255,255,255,0) -> rgba(255,255,255,0.4)
    final layer4Paint = Paint()
      ..blendMode = BlendMode.multiply
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0x99FFFFFF), // rgba(255, 255, 255, 0.6)
          Color(0x00FFFFFF), // transparent
          Color(0x66FFFFFF), // rgba(255, 255, 255, 0.4)
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36.0);
    canvas.drawRect(rect, layer4Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
