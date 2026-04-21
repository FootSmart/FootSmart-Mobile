import 'package:flutter/material.dart';

/// App-wide color constants
/// Supports both dark and light themes
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============ DARK THEME COLORS ============

  // Primary Colors (Dark)
  static const Color primaryDark = Color(0xFF0D1117);
  static const Color accentGreen = Color(0xFF00C896);
  static const Color accentOrange = Color(0xFFD29922);

  // Background Colors (Dark)
  static const Color backgroundDark = Color(0xFF161B22);
  static const Color cardBackground = Color(0xFF1C2128);
  static const Color surfaceDark = Color(0xFF21262D);

  // Text Colors (Dark)
  static const Color textWhite = Color(0xFFF0F6FC);
  static const Color textGrey = Color(0xFF8B949E);
  static const Color textGreyLight = Color(0xFFAFB8C1);
  static const Color textGreyDark = Color(0xFF484F58);

  // ============ LIGHT THEME COLORS ============

  // Primary Colors (Light)
  static const Color primaryLight = Color(0xFFF6F8FA);
  static const Color accentGreenLight = Color(0xFF00A87A);
  static const Color accentOrangeLight = Color(0xFF9A6700);

  // Background Colors (Light)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF6F8FA);

  // Text Colors (Light)
  static const Color textDark = Color(0xFF1C2128);
  static const Color textGreyMedium = Color(0xFF57606A);
  static const Color textGreyLightMode = Color(0xFFAFB8C1);

  // Status Colors
  static const Color success = Color(0xFF1F883D);
  static const Color error = Color(0xFFCF222E);
  static const Color warning = Color(0xFF9A6700);
  static const Color info = Color(0xFF0969DA);

  // Risk Level Colors
  static const Color riskLow = success;
  static const Color riskMedium = warning;
  static const Color riskHigh = error;

  // Chart Colors
  static const Color chartGreen = accentGreen;
  static const Color chartRed = error;
  static const Color chartBlue = info;
  static const Color chartPurple = Color(0xFF7C5CFC);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C896), Color(0xFF00A87A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C2128), Color(0xFF21262D)],
  );

  // Overlay & Shadow
  static const Color overlay = Color(0x80000000);
  static const Color shadowColor = Color(0x14000000);

  // Border Colors
  static const Color borderDark = Color(0x14FFFFFF);
  static const Color borderLight = Color(0x14000000);

  // Bet Type Colors
  static const Color betWin = success;
  static const Color betDraw = warning;
  static const Color betLoss = error;

  // Helper method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
