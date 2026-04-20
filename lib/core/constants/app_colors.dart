import 'package:flutter/material.dart';

/// App-wide color constants
/// Supports both dark and light themes
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============ DARK THEME COLORS ============

  // Primary Colors (Dark)
  static const Color primaryDark = Color(0xFF0B1220); // Deep dark navy
  static const Color accentGreen = Color(0xFF00FF88); // Electric green
  static const Color accentOrange = Color(0xFFFF7A00); // Secondary accent

  // Background Colors (Dark)
  static const Color backgroundDark = Color(0xFF1A1A1A); // Dark charcoal
  static const Color cardBackground = Color(0xFF252525);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors (Dark)
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B0B0);
  static const Color textGreyLight = Color(0xFF808080);
  static const Color textGreyDark = Color(0xFF606060);

  // ============ LIGHT THEME COLORS ============

  // Primary Colors (Light)
  static const Color primaryLight = Color(0xFFF5F7FA); // Light background
  static const Color accentGreenLight = Color(0xFF00CC70); // Softer green
  static const Color accentOrangeLight = Color(0xFFFF8C00); // Softer orange

  // Background Colors (Light)
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure white
  static const Color cardBackgroundLight = Color(0xFFF5F7FA); // Light grey
  static const Color surfaceLight = Color(0xFFFFFFFF); // White surface

  // Text Colors (Light)
  static const Color textDark = Color(0xFF1A1A1A); // Dark text
  static const Color textGreyMedium = Color(0xFF6B7280); // Medium grey
  static const Color textGreyLightMode =
      Color(0xFF9CA3AF); // Light grey for light mode

  // Status Colors
  static const Color success = Color(0xFF00FF88);
  static const Color error = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFF7A00);
  static const Color info = Color(0xFF4A90E2);

  // Risk Level Colors
  static const Color riskLow = Color(0xFF00FF88);
  static const Color riskMedium = Color(0xFFFFB800);
  static const Color riskHigh = Color(0xFFFF4444);

  // Chart Colors
  static const Color chartGreen = Color(0xFF00FF88);
  static const Color chartRed = Color(0xFFFF4444);
  static const Color chartBlue = Color(0xFF4A90E2);
  static const Color chartPurple = Color(0xFF9D4EDD);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1220), Color(0xFF1A2332)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00FF88), Color(0xFF00CC70)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF252525), Color(0xFF1E1E1E)],
  );

  // Overlay & Shadow
  static const Color overlay = Color(0x80000000);
  static const Color shadowColor = Color(0x40000000);

  // Border Colors
  static const Color borderDark = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFF3A3A3A);

  // Bet Type Colors
  static const Color betWin = Color(0xFF00FF88);
  static const Color betDraw = Color(0xFFFFB800);
  static const Color betLoss = Color(0xFFFF4444);

  // Helper method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
