// lib/core/theme/rakshasetu_theme.dart
// RakshaSetu Brand & Arctic Frost Theme System
// Armed Forces Welfare & Resilience Platform Design System

import 'package:flutter/material.dart';

class RakshaSetuColors {
  RakshaSetuColors._();

  // Defence Core Palette
  static const Color navy = Color(0xFF0C2340);
  static const Color shield = Color(0xFF0F3A5D);
  static const Color gold = Color(0xFFC59B27);
  static const Color olive = Color(0xFF4B5320);
  static const Color azure = Color(0xFF0284C7);

  // Arctic Frost Canvas Backdrop
  static const Color background = Color(0xFFFAF8F2);

  // Slate Neutral Scale
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);

  // Sky & Cyan Atmosphere
  static const Color sky600 = Color(0xFF0284C7);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color cyan200 = Color(0xFFA5F3FC);
  static const Color cyan100 = Color(0xFFCFFAFE);

  // Functional Status Colors
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald50 = Color(0xFFECFDF5);

  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber50 = Color(0xFFFFFBEB);

  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose100 = Color(0xFFFFE4E6);

  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple100 = Color(0xFFF3E8FF);

  // Liquid Glass & Luxury Arctic Frost Tokens
  static const Color glassCardBackground = Color(0xB8FFFFFF); // 72% opacity (.lux-glass-card)
  static const Color glassCardBorder = Color(0xE0FFFFFF); // 88% opacity
  static const Color glassInnerBackground = Color(0xC7FFFFFF); // 78% opacity (.lux-glass-inner)
  static const Color glassInnerBorder = Color(0xF0FFFFFF); // 94% opacity
  static const Color glassPillBackground = Color(0xC2FFFFFF); // 76% opacity (.lux-glass-pill)
  static const Color glassPillBorder = Color(0xF2FFFFFF); // 95% opacity
  static const Color glassDockBackground = Color(0xCCFFFFFF); // 80% blended frosted opacity

  // Defence Palette Shades
  static const Color defenceNavy = Color(0xFF081C33);
  static const Color defenceDeep = Color(0xFF0C2340);
  static const Color defenceObsidian = Color(0xFF0A1F2C);
  static const Color defenceSlate = Color(0xFF0E2A38);
  static const Color defenceCyan = Color(0xFF06B6D4);
  static const Color defenceTeal = Color(0xFF0D9488);


  // Gradients
  static const LinearGradient crestGradient = LinearGradient(
    colors: [navy, shield],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient metalBorderGradient = LinearGradient(
    colors: [navy, sky400],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient metalInnerGradient = LinearGradient(
    colors: [shield, azure],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient metalCoreGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryActionGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF06B6D4)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient obsidianGradient = LinearGradient(
    colors: [Color(0xFF0A1F2C), Color(0xFF0E2A38), Color(0xFF155E75)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient liquidGlassLensGradient = LinearGradient(
    colors: [Color(0xF2FFFFFF), Color(0xB8ECFEFF), Color(0xE0CFFAFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class RakshaSetuTheme {
  RakshaSetuTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: RakshaSetuColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: RakshaSetuColors.navy,
        onPrimary: Colors.white,
        primaryContainer: RakshaSetuColors.cyan100,
        onPrimaryContainer: RakshaSetuColors.navy,
        secondary: RakshaSetuColors.azure,
        onSecondary: Colors.white,
        secondaryContainer: RakshaSetuColors.cyan200,
        onSecondaryContainer: RakshaSetuColors.navy,
        tertiary: RakshaSetuColors.gold,
        onTertiary: Colors.white,
        surface: RakshaSetuColors.background,
        onSurface: RakshaSetuColors.slate900,
        surfaceContainerHighest: Color(0xFFF1F5F9),
        error: RakshaSetuColors.rose600,
        onError: Colors.white,
        outline: RakshaSetuColors.slate400,
      ),
      fontFamily: 'Public Sans',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: RakshaSetuColors.slate900),
        titleTextStyle: TextStyle(
          color: RakshaSetuColors.slate900,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Cinzel',
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: RakshaSetuColors.glassCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: RakshaSetuColors.glassCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.75),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RakshaSetuColors.azure, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
