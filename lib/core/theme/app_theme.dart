import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primary = Color(0xFF5B8DEF); // Dawn Calm primary
  static const Color _secondary = Color(0xFF7ED6C1); // mint
  static const Color _tertiary = Color(0xFFF7B267); // warm accent

  static ThemeData get lightTheme {
    final ColorScheme scheme = ColorScheme.light(
      primary: _primary,
      secondary: _secondary,
      tertiary: _tertiary,
      surface: const Color(0xFFFFFFFF),
      surfaceContainerHighest: const Color(0xFFF8FAFC),
      onPrimary: Colors.white,
      onSecondary: const Color(0xFF0F172A),
      onTertiary: const Color(0xFF0F172A),
      onSurface: const Color(0xFF0F172A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.6),
        backgroundColor: scheme.surface,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final ColorScheme scheme = ColorScheme.dark(
      primary: _primary,
      secondary: _secondary,
      tertiary: _tertiary,
      surface: const Color(0xFF0F172A),
      surfaceContainerHighest: const Color(0xFF1E293B),
      onPrimary: Colors.white,
      onSecondary: const Color(0xFFE2E8F0),
      onTertiary: const Color(0xFFE2E8F0),
      onSurface: const Color(0xFFE2E8F0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.7),
        backgroundColor: scheme.surface,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF111827),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
