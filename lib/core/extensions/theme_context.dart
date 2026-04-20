import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Extension on BuildContext for easy theme-aware color access.
/// Use these throughout the app instead of hardcoded dark/light colors.
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // ─── Background Colors ─────────────────────────────────────────────────
  /// Main scaffold background
  Color get scaffoldBg =>
      isDark ? AppColors.primaryDark : AppColors.backgroundLight;

  /// Card / container background
  Color get cardBg =>
      isDark ? const Color(0xFF1A1F2E) : const Color(0xFFF5F7FA);

  /// Surface background (slightly different from card)
  Color get surfaceBg =>
      isDark ? const Color(0xFF1A1F3A) : const Color(0xFFF0F2F5);

  /// Elevated surface (used for nav bars, dialogs)
  Color get elevatedBg => isDark ? const Color(0xFF1E2A3A) : Colors.white;

  /// Input field fill color
  Color get inputBg =>
      isDark ? AppColors.cardBackground : const Color(0xFFF5F7FA);

  // ─── Border Colors ─────────────────────────────────────────────────────
  /// Primary border color
  Color get borderColor =>
      isDark ? const Color(0xFF252B3D) : const Color(0xFFE5E7EB);

  /// Subtle border color
  Color get borderSubtle =>
      isDark ? const Color(0xFF2A2F4A) : const Color(0xFFE0E3E8);

  // ─── Text Colors ───────────────────────────────────────────────────────
  /// Primary text (headings, important text)
  Color get textPrimary => isDark ? AppColors.textWhite : AppColors.textDark;

  /// Secondary text (descriptions, subtitles)
  Color get textSecondary =>
      isDark ? const Color(0xFFA0A4B8) : AppColors.textGreyMedium;

  /// Tertiary text (hints, captions)
  Color get textTertiary =>
      isDark ? const Color(0xFF8E92BC) : const Color(0xFF9CA3AF);

  /// Hint text in inputs
  Color get textHint =>
      isDark ? AppColors.textGreyDark : const Color(0xFF9CA3AF);

  // ─── Accent Colors ─────────────────────────────────────────────────────
  /// Primary accent (green)
  Color get accent =>
      isDark ? AppColors.accentGreen : AppColors.accentGreenLight;

  /// Secondary accent (orange)
  Color get accentOrange =>
      isDark ? AppColors.accentOrange : AppColors.accentOrangeLight;

  // ─── Component Colors ──────────────────────────────────────────────────
  /// Bottom nav bar background
  Color get navBarBg => isDark ? const Color(0xFF1E2A3A) : Colors.white;

  /// Icon color (default)
  Color get iconColor => isDark ? AppColors.textWhite : AppColors.textDark;

  /// Icon color for inactive items
  Color get iconInactive =>
      isDark ? AppColors.textGreyDark : const Color(0xFF9CA3AF);

  /// Shadow color
  Color get shadowColor => isDark
      ? Colors.black.withValues(alpha: 0.3)
      : Colors.black.withValues(alpha: 0.08);

  // ─── Gradient ──────────────────────────────────────────────────────────
  /// Header gradient
  LinearGradient get headerGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1F2E), Colors.transparent],
        )
      : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFF0F2F5), Colors.white.withValues(alpha: 0)],
        );

  /// Background gradient (for onboarding, splash)
  LinearGradient get bgGradient => isDark
      ? AppColors.primaryGradient
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FB), Color(0xFFFFFFFF)],
        );
}
