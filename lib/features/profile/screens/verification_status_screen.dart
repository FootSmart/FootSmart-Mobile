import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';

class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({super.key});

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
        title: Text('Verification Status',
            style: AppTextStyles.h4.copyWith(color: AppColors.textWhite)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A3A2A), Color(0xFF1A2E24)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentGreen),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0x3300FF88),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user_rounded,
                        color: AppColors.accentGreen, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fully Verified',
                            style: AppTextStyles.h4.copyWith(
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Your account is fully verified and active.',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: const Color(0xFFA0A4B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _sectionLabel('Verification Steps'),
            const SizedBox(height: 16),
            const _VerificationStep(
              icon: Icons.email_outlined,
              title: 'Email Address',
              subtitle: 'john.doe@email.com',
              status: _StepStatus.done,
            ),
            const SizedBox(height: 12),
            const _VerificationStep(
              icon: Icons.phone_outlined,
              title: 'Phone Number',
              subtitle: '+1 555 0100',
              status: _StepStatus.done,
            ),
            const SizedBox(height: 12),
            const _VerificationStep(
              icon: Icons.badge_outlined,
              title: 'Government ID',
              subtitle: 'Passport verified',
              status: _StepStatus.done,
            ),
            const SizedBox(height: 12),
            const _VerificationStep(
              icon: Icons.home_outlined,
              title: 'Proof of Address',
              subtitle: 'Utility bill approved',
              status: _StepStatus.done,
            ),
            const SizedBox(height: 12),
            const _VerificationStep(
              icon: Icons.camera_front_outlined,
              title: 'Selfie Check',
              subtitle: 'Identity confirmed',
              status: _StepStatus.done,
            ),
            const SizedBox(height: 28),
            _sectionLabel('Account Limits'),
            const SizedBox(height: 16),
            _LimitRow(label: 'Daily Deposit Limit', value: '\$5,000'),
            const SizedBox(height: 10),
            _LimitRow(label: 'Weekly Withdrawal Limit', value: '\$10,000'),
            const SizedBox(height: 10),
            _LimitRow(label: 'Monthly Bet Limit', value: 'Unlimited'),
            const SizedBox(height: 28),
            _sectionLabel('Documents'),
            const SizedBox(height: 16),
            _DocRow(
                label: 'Passport',
                date: 'Verified Feb 1, 2025',
                expiry: 'Expires Jan 15, 2030'),
            const SizedBox(height: 10),
            _DocRow(
                label: 'Utility Bill',
                date: 'Verified Feb 3, 2025',
                expiry: 'Valid'),
          ],
        ),
      ),
    );
  }

  static Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
            color: const Color(0xFFA0A4B8),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      );
}

enum _StepStatus { done, pending, failed }

class _VerificationStep extends StatelessWidget {
  const _VerificationStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _StepStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData statusIcon;
    switch (status) {
      case _StepStatus.done:
        color = AppColors.accentGreen;
        statusIcon = Icons.check_circle_rounded;
      case _StepStatus.pending:
        color = AppColors.accentOrange;
        statusIcon = Icons.schedule_rounded;
      case _StepStatus.failed:
        color = AppColors.error;
        statusIcon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF252B3D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.accentGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: const Color(0xFFA0A4B8))),
              ],
            ),
          ),
          Icon(statusIcon, color: color, size: 22),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: const Color(0xFFA0A4B8))),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textWhite, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow(
      {required this.label, required this.date, required this.expiry});
  final String label;
  final String date;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined,
              color: AppColors.accentGreen, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(date,
                    style: AppTextStyles.caption
                        .copyWith(color: const Color(0xFFA0A4B8))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x3300FF88),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(expiry,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

