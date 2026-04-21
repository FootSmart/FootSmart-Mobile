import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App-wide text style constants.
/// Base styles do NOT include color - they inherit from the theme.
/// Use `.copyWith(color: ...)` or `context.textPrimary` for specific colors.
class AppTextStyles {
  AppTextStyles._();

  // Base text style - NO color so it inherits from theme
  static TextStyle get _baseTextStyle => GoogleFonts.inter(height: 1.5);

  // Display Styles (Logo, Headers)
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get displaySmall =>
      _baseTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600);

  // Heading Styles
  static TextStyle get h1 =>
      _baseTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get h2 =>
      _baseTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get h3 =>
      _baseTextStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get h4 =>
      _baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);

  // Body Styles
  static TextStyle get bodyLarge =>
      _baseTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6);

  static TextStyle get bodyMedium =>
      _baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6);

  static TextStyle get bodySmall =>
      _baseTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);

  // Special Purpose Styles
  static TextStyle get tagline => _baseTextStyle.copyWith(
      fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      letterSpacing: 0.2,
      );

  static TextStyle get buttonLarge => _baseTextStyle.copyWith(
        fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      );

  static TextStyle get buttonMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      );

  // Number/Stats Styles (for odds, percentages, etc.)
  static TextStyle get statsLarge => GoogleFonts.inter(
      fontSize: 40,
      fontWeight: FontWeight.w700,
        color: AppColors.accentGreen,
      );

  static TextStyle get statsMedium => GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w700,
        color: AppColors.accentGreen,
      );

  static TextStyle get statsSmall => GoogleFonts.inter(
      fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.accentGreen,
      );

  // Caption & Label Styles - NO hardcoded color
  static TextStyle get caption => _baseTextStyle.copyWith(
        fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
      );

  static TextStyle get label => _baseTextStyle.copyWith(
      fontSize: 11,
        fontWeight: FontWeight.w500,
      letterSpacing: 0.8,
      );

  static TextStyle get overline => _baseTextStyle.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      );

  // Input Field Styles - NO hardcoded color (inherits from theme)
  static TextStyle get inputText => _baseTextStyle.copyWith(
        fontSize: 16,
      fontWeight: FontWeight.w400,
      );

  static TextStyle get inputHint => _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      );

  static TextStyle get inputLabel => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  // Status Styles
  static TextStyle get statusSuccess => _baseTextStyle.copyWith(
      fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.success,
      );

  static TextStyle get statusError => _baseTextStyle.copyWith(
      fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      );

  static TextStyle get statusWarning => _baseTextStyle.copyWith(
      fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.warning,
      );

  // Match Score Styles
  static TextStyle get scoreMain => GoogleFonts.inter(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      );

  static TextStyle get scoreSecondary => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textGrey,
      );
}
