import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App-wide text style constants.
/// Base styles do NOT include color - they inherit from the theme.
/// Use `.copyWith(color: ...)` or `context.textPrimary` for specific colors.
class AppTextStyles {
  AppTextStyles._();

  // Base text style - NO color so it inherits from theme
  static TextStyle get _baseTextStyle => GoogleFonts.poppins();

  // Display Styles (Logo, Headers)
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get displaySmall =>
      _baseTextStyle.copyWith(fontSize: 28, fontWeight: FontWeight.bold);

  // Heading Styles
  static TextStyle get h1 =>
      _baseTextStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold);

  static TextStyle get h2 =>
      _baseTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold);

  static TextStyle get h3 =>
      _baseTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get h4 =>
      _baseTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600);

  // Body Styles
  static TextStyle get bodyLarge =>
      _baseTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.normal);

  static TextStyle get bodyMedium =>
      _baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal);

  static TextStyle get bodySmall =>
      _baseTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.normal);

  // Special Purpose Styles
  static TextStyle get tagline => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  // Number/Stats Styles (for odds, percentages, etc.)
  static TextStyle get statsLarge => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppColors.accentGreen,
      );

  static TextStyle get statsMedium => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.accentGreen,
      );

  static TextStyle get statsSmall => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.accentGreen,
      );

  // Caption & Label Styles - NO hardcoded color
  static TextStyle get caption => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get label => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get overline => _baseTextStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      );

  // Input Field Styles - NO hardcoded color (inherits from theme)
  static TextStyle get inputText => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get inputHint => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get inputLabel => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  // Status Styles
  static TextStyle get statusSuccess => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.success,
      );

  static TextStyle get statusError => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      );

  static TextStyle get statusWarning => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.warning,
      );

  // Match Score Styles
  static TextStyle get scoreMain => GoogleFonts.inter(
        fontSize: 64,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get scoreSecondary => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textGrey,
      );
}
