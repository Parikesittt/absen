import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  // Background Gradient: from-sky-400 via-cyan-400 to-blue-500
  static const background = LinearGradient(
    colors: [AppColors.sky400, AppColors.cyan400, AppColors.blue500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary Button Gradient: from-sky-500 to-cyan-500
  static const primaryButton = LinearGradient(
    colors: [AppColors.sky500, AppColors.cyan500],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Profile Card Gradient
  static const profileCard = LinearGradient(
    colors: [AppColors.sky500, AppColors.cyan500],
  );

  // Avatar fallback gradient
  static const avatar = LinearGradient(
    colors: [AppColors.sky400, AppColors.cyan500],
  );
}
