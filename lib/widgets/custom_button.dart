import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/extensions/theme_context.dart';

enum ButtonVariant { primary, secondary, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDark),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text, style: _getTextStyle(context)),
            ],
          );

    final buttonChild = switch (variant) {
      ButtonVariant.primary || ButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(context),
          child: child,
        ),
      ButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(context),
          child: child,
        ),
      ButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(context),
          child: child,
        ),
    };

    final button = SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: buttonChild,
    );

    return button;
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: context.accent,
          foregroundColor: AppColors.textDark,
          disabledBackgroundColor: context.accent.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: context.accentOrange,
          foregroundColor: AppColors.textDark,
          disabledBackgroundColor: context.accentOrange.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        );
      case ButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: context.accent,
          side: BorderSide(color: context.accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        );
      case ButtonVariant.text:
        return TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: context.accent,
          elevation: 0,
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = AppTextStyles.buttonLarge;
    switch (variant) {
      case ButtonVariant.primary:
        return baseStyle.copyWith(
          color: AppColors.textDark,
        );
      case ButtonVariant.secondary:
        return baseStyle.copyWith(color: AppColors.textDark);
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return baseStyle.copyWith(color: context.accent);
    }
  }
}
