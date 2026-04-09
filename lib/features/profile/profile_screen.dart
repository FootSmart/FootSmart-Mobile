import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/models/user.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/profile_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileService _profileService;
  User? _user;
  UserStats? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(ApiService());
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = await _profileService.getCurrentUser();
      final stats = await _profileService.getUserStats();
      
      if (mounted) {
        setState(() {
          _user = user;
          _userStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  static const List<_ProfileSection> _menuSections = [
    _ProfileSection(
      title: 'Account',
      items: [
        _ProfileMenuItem(
          icon: Icons.person_outline_rounded,
          label: 'Personal Information',
          route: '/app/profile/info',
        ),
        _ProfileMenuItem(
          icon: Icons.verified_user_outlined,
          label: 'Verification Status',
          route: '/app/kyc',
          isVerified: true,
        ),
        _ProfileMenuItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          route: '/app/notifications',
        ),
        _ProfileMenuItem(
          icon: Icons.credit_card_outlined,
          label: 'Payment Methods',
          route: '/app/payment-methods',
        ),
      ],
    ),
    _ProfileSection(
      title: 'Betting',
      items: [
        _ProfileMenuItem(
          icon: Icons.description_outlined,
          label: 'Betting History',
          route: '/app/profile/history',
        ),
        _ProfileMenuItem(
          icon: Icons.shield_outlined,
          label: 'Responsible Gambling',
          route: '/app/responsible-gambling',
        ),
      ],
    ),
    _ProfileSection(
      title: 'Support',
      items: [
        _ProfileMenuItem(
          icon: Icons.help_outline_rounded,
          label: 'Help & Support',
          route: '/app/support',
        ),
        _ProfileMenuItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          route: '/app/settings',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF1A1F2E), Colors.transparent],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_user != null) ...[
                            _UserCard(user: _user!, stats: _userStats),
                            const SizedBox(height: 16),
                            _MemberSinceCard(user: _user!),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final section in _menuSections) ...[
                            Text(
                              section.title.toUpperCase(),
                              style: AppTextStyles.overline.copyWith(
                                color: const Color(0xFFA0A4B8),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ProfileSectionCard(
                              section: section,
                              onTapItem: (item) => _onMenuTap(context, item),
                            ),
                            const SizedBox(height: 24),
                          ],
                          _LogoutButton(
                            onPressed: () async {
                              await _profileService.clearCache();
                              if (!context.mounted) return;
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.signIn,
                                (route) => false,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Version 1.0.0 • FootSmart Pro',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFFA0A4B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, AppRoutes.home);
          } else if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.explore);
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.betting);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.wallet);
          }
        },
      ),
    );
  }

  void _onMenuTap(BuildContext context, _ProfileMenuItem item) {
    Navigator.of(context).pushNamed(item.route);
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final UserStats? stats;

  const _UserCard({
    required this.user,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF252B3D)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF252B3D), Color(0xFF1A1F2E)],
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accentGreen, Color(0xFF00CC6E)],
                  ),
                ),
                alignment: Alignment.center,
                child: ClipOval(
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                        ? Image.network(
                            user.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  user.initials,
                                  style: AppTextStyles.h3.copyWith(
                                    color: const Color(0xFF0B1220),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              user.initials,
                              style: AppTextStyles.h3.copyWith(
                                color: const Color(0xFF0B1220),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFFA0A4B8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusBadge(
                          label: user.kycStatus == 'approved'
                              ? 'Verified'
                              : 'Not Verified',
                          backgroundColor: user.kycStatus == 'approved'
                              ? const Color(0x3300FF88)
                              : const Color(0x33FF6B6B),
                          textColor: user.kycStatus == 'approved'
                              ? AppColors.accentGreen
                              : AppColors.error,
                          icon: user.kycStatus == 'approved'
                              ? Icons.check_circle
                              : Icons.pending_outlined,
                        ),
                        if (user.role == 'coach')
                          _StatusBadge(
                            label: 'Coach',
                            backgroundColor: const Color(0x33FF7A00),
                            textColor: AppColors.accentOrange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _StatsGrid(stats: stats),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserStats? stats;

  const _StatsGrid({this.stats});

  @override
  Widget build(BuildContext context) {
    final statsData = [
      _ProfileStat(
        label: 'Total Bets',
        value: '${stats?.totalBets ?? 0}',
      ),
      _ProfileStat(
        label: 'Win Rate',
        value: '${(stats?.winRate ?? 0).toStringAsFixed(1)}%',
      ),
      _ProfileStat(
        label: 'Total Won',
        value: '\$${(stats?.totalWon ?? 0).toStringAsFixed(2)}',
      ),
      _ProfileStat(
        label: 'ROI',
        value: '${stats?.roi != null ? (stats!.roi > 0 ? '+' : '') : '+'}${(stats?.roi ?? 0).toStringAsFixed(1)}%',
      ),
    ];

    return Row(
      children: statsData
          .map(
            (stat) => Expanded(
              child: Column(
                children: [
                  Text(
                    stat.value,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFA0A4B8),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MemberSinceCard extends StatelessWidget {
  final User user;

  const _MemberSinceCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Member Since',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFFA0A4B8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'January 2025', // TODO: Get from backend
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Status',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFFA0A4B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.accountStatus == 'active' ? 'Active' : 'Inactive',
                style: AppTextStyles.h3.copyWith(
                  color: user.accountStatus == 'active'
                      ? AppColors.accentGreen
                      : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.section, required this.onTapItem});

  final _ProfileSection section;
  final ValueChanged<_ProfileMenuItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < section.items.length; i++)
            _ProfileMenuTile(
              item: section.items[i],
              isLast: i == section.items.length - 1,
              onTap: () => onTapItem(section.items[i]),
            ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  final _ProfileMenuItem item;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFF252B3D)),
                ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF252B3D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 20, color: AppColors.accentGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (item.isVerified)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
              ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFA0A4B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF87171),
          side: const BorderSide(color: Color(0xFF252B3D)),
          backgroundColor: const Color(0xFF1A1F2E),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          'Log Out',
          style: AppTextStyles.buttonMedium.copyWith(
            color: const Color(0xFFF87171),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection {
  const _ProfileSection({required this.title, required this.items});

  final String title;
  final List<_ProfileMenuItem> items;
}

class _ProfileMenuItem {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isVerified = false,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool isVerified;
}

class _ProfileStat {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;
}
