import 'package:flutter/material.dart';

/// Soft spacing / radius tokens for Viyan.
abstract final class AppTokens {
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double space2xl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 14;

  static const double elevationNone = 0;
  static const double elevationSoft = 1;
}

/// Premium light (pastel) + intentional dark theme for Viyan.
abstract final class AppTheme {
  // —— Light: soft white / muted teal-slate ——
  static const Color primary = Color(0xFF4A7C7A);
  static const Color primarySoft = Color(0xFFE8F2F1);
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1F2933);
  static const Color mutedText = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E9EF);
  static const Color danger = Color(0xFFC83E4D);
  static const Color success = Color(0xFF16845B);
  static const Color warning = Color(0xFFB7791F);
  static const Color info = Color(0xFF3B82C4);

  /// Legacy aliases — map old navy/gold widgets onto the new palette.
  static const Color navy = primary;
  static const Color navySecondary = Color(0xFF3D6866);
  static const Color navySurface = Color(0xFF5A8F8D);
  static const Color navyMuted = Color(0xFF6B9A98);
  static const Color gold = Color(0xFF5B8A88);
  static const Color lightGold = primarySoft;

  // —— Dark: obsidian neutrals + soft pastel accent ——
  static const Color obsidian = Color(0xFF0C0E12);
  static const Color obsidianSurface = Color(0xFF161A22);
  static const Color obsidianElevated = Color(0xFF1E2430);
  static const Color obsidianBorder = Color(0xFF2A3140);
  static const Color obsidianInk = Color(0xFFE8EAED);
  static const Color obsidianMuted = Color(0xFF9AA3B2);
  static const Color obsidianGold = Color(0xFF7EB5B2);

  /// Legacy alias used across existing widgets.
  static const Color paper = background;

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          onPrimary: Colors.white,
          secondary: primary,
          onSecondary: Colors.white,
          error: danger,
          surface: surface,
          onSurface: ink,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      dividerColor: border,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: AppTokens.elevationNone,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          side: const BorderSide(color: border),
        ),
        shadowColor: primary.withValues(alpha: 0.06),
      ),
      inputDecorationTheme: _inputTheme(
        fill: surface,
        borderColor: border,
        focusColor: primary,
        hint: mutedText,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primarySoft,
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(color: ink, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: surface),
      textTheme: _textTheme(ink, mutedText),
    );
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: obsidianGold,
          brightness: Brightness.dark,
        ).copyWith(
          primary: obsidianGold,
          onPrimary: obsidian,
          secondary: obsidianGold,
          onSecondary: obsidian,
          error: danger,
          surface: obsidianSurface,
          onSurface: obsidianInk,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: obsidian,
      dividerColor: obsidianBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: obsidianSurface,
        foregroundColor: obsidianInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: obsidianSurface,
        elevation: AppTokens.elevationNone,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          side: const BorderSide(color: obsidianBorder),
        ),
      ),
      inputDecorationTheme: _inputTheme(
        fill: obsidianElevated,
        borderColor: obsidianBorder,
        focusColor: obsidianGold,
        hint: obsidianMuted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: obsidianGold,
          foregroundColor: obsidian,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: obsidianElevated,
        selectedColor: obsidianElevated,
        side: const BorderSide(color: obsidianBorder),
        labelStyle: const TextStyle(color: obsidianInk, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: obsidianGold,
        foregroundColor: Color(0xFF0C0E12),
        elevation: 2,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: obsidianSurface),
      textTheme: _textTheme(obsidianInk, obsidianMuted),
    );
  }

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color borderColor,
    required Color focusColor,
    required Color hint,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: TextStyle(color: hint, fontSize: 14),
      labelStyle: TextStyle(color: hint, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: focusColor, width: 1.4),
      ),
    );
  }

  static TextTheme _textTheme(Color inkColor, Color muted) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: inkColor,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: inkColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: inkColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: inkColor, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, color: inkColor, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, color: muted, height: 1.35),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: muted,
        letterSpacing: 0.2,
      ),
    );
  }
}
