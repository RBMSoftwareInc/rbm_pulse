import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  static const String _themeKey = 'theme_mode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeKey);
    if (savedMode != null) {
      if (savedMode == 'ThemeMode.light') {
        _themeMode = ThemeMode.light;
      } else if (savedMode == 'ThemeMode.system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.dark;
      }
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }

  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF2C2C2C),
        onPrimary: Colors.white,
        secondary: Color(0xFF6C6C6C),
        onSecondary: Colors.white,
        error: Color(0xFFD72631),
        onError: Colors.white,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF2C2C2C),
        surfaceContainerHighest: Color(0xFFF5F5F5),
        onSurfaceVariant: Color(0xFF6C6C6C),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Colors.white,
          fontFamily: 'Roboto',
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        color: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Color(0xFF2C2C2C)),
        displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Color(0xFF2C2C2C)),
        displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2C2C2C)),
        headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2C2C2C)),
        headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2C2C2C)),
        titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2C2C2C)),
        titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2C2C2C)),
        titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2C2C2C)),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFF2C2C2C)),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Color(0xFF2C2C2C)),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Color(0xFF6C6C6C)),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2C2C2C)),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6C6C6C)),
        labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6C6C6C)),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFE0E0E0),
        onPrimary: Color(0xFF2C2C2C),
        secondary: Color(0xFFB0B0B0),
        onSecondary: Color(0xFF2C2C2C),
        error: Color(0xFFD72631),
        onError: Colors.white,
        surface: Color(0xFF2C2C2C),
        onSurface: Color(0xFFE0E0E0),
        surfaceContainerHighest: Color(0xFF3A3A3A),
        onSurfaceVariant: Color(0xFFB0B0B0),
      ),
      scaffoldBackgroundColor: const Color(0xFF1B1B1B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Colors.white,
          fontFamily: 'Roboto',
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
        color: const Color(0xFF2C2C2C),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Color(0xFFE0E0E0)),
        displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Color(0xFFE0E0E0)),
        displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE0E0E0)),
        headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE0E0E0)),
        headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE0E0E0)),
        titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE0E0E0)),
        titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE0E0E0)),
        titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE0E0E0)),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Color(0xFFE0E0E0)),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Color(0xFFB0B0B0)),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE0E0E0)),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB0B0B0)),
        labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB0B0B0)),
      ),
    );
  }
}
