import 'package:flutter/material.dart';

class AppColors {
  // backgrounds
  static const Color background = Color(0xFF010101);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF2A2A2A);

  // accent
  static const Color pink = Color(0xFFCCA6C4);
  static const Color pinkText = Color(0xFF010101);

  // text
  static const Color textPrimary = Color(0xFFF0E0EC);
  static const Color textSecondary = Color(0xFF9A8A98);
  static const Color textHint = Color(0xFF6A5A68);

  // pastel accents
  static const Color pastelBlue = Color(0xFFAAC4E8);
  static const Color pastelPurple = Color(0xFFC8AEE8);
  static const Color pastelGreen = Color(0xFFA8D8B0);

  // error
  static const Color error   = Color(0xFFE05252);

  // coalition colors
  static const Color arrakisBg = Color(0xFF2A0808);
  static const Color arrakisAccent = Color(0xFFFF6B6B);

  static const Color coruscantBg = Color(0xFF08112A);
  static const Color coruscantAccent = Color(0xFF6A9FFF);

  static const Color asgardBg = Color(0xFF2A1E08);
  static const Color asgardAccent = Color(0xFFFDC648);
}

class AppTheme {
  static ThemeData get darkPink {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.pink,
        onPrimary: AppColors.pinkText,
        secondary: AppColors.surface,
        onSecondary: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pink,
          foregroundColor: AppColors.pinkText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.surfaceLight, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.surfaceLight, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.pink, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      ),
    );
  }
}