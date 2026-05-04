import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // --- preferences state ---
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;

  bool _betResults = true;
  bool _matchStart = true;
  bool _liveScore = false;
  bool _promotions = true;
  bool _deposits = true;
  bool _withdrawals = true;
  bool _security = true;
  bool _newsletter = false;

  static const List<_NotifItem> _recent = [
    _NotifItem(
      icon: Icons.check_circle_rounded,
      color: AppColors.accentGreen,
      title: 'Bet Won!',
      body: 'Your bet on Man City vs Liverpool paid out \$52.50.',
      time: '2h ago',
    ),
    _NotifItem(
      icon: Icons.sports_soccer_rounded,
      color: Color(0xFF4A90E2),
      title: 'Match Starting',
      body: 'Bayern vs Dortmund kicks off in 15 minutes.',
      time: '5h ago',
    ),
    _NotifItem(
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.accentGreen,
      title: 'Deposit Confirmed',
      body: '\$100.00 added to your wallet via Credit Card.',
      time: 'Yesterday',
    ),
    _NotifItem(
      icon: Icons.local_offer_rounded,
      color: AppColors.accentOrange,
      title: 'New Promotion',
      body: 'Deposit \$50 this weekend and get a 20% bonus!',
      time: '2 days ago',
    ),
    _NotifItem(
      icon: Icons.cancel_rounded,
      color: Color(0xFFF87171),
      title: 'Bet Settled',
      body: 'Your bet on Barcelona vs Real Madrid was lost.',
      time: '3 days ago',
    ),
  ];

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
        title: Text('Notifications',
            style: AppTextStyles.h4.copyWith(color: AppColors.textWhite)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Clear all',
                style: AppTextStyles.bodySmall
                    .copyWith(color: const Color(0xFFA0A4B8))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Channels'),
            const SizedBox(height: 12),
            _ChannelCard(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'In-app & device alerts',
              value: _pushEnabled,
              onChanged: (v) => setState(() => _pushEnabled = v),
            ),
            const SizedBox(height: 10),
            _ChannelCard(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Sent to john.doe@email.com',
              value: _emailEnabled,
              onChanged: (v) => setState(() => _emailEnabled = v),
            ),
            const SizedBox(height: 10),
            _ChannelCard(
              icon: Icons.sms_outlined,
              title: 'SMS Notifications',
              subtitle: 'Sent to +1 555 0100',
              value: _smsEnabled,
              onChanged: (v) => setState(() => _smsEnabled = v),
            ),
            const SizedBox(height: 28),
            _sectionLabel('Betting'),
            const SizedBox(height: 12),
            _ToggleRow(
                label: 'Bet Results',
                value: _betResults,
                onChanged: (v) => setState(() => _betResults = v)),
            _ToggleRow(
                label: 'Match Start Reminders',
                value: _matchStart,
                onChanged: (v) => setState(() => _matchStart = v)),
            _ToggleRow(
                label: 'Live Score Updates',
                value: _liveScore,
                onChanged: (v) => setState(() => _liveScore = v)),
            _ToggleRow(
                label: 'Promotions & Bonuses',
                value: _promotions,
                onChanged: (v) => setState(() => _promotions = v)),
            const SizedBox(height: 28),
            _sectionLabel('Account'),
            const SizedBox(height: 12),
            _ToggleRow(
                label: 'Deposits',
                value: _deposits,
                onChanged: (v) => setState(() => _deposits = v)),
            _ToggleRow(
                label: 'Withdrawals',
                value: _withdrawals,
                onChanged: (v) => setState(() => _withdrawals = v)),
            _ToggleRow(
                label: 'Security Alerts',
                value: _security,
                onChanged: (v) => setState(() => _security = v)),
            _ToggleRow(
                label: 'Newsletter',
                value: _newsletter,
                onChanged: (v) => setState(() => _newsletter = v)),
            const SizedBox(height: 28),
            _sectionLabel('Recent'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF252B3D)),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _recent.length; i++) ...[
                    _NotifTile(item: _recent[i]),
                    if (i < _recent.length - 1)
                      const Divider(
                          color: Color(0xFF252B3D), height: 1, indent: 56),
                  ],
                ],
              ),
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

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

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
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: const Color(0xFFA0A4B8))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accentGreen,
            activeTrackColor: AppColors.accentGreen.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        tileColor: Colors.transparent,
        title: Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textWhite)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.accentGreen,
        activeTrackColor: AppColors.accentGreen.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item});
  final _NotifItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.body,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: const Color(0xFFA0A4B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(item.time,
              style: AppTextStyles.caption
                  .copyWith(color: const Color(0xFFA0A4B8))),
        ],
      ),
    );
  }
}

class _NotifItem {
  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
}

