import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFCD8B53),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFCD8B53),
      secondary: const Color(0xFF9A6034),
      surface: const Color(0xFFFFFBF7),
      error: const Color(0xFFD64C40),
      outline: const Color(0x33CD8B53),
      outlineVariant: const Color(0x1FCD8B53),
    );

    return _buildTheme(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFCD8B53),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFCD8B53),
      secondary: const Color(0xFFE8B484),
      surface: const Color(0xFF102824),
      error: const Color(0xFFFF7B72),
      outline: const Color(0x66CD8B53),
      outlineVariant: const Color(0x29CD8B53),
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
        elevation: 0,
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
          foregroundColor: const Color(0xFF1E1711),
          elevation: 0,
          shadowColor: Colors.transparent,
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
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        side: BorderSide(color: colorScheme.borderDefault, width: 1.4),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.accentPrimary;
          }
          return colorScheme.backgroundSecondary;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF1E1711)),
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
