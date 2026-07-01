import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Color Palette
  static const Color cafeNoir = Color(0xFF4C3D19);
  static const Color kombuGreen = Color(0xFF354024);
  static const Color mossGreen = Color(0xFF889063);
  static const Color tan = Color(0xFFCFBB99);
  static const Color bone = Color(0xFFE5D7C4);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bone,
      colorScheme: const ColorScheme.light(
        primary: cafeNoir,
        secondary: mossGreen,
        surface: bone,
        error: cafeNoir, // Soften errors
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.cormorantGaramond(
          color: cafeNoir,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        titleMedium: GoogleFonts.cormorantGaramond(
          color: cafeNoir,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: kombuGreen,
          height: 1.6,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: kombuGreen,
          height: 1.6,
        ),
      ),
    );
  }
}
