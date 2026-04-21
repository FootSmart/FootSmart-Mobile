import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isSmall(BuildContext context) => screenWidth(context) < 375;

  static bool isMedium(BuildContext context) =>
      screenWidth(context) >= 375 && screenWidth(context) < 415;

  static bool isLarge(BuildContext context) => screenWidth(context) >= 415;

  static double fontScale(BuildContext context) {
    if (isSmall(context)) return -1;
    if (isLarge(context)) return 1;
    return 0;
  }

  static int exploreGridColumns(BuildContext context) {
    final width = screenWidth(context);
    if (width > 600) return 3;
    return 2;
  }
}
