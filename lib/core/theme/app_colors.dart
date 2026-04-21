import 'package:flutter/material.dart';

extension AppColorsX on ColorScheme {
  bool get _isDark => brightness == Brightness.dark;

  Color get backgroundPrimary =>
      _isDark ? const Color(0xFF0D1117) : const Color(0xFFFFFFFF);

  Color get backgroundSecondary =>
      _isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA);

  Color get backgroundCard =>
      _isDark ? const Color(0xFF1C2128) : const Color(0xFFFFFFFF);

  Color get backgroundElevated =>
      _isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA);

  Color get accentPrimary =>
      _isDark ? const Color(0xFF00C896) : const Color(0xFF00A87A);

  Color get accentSecondary =>
      _isDark ? const Color(0xFF7C5CFC) : const Color(0xFF6B4FD8);

  Color get textPrimary =>
      _isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1C2128);

  Color get textSecondary =>
      _isDark ? const Color(0xFF8B949E) : const Color(0xFF57606A);

  Color get textMuted =>
      _isDark ? const Color(0xFF484F58) : const Color(0xFFAFB8C1);

  Color get borderDefault =>
      _isDark ? const Color(0x14FFFFFF) : const Color(0x14000000);

  Color get borderSubtle =>
      _isDark ? const Color(0x0AFFFFFF) : const Color(0x0A000000);

  Color get success => _isDark ? const Color(0xFF2EA043) : const Color(0xFF1F883D);

  Color get warning => _isDark ? const Color(0xFFD29922) : const Color(0xFF9A6700);

  Color get danger => _isDark ? const Color(0xFFF85149) : const Color(0xFFCF222E);

  Color get info => _isDark ? const Color(0xFF388BFD) : const Color(0xFF0969DA);
}
