import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

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
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1A2332),
          selectedItemColor: AppColors.accentGreen,
          unselectedItemColor: AppColors.textGreyDark,
          selectedLabelStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: AppTextStyles.caption.copyWith(
            fontSize: 11,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.home_rounded,
                isSelected: currentIndex == 0,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.bar_chart_rounded,
                isSelected: currentIndex == 1,
              ),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.sports_soccer_rounded,
                isSelected: currentIndex == 2,
              ),
              label: 'Bet',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.account_balance_wallet_rounded,
                isSelected: currentIndex == 3,
              ),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.person_rounded,
                isSelected: currentIndex == 4,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? AppColors.accentGreen : AppColors.textGreyDark,
      ),
    );
  }
}
