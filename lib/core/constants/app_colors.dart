import 'package:flutter/material.dart';

/// App-wide color constants
/// Supports both dark and light themes
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============ DARK THEME COLORS ============

  // Primary Colors (Dark)
  static const Color primaryDark = Color(0xFF031411);
  static const Color accentGreen = Color(0xFFCD8B53);
  static const Color accentOrange = Color(0xFFE1A86C);

  // Background Colors (Dark)
  static const Color backgroundDark = Color(0xFF0A211D);
  static const Color cardBackground = Color(0xFF102824);
  static const Color surfaceDark = Color(0xFF16332E);

  // Text Colors (Dark)
  static const Color textWhite = Color(0xFFFFF9F2);
  static const Color textGrey = Color(0xFFD8BC9F);
  static const Color textGreyLight = Color(0xFFA38C79);
  static const Color textGreyDark = Color(0xFF8A7464);

  // ============ LIGHT THEME COLORS ============

  // Primary Colors (Light)
  static const Color primaryLight = Color(0xFFF8F1E8);
  static const Color accentGreenLight = Color(0xFFCD8B53);
  static const Color accentOrangeLight = Color(0xFF9A6034);

  // Background Colors (Light)
  static const Color backgroundLight = Color(0xFFFFFBF7);
  static const Color cardBackgroundLight = Color(0xFFFFFBF7);
  static const Color surfaceLight = Color(0xFFF5EBDD);

  // Text Colors (Light)
  static const Color textDark = Color(0xFF1E1711);
  static const Color textGreyMedium = Color(0xFF6D5744);
  static const Color textGreyLightMode = Color(0xFFA38C79);

  // Status Colors
  static const Color success = Color(0xFF1F883D);
  static const Color error = Color(0xFFCF222E);
  static const Color warning = Color(0xFFB4703D);
  static const Color info = Color(0xFF196C87);

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
    colors: [Color(0xFF031411), Color(0xFF0A211D)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCD8B53), Color(0xFFE8B484)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF102824), Color(0xFF16332E)],
  );

  // Overlay & Shadow
  static const Color overlay = Color(0x80000000);
  static const Color shadowColor = Color(0x14000000);

  // Border Colors
  static const Color borderDark = Color(0x66CD8B53);
  static const Color borderLight = Color(0x33CD8B53);

  // Bet Type Colors
  static const Color betWin = success;
  static const Color betDraw = warning;
  static const Color betLoss = error;

  // Helper method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
