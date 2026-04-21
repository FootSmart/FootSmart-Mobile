import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Extension on BuildContext for easy theme-aware color access.
/// Use these throughout the app instead of hardcoded dark/light colors.
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // ─── Background Colors ─────────────────────────────────────────────────
  /// Main scaffold background
  Color get scaffoldBg => colorScheme.backgroundPrimary;

  /// Card / container background
  Color get cardBg => colorScheme.backgroundCard;

  /// Surface background (slightly different from card)
  Color get surfaceBg => colorScheme.backgroundSecondary;

  /// Elevated surface (used for nav bars, dialogs)
  Color get elevatedBg => colorScheme.backgroundElevated;

  /// Input field fill color
  Color get inputBg => colorScheme.backgroundSecondary;

  // ─── Border Colors ─────────────────────────────────────────────────────
  /// Primary border color
  Color get borderColor => colorScheme.borderDefault;

  /// Subtle border color
  Color get borderSubtle => colorScheme.borderSubtle;

  // ─── Text Colors ───────────────────────────────────────────────────────
  /// Primary text (headings, important text)
  Color get textPrimary => colorScheme.textPrimary;

  /// Secondary text (descriptions, subtitles)
  Color get textSecondary => colorScheme.textSecondary;

  /// Tertiary text (hints, captions)
  Color get textTertiary => colorScheme.textMuted;

  /// Hint text in inputs
  Color get textHint => colorScheme.textMuted;

  // ─── Accent Colors ─────────────────────────────────────────────────────
  /// Primary accent (green)
  Color get accent => colorScheme.accentPrimary;

  /// Secondary accent (orange)
  Color get accentOrange => colorScheme.warning;

  // ─── Component Colors ──────────────────────────────────────────────────
  /// Bottom nav bar background
  Color get navBarBg => colorScheme.backgroundElevated;

  /// Icon color (default)
  Color get iconColor => colorScheme.textPrimary;

  /// Icon color for inactive items
  Color get iconInactive => colorScheme.textMuted;

  /// Shadow color
  Color get shadowColor => isDark
      ? Colors.black.withValues(alpha: 0.3)
      : Colors.black.withValues(alpha: 0.08);

  // ─── Gradient ──────────────────────────────────────────────────────────
  /// Header gradient
  LinearGradient get headerGradient => isDark
      ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.backgroundSecondary, Colors.transparent],
        )
      : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.backgroundSecondary, colorScheme.backgroundPrimary],
        );

  /// Background gradient (for onboarding, splash)
  LinearGradient get bgGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1117), Color(0xFF161B22)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FB), Color(0xFFFFFFFF)],
        );
}
