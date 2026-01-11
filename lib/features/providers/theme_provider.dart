import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode controller
final themeModeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Brand colors (design tokens)
const _primaryLight = Color(0xFF4F46E5); // Indigo
const _primaryDark = Color(0xFF818CF8);
const _secondary = Color(0xFF22D3EE); // Cyan

/// =======================
/// 🌞 LIGHT THEME
/// =======================
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: const ColorScheme.light(
    primary: _primaryLight,
    secondary: _secondary,
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    error: Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Color(0xFF0F172A),
    onSurface: Color(0xFF0F172A),
  ),

  scaffoldBackgroundColor: const Color(0xFFF8FAFC),

  /// Cards (used by auth containers & content surfaces)
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 10,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF0F172A),
    ),
    iconTheme: IconThemeData(color: Color(0xFF0F172A)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Color(0xFF64748B)),
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFF0F172A),
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color(0xFF0F172A),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFF0F172A),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF475569),
    ),
  ),

  iconTheme: const IconThemeData(color: _primaryLight),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: _primaryLight,
    contentTextStyle: const TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
);

/// =======================
/// 🌙 DARK THEME
/// =======================
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: const ColorScheme.dark(
    primary: _primaryDark,
    secondary: _secondary,
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    error: Color(0xFFF87171),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onBackground: Color(0xFFF8FAFC),
    onSurface: Color(0xFFF8FAFC),
  ),

  scaffoldBackgroundColor: const Color(0xFF0F172A),

  cardTheme: CardThemeData(
    color: const Color(0xFF1E293B),
    elevation: 12,
    shadowColor: Colors.black54,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF8FAFC),
    ),
    iconTheme: IconThemeData(color: Color(0xFFF8FAFC)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1E293B),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFFF8FAFC),
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF8FAFC),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFFF8FAFC),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFFCBD5E1),
    ),
  ),

  iconTheme: const IconThemeData(color: _primaryDark),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: _primaryDark,
    contentTextStyle: const TextStyle(color: Colors.black),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
);