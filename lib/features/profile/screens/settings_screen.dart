import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Appearance
  String _language = 'English';
  String _currency = 'USD (\$)';
  String _oddsFormat = 'Decimal';

  // Privacy & security
  bool _biometrics = true;
  bool _twoFactor = false;
  bool _showBalance = true;

  // Odds format options
  static const _oddsOptions = ['Decimal', 'Fractional', 'American'];
  static const _langOptions = ['English', 'Spanish', 'French', 'German', 'Portuguese'];
  static const _currencyOptions = ['USD (\$)', 'EUR (€)', 'GBP (£)', 'BTC'];

  void _showPicker(
      String title, List<String> options, String current,
      ValueChanged<String> onPick) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFF252B3D),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: AppTextStyles.h4
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...options.map((opt) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(opt, style: AppTextStyles.bodyMedium),
                    trailing: opt == current
                        ? const Icon(Icons.check_rounded,
                            color: AppColors.accentGreen)
                        : null,
                    onTap: () {
                      onPick(opt);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteAccount() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Account',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
        content: Text(
          'This will permanently delete your account and all data. This action cannot be undone.',
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
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Delete',
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
        title: Text('Settings',
            style: AppTextStyles.h4.copyWith(color: AppColors.textWhite)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Appearance'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _PickerRow(
                  icon: Icons.language_rounded,
                  label: 'Language',
                  value: _language,
                  onTap: () => _showPicker(
                      'Language', _langOptions, _language,
                      (v) => setState(() => _language = v)),
                ),
                _divider(),
                _PickerRow(
                  icon: Icons.attach_money_rounded,
                  label: 'Currency',
                  value: _currency,
                  onTap: () => _showPicker(
                      'Currency', _currencyOptions, _currency,
                      (v) => setState(() => _currency = v)),
                ),
                _divider(),
                _PickerRow(
                  icon: Icons.percent_rounded,
                  label: 'Odds Format',
                  value: _oddsFormat,
                  onTap: () => _showPicker(
                      'Odds Format', _oddsOptions, _oddsFormat,
                      (v) => setState(() => _oddsFormat = v)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionLabel('Privacy & Security'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _ToggleRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'Biometric Login',
                  value: _biometrics,
                  onChanged: (v) => setState(() => _biometrics = v),
                ),
                _divider(),
                _ToggleRow(
                  icon: Icons.security_rounded,
                  label: 'Two-Factor Authentication',
                  value: _twoFactor,
                  onChanged: (v) => setState(() => _twoFactor = v),
                ),
                _divider(),
                _ToggleRow(
                  icon: Icons.visibility_outlined,
                  label: 'Show Balance on Home',
                  value: _showBalance,
                  onChanged: (v) => setState(() => _showBalance = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionLabel('Account Actions'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _ActionRow(
                  icon: Icons.lock_reset_rounded,
                  label: 'Change Password',
                  onTap: () {},
                ),
                _divider(),
                _ActionRow(
                  icon: Icons.download_rounded,
                  label: 'Download My Data',
                  onTap: () {},
                ),
                _divider(),
                _ActionRow(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete Account',
                  color: const Color(0xFFF87171),
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionLabel('About'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _InfoRow(label: 'App Version', value: '1.0.0'),
                _divider(),
                _InfoRow(label: 'Build', value: '2026.02.23'),
                _divider(),
                _ActionRow(
                  icon: Icons.policy_outlined,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                _divider(),
                _ActionRow(
                  icon: Icons.article_outlined,
                  label: 'Terms & Conditions',
                  onTap: () {},
                ),
              ],
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

  static Widget _divider() =>
      const Divider(color: Color(0xFF252B3D), height: 1, indent: 48);
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textWhite)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentGreen,
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentGreen, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textWhite)),
            ),
            Text(value,
                style: AppTextStyles.bodySmall
                    .copyWith(color: const Color(0xFFA0A4B8))),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFA0A4B8), size: 20),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(color: color)),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withAlpha(120), size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textWhite)),
          ),
          Text(value,
              style: AppTextStyles.bodySmall
                  .copyWith(color: const Color(0xFFA0A4B8))),
        ],
      ),
    );
  }
}

