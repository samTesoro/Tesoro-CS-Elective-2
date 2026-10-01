import 'package:flutter/material.dart';

const mainRed = Color(0xFFC8102E);
const darkRed = Color(0xFF8E0B20);
const accentRed = Color(0xFFE31B23);

const pixelBorderColor = Color(0xFF1B1B1B);
const pixelBorderWidth = 3.0;
const inputBorderWidth = pixelBorderWidth;

BoxDecoration pixelBox({required Color color}) => BoxDecoration(
  color: color,
  border: Border.all(color: pixelBorderColor, width: pixelBorderWidth),
  boxShadow: const [
    BoxShadow(color: pixelBorderColor, offset: Offset(4, 4), blurRadius: 0),
  ],
);

const darkControlColor = Color(0xFF2B2B2B);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color controlFillColor(BuildContext context) =>
    _isDark(context) ? darkControlColor : Colors.white;

Color controlTextColor(BuildContext context) =>
    _isDark(context) ? Colors.white : pixelBorderColor;

const _pixelShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.zero,
  side: BorderSide(color: pixelBorderColor, width: pixelBorderWidth),
);

ThemeData createTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final primaryColor = isDark ? accentRed : mainRed;

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'PokemonPixel',
    colorScheme: ColorScheme.fromSeed(
      seedColor: mainRed,
      primary: primaryColor,
      secondary: isDark ? mainRed : darkRed,
      brightness: brightness,
    ),
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF7F7F7),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? darkRed : mainRed,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: const Border(
        bottom: BorderSide(color: pixelBorderColor, width: pixelBorderWidth),
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      shape: _pixelShape,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? darkRed : mainRed,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: _pixelShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : primaryColor,
        backgroundColor: isDark ? darkControlColor : null,
        side: const BorderSide(
          color: pixelBorderColor,
          width: pixelBorderWidth,
        ),
        shape: _pixelShape,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? darkControlColor : Colors.white,
      hintStyle: TextStyle(
        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: pixelBorderColor,
          width: inputBorderWidth,
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: pixelBorderColor,
          width: inputBorderWidth,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: pixelBorderColor,
          width: inputBorderWidth,
        ),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
