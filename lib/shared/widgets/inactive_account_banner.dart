import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';

class InactiveAccountBanner extends StatelessWidget {
  const InactiveAccountBanner({
    super.key,
    required this.isVisible,
  });

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B1A20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6B2E3A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account inactive',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete KYC to unlock betting, wallet, and protected features.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFFE3C7CE),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => AppRoutes.push(context, AppRoutes.kyc),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentGreen,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Verify now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
