import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color primaryGreenDark = Color(0xFF16A34A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  static const Color backgroundDark = Color(0xFF0D1110);
  static const Color surfaceDark = Color(0xFF151B18);
  static const Color elevatedDark = Color(0xFF1A2320);
  static const Color textPrimaryDark = Color(0xFFE5E7EB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  static const Color plastic = Color(0xFF3B82F6);
  static const Color paper = Color(0xFFFACC15);
  static const Color glass = Color(0xFF22C55E);
  static const Color metal = Color(0xFF9CA3AF);
  static const Color organic = Color(0xFF8B5E3C);

  static ThemeData lightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      surface: surfaceLight,
      primary: primaryGreen,
      secondary: const Color(0xFF10B981),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
          letterSpacing: -0.2,
        ),
      ),
      textTheme: const TextTheme(
        displaySmall:
            TextStyle(fontSize: 34, height: 1.15, fontWeight: FontWeight.w600),
        headlineSmall:
            TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w600),
        titleLarge:
            TextStyle(fontSize: 22, height: 1.2, fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w500),
        bodyLarge:
            TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w400),
        bodyMedium:
            TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w400),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  static ThemeData darkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
      surface: surfaceDark,
      primary: primaryGreen,
      secondary: const Color(0xFF34D399),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryDark,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: elevatedDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
