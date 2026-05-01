import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final nav = Container(
      height: 64 + bottomInset,
      decoration: BoxDecoration(
        color: colorScheme.backgroundElevated.withValues(alpha: 0.92),
        border: Border(top: BorderSide(color: colorScheme.borderDefault)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 22,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Row(
        children: [
          _NavItem(
            index: 0,
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
          _NavItem(
            index: 1,
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            label: 'Explore',
          ),
          _NavItem(
            index: 2,
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.sports_soccer_outlined,
            selectedIcon: Icons.sports_soccer,
            label: 'Bet',
            emphasized: true,
          ),
          _NavItem(
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet,
            label: 'Wallet',
          ),
          _NavItem(
            index: 4,
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );

    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    if (isIOS) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: nav,
        ),
      );
    }

    return nav;
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool emphasized;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = index == currentIndex;

    final color =
        selected ? colorScheme.accentPrimary : colorScheme.textSecondary;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: () => onTap(index),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Container(
                    padding: emphasized
                        ? const EdgeInsets.all(AppSpacing.xs)
                        : EdgeInsets.zero,
                    decoration: emphasized
                        ? BoxDecoration(
                            color: selected
                                ? colorScheme.accentPrimary
                                    .withValues(alpha: 0.18)
                                : colorScheme.borderSubtle,
                            border: Border.all(
                              color: selected
                                  ? colorScheme.accentPrimary
                                      .withValues(alpha: 0.5)
                                  : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          )
                        : null,
                    child: Icon(
                      selected ? selectedIcon : icon,
                      size: emphasized ? 24 : 22,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
