import 'package:flutter/material.dart';
import '../theme/app_theme.dart' as design;

/// Compatibility wrapper kept for existing imports.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => design.AppTheme.dark();
  static ThemeData get lightTheme => design.AppTheme.light();
}
