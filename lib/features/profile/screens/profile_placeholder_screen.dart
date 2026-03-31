import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';

/// Reusable "coming soon" placeholder screen used by all profile sub-screens.
class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: AppTextStyles.h4.copyWith(color: AppColors.textWhite),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF252B3D)),
              ),
              child: Icon(icon, size: 52, color: AppColors.accentGreen),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: AppColors.textWhite),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Coming soon',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: const Color(0xFFA0A4B8)),
            ),
          ],
        ),
      ),
    );
  }
}
