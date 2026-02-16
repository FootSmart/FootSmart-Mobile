import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';

void handleBottomNavTap(
  BuildContext context, {
  required int currentIndex,
  required int index,
}) {
  if (index == currentIndex) {
    return;
  }

  const targetRouteByIndex = <int, String>{
    0: AppRoutes.home,
    1: AppRoutes.explore,
    2: AppRoutes.betting,
    3: AppRoutes.wallet,
    4: AppRoutes.profile,
  };

  final targetRoute = targetRouteByIndex[index];
  if (targetRoute == null) {
    return;
  }

  Navigator.of(context).pushReplacementNamed(targetRoute);
}
