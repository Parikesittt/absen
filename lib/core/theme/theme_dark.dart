import 'package:flutter/material.dart';
import 'app_colors_dark.dart';

class AppThemeDark {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppDarkColors.gray900,

      colorScheme: const ColorScheme.dark(
        primary: AppDarkColors.sky500,
        secondary: AppDarkColors.cyan400,
        background: AppDarkColors.gray900,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDarkColors.sky500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDarkColors.gray800,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppDarkColors.gray700),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppDarkColors.sky400, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        hintStyle: TextStyle(color: AppDarkColors.gray500),
        labelStyle: TextStyle(color: AppDarkColors.gray400),
      ),
    );
  }
}
