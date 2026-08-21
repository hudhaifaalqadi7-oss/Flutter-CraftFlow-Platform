import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const primary = Color(0xFF114B5F);
const accent = Color(0xFFD4A373);
const surface = Color(0xFFFDFBF7);
const muted = Color(0xFF6B828A);

ThemeData buildAppTheme() => ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.cairoTextTheme(),
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
