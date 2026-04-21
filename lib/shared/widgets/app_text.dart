import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

enum AppTextVariant {
  display,
  h1,
  h2,
  h3,
  bodyLarge,
  body,
  caption,
  label,
}

enum AppTextTone {
  primary,
  secondary,
  muted,
  success,
  warning,
  danger,
  info,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final AppTextTone tone;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.body,
    this.tone = AppTextTone.primary,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    TextStyle baseStyle;
    switch (variant) {
      case AppTextVariant.display:
        baseStyle = textTheme.displayLarge ?? const TextStyle(fontSize: 28);
        break;
      case AppTextVariant.h1:
        baseStyle = textTheme.headlineLarge ?? const TextStyle(fontSize: 22);
        break;
      case AppTextVariant.h2:
        baseStyle = textTheme.headlineMedium ?? const TextStyle(fontSize: 18);
        break;
      case AppTextVariant.h3:
        baseStyle = textTheme.titleLarge ?? const TextStyle(fontSize: 15);
        break;
      case AppTextVariant.bodyLarge:
        baseStyle = textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
        break;
      case AppTextVariant.body:
        baseStyle = textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
        break;
      case AppTextVariant.caption:
        baseStyle = textTheme.bodySmall ?? const TextStyle(fontSize: 12);
        break;
      case AppTextVariant.label:
        baseStyle = textTheme.labelSmall ?? const TextStyle(fontSize: 11);
        break;
    }

    Color resolvedTone;
    switch (tone) {
      case AppTextTone.primary:
        resolvedTone = colorScheme.textPrimary;
        break;
      case AppTextTone.secondary:
        resolvedTone = colorScheme.textSecondary;
        break;
      case AppTextTone.muted:
        resolvedTone = colorScheme.textMuted;
        break;
      case AppTextTone.success:
        resolvedTone = colorScheme.success;
        break;
      case AppTextTone.warning:
        resolvedTone = colorScheme.warning;
        break;
      case AppTextTone.danger:
        resolvedTone = colorScheme.danger;
        break;
      case AppTextTone.info:
        resolvedTone = colorScheme.info;
        break;
    }

    final offset = ResponsiveHelper.fontScale(context);
    final fontSize = (baseStyle.fontSize ?? 14) + offset;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: baseStyle.copyWith(
        color: resolvedTone,
        fontSize: fontSize,
        fontWeight: fontWeight ?? baseStyle.fontWeight,
      ),
    );
  }
}
