import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFFC107);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF8A8A8A);
  static const background = Color(0xFFF3F4F6);
  static const success = Color(0xFF2ECC71);
  static const danger = Color(0xFFE74C3C);
  static const info = Color(0xFF3498DB);
  static const cardBorder = Color(0xFFE5E7EB);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.dark,
        primary: AppColors.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark,
          foregroundColor: Colors.white,
          minimumSize: const Size(120, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
    );
  }
}
