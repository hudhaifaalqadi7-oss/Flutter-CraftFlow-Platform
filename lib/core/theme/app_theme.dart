import 'package:flutter/material.dart';

const Color primary = Color(0xFF114B5F);
const Color accent = Color(0xFFD4A373);
const Color bgSurface = Color(0xFFFDFBF7);
const Color textMain = Color(0xFF1C2D35);
const Color textMuted = Color(0xFF6B828A);
const Color successColor = Color(0xFF2A9D8F);
const Color warningColor = Color(0xFFE9C46A);
const Color dangerColor = Color(0xFFE76F51);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bgSurface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      surface: bgSurface,
    ),
    fontFamily: 'Arial',
    appBarTheme: const AppBarTheme(
      backgroundColor: bgSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textMain,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: 'Arial',
      ),
      iconTheme: IconThemeData(color: primary),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x11114B5F)),
      ),
    ),
  );
}