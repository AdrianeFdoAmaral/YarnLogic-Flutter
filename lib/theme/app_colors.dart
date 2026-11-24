// theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFDFBF9);
  static const terracotta = Color(0xFFCE6D46);
  static const terracottaBorder = Color(0xFFD88A6C);
  static const peachCard = Color(0xFFF7EFEA);
  static const inputFill = Color(0xFFF3EFEA);
  static const textPrimary = Color(0xFF26211F);
  static const textMuted = Color(0xFF7D7570);
  static const badgeGreenBg = Color(0xFFE5ECE0);
  static const badgeGreenText = Color(0xFF4E6342);
  static const dividerSoft = Color(0xFFE5DDD7);
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.terracotta,
          primary: AppColors.terracotta,
          surface: AppColors.background,
        ),
        fontFamily: 'sans-serif',
      );
}