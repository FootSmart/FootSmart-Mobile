import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme(ColorScheme colorScheme) {
    final base = GoogleFonts.outfitTextTheme();

    return base.copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.2,
        color: colorScheme.textPrimary,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: colorScheme.textPrimary,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: colorScheme.textPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: colorScheme.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: colorScheme.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: colorScheme.textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: colorScheme.textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
        color: colorScheme.textSecondary,
      ),
    );
  }
}
