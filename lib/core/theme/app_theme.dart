import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00A87A),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF00A87A),
      secondary: const Color(0xFF6B4FD8),
      surface: const Color(0xFFFFFFFF),
      error: const Color(0xFFCF222E),
      outline: const Color(0x14000000),
      outlineVariant: const Color(0x0A000000),
    );

    return _buildTheme(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00C896),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF00C896),
      secondary: const Color(0xFF7C5CFC),
      surface: const Color(0xFF1C2128),
      error: const Color(0xFFF85149),
      outline: const Color(0x14FFFFFF),
      outlineVariant: const Color(0x0AFFFFFF),
    );

    return _buildTheme(scheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.backgroundPrimary,
      canvasColor: colorScheme.backgroundPrimary,
      textTheme: AppTextStyles.textTheme(colorScheme),
      dividerColor: colorScheme.borderDefault,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.backgroundPrimary,
        foregroundColor: colorScheme.textPrimary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: AppTextStyles.textTheme(colorScheme).headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.backgroundCard,
        elevation: colorScheme.brightness == Brightness.dark ? 0 : 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colorScheme.borderDefault),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTextStyles.textTheme(colorScheme)
            .bodyMedium
            ?.copyWith(color: colorScheme.textMuted),
        labelStyle: AppTextStyles.textTheme(colorScheme)
            .bodySmall
            ?.copyWith(color: colorScheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.accentPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          backgroundColor: colorScheme.accentPrimary,
          foregroundColor: colorScheme.brightness == Brightness.dark
              ? const Color(0xFF0D1117)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          foregroundColor: colorScheme.accentPrimary,
          side: BorderSide(color: colorScheme.accentPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.backgroundElevated,
        contentTextStyle: AppTextStyles.textTheme(colorScheme)
            .bodyMedium
            ?.copyWith(color: colorScheme.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
