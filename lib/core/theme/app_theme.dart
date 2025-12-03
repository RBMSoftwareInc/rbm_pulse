// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const rbmRed = Color(0xFFD72631);
  const rbmBlack = Color(0xFF232323);
  const rbmSurface = Color(0xFFF5F5F8);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: rbmRed,
      brightness: Brightness.dark,
      primary: rbmRed,
      secondary: rbmBlack,
      background: rbmBlack,
      surface: rbmSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: rbmBlack, // <--- Card text default: dark
    ),
    scaffoldBackgroundColor: rbmBlack,
    fontFamily: 'Satoshi',
    textTheme: TextTheme(
      headlineMedium:
          TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: rbmBlack), // <--- for card content
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: rbmRed,
      elevation: 4,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22),
    ),
    cardTheme: CardTheme(
      elevation: 6,
      color: rbmSurface,
      shadowColor: rbmRed.withOpacity(0.15),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: rbmRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 8,
        shadowColor: Colors.redAccent,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: rbmSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: rbmRed, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: rbmRed.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(15),
      ),
      labelStyle: TextStyle(color: rbmRed, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: rbmRed),
    chipTheme: ChipThemeData(
      backgroundColor: rbmRed.withOpacity(0.07),
      secondarySelectedColor: rbmRed,
      labelStyle: const TextStyle(color: rbmRed),
      shape: const StadiumBorder(),
    ),
  );
}
