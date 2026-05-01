import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';

class ResponsibleGamblingScreen extends StatefulWidget {
  const ResponsibleGamblingScreen({super.key});

  @override
  State<ResponsibleGamblingScreen> createState() =>
      _ResponsibleGamblingScreenState();
}

class _ResponsibleGamblingScreenState
    extends State<ResponsibleGamblingScreen> {
  double _dailyLimit = 50;
  double _weeklyLimit = 200;
  double _monthlyLimit = 500;
  bool _selfExclusion = false;
  bool _coolingOff = false;
  bool _realityChecks = true;

  void _confirmSelfExclusion() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Self-Exclusion',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
        content: Text(
          'Self-exclusion will lock your account from gambling for a minimum of 6 months. This cannot be reversed. Are you sure?',
          style: AppTextStyles.bodyMedium
              .copyWith(color: const Color(0xFFA0A4B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: const Color(0xFFA0A4B8))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _selfExclusion = true);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Enable',
                style: AppTextStyles.buttonMedium
                    .copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
        title: Text('Responsible Gambling',
            style: AppTextStyles.h4.copyWith(color: AppColors.textWhite)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x33FF7A00),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentOrange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.accentOrange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gamble responsibly. Only bet what you can afford to lose. 18+ only.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.accentOrange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _sectionLabel('This Week\'s Activity'),
            const SizedBox(height: 12),
            const _ActivityBar(label: 'Wagered', value: 125, max: 200, unit: '\$'),
            const SizedBox(height: 10),
            const _ActivityBar(label: 'Bets Placed', value: 7, max: 30, unit: ''),
            const SizedBox(height: 10),
            const _ActivityBar(
                label: 'Time Spent', value: 3.5, max: 10, unit: 'h'),
            const SizedBox(height: 28),
            _sectionLabel('Deposit Limits'),
            const SizedBox(height: 8),
            Text(
              'Set maximum amounts you can deposit per period.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: const Color(0xFFA0A4B8)),
            ),
            const SizedBox(height: 16),
            _LimitSlider(
              label: 'Daily Limit',
              value: _dailyLimit,
              max: 500,
              onChanged: (v) => setState(() => _dailyLimit = v),
            ),
            const SizedBox(height: 16),
            _LimitSlider(
              label: 'Weekly Limit',
              value: _weeklyLimit,
              max: 2000,
              onChanged: (v) => setState(() => _weeklyLimit = v),
            ),
            const SizedBox(height: 16),
            _LimitSlider(
              label: 'Monthly Limit',
              value: _monthlyLimit,
              max: 5000,
              onChanged: (v) => setState(() => _monthlyLimit = v),
            ),
            const SizedBox(height: 28),
            _sectionLabel('Safety Tools'),
            const SizedBox(height: 12),
            _ToggleCard(
              icon: Icons.timer_outlined,
              title: 'Reality Checks',
              subtitle: 'Get reminded every 30 minutes while gambling.',
              value: _realityChecks,
              color: AppColors.accentGreen,
              onChanged: (v) => setState(() => _realityChecks = v),
            ),
            const SizedBox(height: 10),
            _ToggleCard(
              icon: Icons.pause_circle_outline_rounded,
              title: 'Cooling-Off Period',
              subtitle: 'Temporarily pause betting for 24–72 hours.',
              value: _coolingOff,
              color: AppColors.accentOrange,
              onChanged: (v) => setState(() => _coolingOff = v),
            ),
            const SizedBox(height: 10),
            _ToggleCard(
              icon: Icons.block_rounded,
              title: 'Self-Exclusion',
              subtitle: 'Permanently exclude yourself from gambling.',
              value: _selfExclusion,
              color: AppColors.error,
              onChanged: (v) {
                if (v) {
                  _confirmSelfExclusion();
                } else {
                  setState(() => _selfExclusion = false);
                }
              },
            ),
            const SizedBox(height: 28),
            _sectionLabel('Support Resources'),
            const SizedBox(height: 12),
            const _ResourceTile(
              title: 'GamCare',
              subtitle: 'Free support for gambling problems',
              url: 'www.gamcare.org.uk',
              icon: Icons.support_agent_rounded,
            ),
            const SizedBox(height: 10),
            const _ResourceTile(
              title: 'Gamblers Anonymous',
              subtitle: 'Community support groups',
              url: 'www.gamblersanonymous.org',
              icon: Icons.groups_outlined,
            ),
            const SizedBox(height: 10),
            const _ResourceTile(
              title: 'BeGambleAware',
              subtitle: 'Information & advice',
              url: 'www.begambleaware.org',
              icon: Icons.info_outline_rounded,
            ),
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

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({
    required this.label,
    required this.value,
    required this.max,
    required this.unit,
  });

  final String label;
  final double value;
  final double max;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final pct = (value / max).clamp(0.0, 1.0);
    final color =
        pct < 0.6 ? AppColors.accentGreen : pct < 0.85 ? AppColors.accentOrange : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: const Color(0xFFA0A4B8))),
              Text('$unit$value / $unit$max',
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: const Color(0xFF252B3D),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitSlider extends StatelessWidget {
  const _LimitSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              Text('\$${value.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accentGreen,
              inactiveTrackColor: const Color(0xFF252B3D),
              thumbColor: AppColors.accentGreen,
              overlayColor: const Color(0x2200FF88),
            ),
            child: Slider(
              value: value,
              max: max,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: value ? color.withAlpha(120) : const Color(0xFF252B3D)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: const Color(0xFFA0A4B8))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
                borderRadius: BorderRadius.circular(10)),
            child:
                Icon(icon, size: 20, color: AppColors.accentGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: const Color(0xFFA0A4B8))),
                Text(url,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.accentGreen)),
              ],
            ),
          ),
          const Icon(Icons.open_in_new_rounded,
              color: Color(0xFFA0A4B8), size: 18),
        ],
      ),
    );
  }
}

