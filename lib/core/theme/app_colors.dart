import 'package:flutter/material.dart';

extension AppColorsX on ColorScheme {
  bool get _isDark => brightness == Brightness.dark;

  Color get backgroundPrimary =>
      _isDark ? const Color(0xFF031411) : const Color(0xFFF8F1E8);

  Color get backgroundSecondary =>
      _isDark ? const Color(0xFF0A211D) : const Color(0xFFF0E4D7);

  Color get backgroundCard =>
      _isDark ? const Color(0xFF102824) : const Color(0xFFFFFBF7);

  Color get backgroundElevated =>
      _isDark ? const Color(0xFF16332E) : const Color(0xFFF5EBDD);

  Color get accentPrimary => const Color(0xFFCD8B53);

  Color get accentSecondary =>
      _isDark ? const Color(0xFFE8B484) : const Color(0xFF9A6034);

  Color get textPrimary =>
      _isDark ? const Color(0xFFFFF9F2) : const Color(0xFF1E1711);

  Color get textSecondary =>
      _isDark ? const Color(0xFFD8BC9F) : const Color(0xFF6D5744);

  Color get textMuted =>
      _isDark ? const Color(0xFF8A7464) : const Color(0xFFA38C79);

  Color get borderDefault =>
      _isDark ? const Color(0x66CD8B53) : const Color(0x33CD8B53);

  Color get borderSubtle =>
      _isDark ? const Color(0x29CD8B53) : const Color(0x1FCD8B53);

  Color get success =>
      _isDark ? const Color(0xFF4AB682) : const Color(0xFF1E8E61);

  Color get warning =>
      _isDark ? const Color(0xFFE1A86C) : const Color(0xFFB4703D);

  Color get danger =>
      _isDark ? const Color(0xFFFF7B72) : const Color(0xFFD64C40);

  Color get info => _isDark ? const Color(0xFF5EB7D5) : const Color(0xFF196C87);
}
