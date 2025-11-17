import 'package:absen/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppThemeLight {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.slate50,

    // PRIMARY COLOR
    primaryColor: AppColors.sky500,
    colorScheme: ColorScheme.light(
      primary: AppColors.sky500,
      secondary: AppColors.cyan500,
    ),

    // BUTTONS
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sky500,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // TEXTFIELD (inputs)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray50,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.sky500, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: TextStyle(color: AppColors.gray400),
      labelStyle: TextStyle(color: AppColors.gray700),
    ),

    // TEXT STYLES
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.gray900,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.gray900,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.gray700),
      bodyMedium: TextStyle(color: AppColors.gray600),
    ),
  );
}
