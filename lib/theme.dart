import 'package:flutter/material.dart';

// Main Brand Colors
const mainRed = Color(0xFFC8102E);
const darkRed = Color(0xFF8E0B20);
const accentRed = Color(0xFFE31B23);

ThemeData createTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final primaryColor = isDark ? accentRed : mainRed;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mainRed,
      primary: primaryColor,
      secondary: isDark ? mainRed : darkRed,
      brightness: brightness,
    ),
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F7),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? darkRed : mainRed,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: const TextStyle(fontSize: 16),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey.shade400 : Colors.grey,
      ),
    ),
  );
}

final lightTheme = createTheme(Brightness.light);
final darkTheme = createTheme(Brightness.dark);