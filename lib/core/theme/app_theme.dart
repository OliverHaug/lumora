import 'package:flutter/material.dart';
import 'package:xyz/core/theme/app_colors.dart';
import 'package:xyz/core/theme/app_typography.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xfffaf8f4),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xffdec27a),
      brightness: Brightness.light,
    ),
    textTheme: AppTypography.lightTextTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xfff6f4ef),
      hintStyle: const TextStyle(color: Colors.black54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(28),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(horizontal: 15),
      ),
    ),
  );
}
