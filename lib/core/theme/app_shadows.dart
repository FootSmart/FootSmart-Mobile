import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow modalShadow = BoxShadow(
    color: Color(0x29000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}
