import 'package:flutter/material.dart';
import 'incidencias_colors.dart';

class AppTheme {
  // ==============================================================
  // 1. ColorScheme propio Material 3
  // ==============================================================

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1E3A8A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDBEAFE),
    onPrimaryContainer: Color(0xFF1E293B),
    secondary: Color(0xFF0F766E),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCCFBF1),
    onSecondaryContainer: Color(0xFF115E59),
    tertiary: Color(0xFFB45309),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFEF3C7),
    onTertiaryContainer: Color(0xFF78350F),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF991B1B),
    surface: Color(0xFFF8FAFC),
    onSurface: Color(0xFF0F172A),
    surfaceContainerHighest: Color(0xFFE2E8F0),
    onSurfaceVariant: Color(0xFF475569),
    outline: Color(0xFF94A3B8),
    outlineVariant: Color(0xFFCBD5E1),
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF93C5FD),
    onPrimary: Color(0xFF0F172A),
    primaryContainer: Color(0xFF1E3A8A),
    onPrimaryContainer: Color(0xFFDBEAFE),
    secondary: Color(0xFF5EEAD4),
    onSecondary: Color(0xFF042F2E),
    secondaryContainer: Color(0xFF115E59),
    onSecondaryContainer: Color(0xFFCCFBF1),
    tertiary: Color(0xFFFCD34D),
    onTertiary: Color(0xFF451A03),
    tertiaryContainer: Color(0xFF78350F),
    onTertiaryContainer: Color(0xFFFEF3C7),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF991B1B),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: Color(0xFF0F172A),
    onSurface: Color(0xFFF8FAFC),
    surfaceContainerHighest: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF64748B),
    outlineVariant: Color(0xFF334155),
  );

  // ==============================================================
  // 2. Tipografía coherente (RA1.d)
  // ==============================================================

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.2),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.1),
    titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 15, height: 1.45),
    bodyMedium: TextStyle(fontSize: 13.5, height: 1.4),
    bodySmall: TextStyle(fontSize: 12, height: 1.3),
    labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, letterSpacing: 0.2),
  );

  // ==============================================================
  // 3. Tema Claro
  // ==============================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: _textTheme.apply(
        bodyColor: lightColorScheme.onSurface,
        displayColor: lightColorScheme.onSurface,
      ),
      scaffoldBackgroundColor: lightColorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0.5,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFFBFDBFE),
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      extensions: const [
        IncidenciasColors.light,
      ],
    );
  }

  // ==============================================================
  // 4. Tema Oscuro
  // ==============================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: _textTheme.apply(
        bodyColor: darkColorScheme.onSurface,
        displayColor: darkColorScheme.onSurface,
      ),
      scaffoldBackgroundColor: darkColorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Color(0xFF93C5FD),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: Color(0xFF93C5FD),
        labelColor: Color(0xFF93C5FD),
        unselectedLabelColor: Color(0xFF64748B),
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF93C5FD),
        foregroundColor: Color(0xFF0F172A),
        elevation: 2,
      ),
      extensions: const [
        IncidenciasColors.dark,
      ],
    );
  }
}
