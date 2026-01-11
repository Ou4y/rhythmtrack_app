import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF2563EB),
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF2563EB),
    secondary: const Color(0xFF38BDF8),
    background: const Color(0xFFF5F7FB),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black87,
    onSurface: Colors.black87,
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F7FB),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2563EB),
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
    ),
  ),
  cardColor: Colors.white,
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    shadowColor: Colors.black12,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2563EB),
    shape: CircleBorder(),
    elevation: 8,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF2563EB),
    contentTextStyle: TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFFF5F7FB),
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(24))),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.85),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    hintStyle: const TextStyle(color: Colors.black38),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 15, color: Colors.black87),
    bodySmall: TextStyle(fontSize: 13, color: Colors.black54),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF2563EB)),
  buttonTheme: const ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
    buttonColor: Color(0xFF2563EB),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF6366F1),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF6366F1),
    secondary: const Color(0xFF38BDF8),
    background: const Color(0xFF181A20),
    surface: const Color(0xFF23243A),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF181A20),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF6366F1),
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
    ),
  ),
  cardColor: const Color(0xFF23243A),
  cardTheme: CardThemeData(
    color: const Color(0xFF23243A),
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    shadowColor: Colors.black54,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF6366F1),
    shape: CircleBorder(),
    elevation: 8,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF6366F1),
    contentTextStyle: TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF23243A),
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(24))),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF23243A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    hintStyle: const TextStyle(color: Colors.white54),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 15, color: Colors.white),
    bodySmall: TextStyle(fontSize: 13, color: Colors.white70),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF6366F1)),
  buttonTheme: const ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
    buttonColor: Color(0xFF6366F1),
  ),
);
