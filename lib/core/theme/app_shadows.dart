import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 24,
    offset: Offset(0, 10),
  );

  static const BoxShadow modalShadow = BoxShadow(
    color: Color(0x47000000),
    blurRadius: 36,
    offset: Offset(0, 16),
  );
}
