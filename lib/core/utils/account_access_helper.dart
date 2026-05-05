import 'package:flutter/material.dart';
import '../models/user.dart';
import '../routes/app_routes.dart';
import '../constants/app_colors.dart';

bool canUseProtectedFeatures(User? user) {
  if (user == null) return false;
  return user.accountStatus == 'active' && user.kycStatus == 'approved';
}

Future<void> showKycRequiredDialog(BuildContext context) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('KYC required'),
      content: const Text('Complete KYC to use this feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            AppRoutes.push(context, AppRoutes.kyc);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGreen,
            foregroundColor: const Color(0xFF0B1220),
          ),
          child: const Text('Verify now'),
        ),
      ],
    ),
  );
}
