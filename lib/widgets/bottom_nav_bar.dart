import 'package:flutter/material.dart';
import '../shared/widgets/app_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
