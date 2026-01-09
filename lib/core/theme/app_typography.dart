import 'package:flutter/material.dart';
import 'package:lumora/core/theme/app_colors.dart';

class AppTypography {
  static const String? baseFamily = null;

  static const wR = FontWeight.w400;
  static const wM = FontWeight.w500;
  static const wS = FontWeight.w600;
  static const wB = FontWeight.w700;

  static const Color _text = AppColors.black;
  static Color _muted(double o) => _text.withValues(alpha: o);

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontFamily: baseFamily,
      fontSize: 30,
      height: 1.15,
      fontWeight: wB,
      color: _text,
    ),
    headlineMedium: TextStyle(
      fontFamily: baseFamily,
      fontSize: 26,
      height: 1.2,
      fontWeight: wB,
      color: _text,
    ),

    titleLarge: TextStyle(
      fontFamily: baseFamily,
      fontSize: 20,
      height: 1.25,
      fontWeight: wS,
      color: _text,
    ),
    titleMedium: TextStyle(
      fontFamily: baseFamily,
      fontSize: 17,
      height: 1.25,
      fontWeight: wS,
      color: _text,
    ),
    titleSmall: TextStyle(
      fontFamily: baseFamily,
      fontSize: 15,
      height: 1.25,
      fontWeight: wM,
      color: _text,
    ),

    bodyLarge: TextStyle(
      fontFamily: baseFamily,
      fontSize: 16.5,
      height: 1.4,
      fontWeight: wR,
      color: _text,
    ),
    bodyMedium: TextStyle(
      fontFamily: baseFamily,
      fontSize: 15,
      height: 1.4,
      fontWeight: wR,
      color: _text,
    ),
    bodySmall: TextStyle(
      fontFamily: baseFamily,
      fontSize: 13.5,
      height: 1.35,
      fontWeight: wR,
      color: _muted(.75),
    ),

    labelLarge: TextStyle(
      fontFamily: baseFamily,
      fontSize: 15,
      height: 1.2,
      fontWeight: wS,
      color: _text,
      letterSpacing: .1,
    ),
    labelMedium: TextStyle(
      fontFamily: baseFamily,
      fontSize: 13.5,
      height: 1.2,
      fontWeight: wS,
      color: _text,
      letterSpacing: .1,
    ),
    labelSmall: TextStyle(
      fontFamily: baseFamily,
      fontSize: 12,
      height: 1.15,
      fontWeight: wM,
      color: _muted(.8),
      letterSpacing: .15,
    ),
  );
}
