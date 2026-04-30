import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.indigo,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.indigo,
        secondary: AppColors.orange,
        surface: AppColors.cardBg,
        error: AppColors.red,
      ),
      fontFamily: '.SF Pro Text', // Fallback to system San Francisco
      textTheme: const TextTheme(
        displayLarge: TextStyle(letterSpacing: -0.5, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(letterSpacing: -0.5, fontWeight: FontWeight.bold, color: Colors.white),
        headlineLarge: TextStyle(letterSpacing: -0.5, fontWeight: FontWeight.w700, color: Colors.white),
        headlineMedium: TextStyle(letterSpacing: -0.5, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: TextStyle(letterSpacing: -0.5, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }

  static TextStyle get monoStyle {
    return const TextStyle(
      fontFamily: 'monospace',
      color: AppColors.indigoLight,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );
  }
}
