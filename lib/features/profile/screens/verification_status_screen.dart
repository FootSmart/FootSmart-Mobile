import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/models/user.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/auth_service.dart';
import 'package:footsmart_pro/core/services/profile_service.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  late final ProfileService _profileService;
  late final AuthService _authService;

  User? _user;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _profileService = ProfileService(api);
    _authService = AuthService(api);
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() => _isRefreshing = true);
    }

    try {
      await _authService.syncTokenToApi();
      final user = await _profileService.getCurrentUserFromDatabase();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
        _isRefreshing = false;
        _error = null;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _error = e.toString();
      });
    }
  }

  String _norm(String value) => value.trim().toLowerCase();

  bool _isApproved(String status) => _norm(status) == 'approved';

  bool _isPending(String status) {
    const pendingStates = {'pending', 'in_review', 'under_review'};
    return pendingStates.contains(_norm(status));
  }

  bool _isRejected(String status) {
    const rejectedStates = {'rejected', 'failed', 'declined'};
    return rejectedStates.contains(_norm(status));
  }

  bool _isActiveAccount(String status) => _norm(status) == 'active';

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? _ErrorState(
                  error: _error,
                  onRetry: () => _loadFromDatabase(),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadFromDatabase(silent: true),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (_error != null) ...[
                        _InlineWarning(error: _error!),
                        const SizedBox(height: 16),
                      ],
                      _StatusBanner(
                        kycStatus: _user!.kycStatus,
                        accountStatus: _user!.accountStatus,
                        isApproved: _isApproved(_user!.kycStatus),
                        isPending: _isPending(_user!.kycStatus),
                        isRejected: _isRejected(_user!.kycStatus),
                        isActiveAccount: _isActiveAccount(_user!.accountStatus),
                      ),
                      const SizedBox(height: 24),
                      _sectionLabel('Verification Progress'),
                      const SizedBox(height: 12),
                      ..._buildSteps(_user!),
                      const SizedBox(height: 24),
                      _sectionLabel('Live Account Snapshot'),
                      const SizedBox(height: 12),
                      _SnapshotCard(
                        user: _user!,
                        lastUpdated: _lastUpdated,
                        isRefreshing: _isRefreshing,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _isRefreshing
                            ? null
                            : () => _loadFromDatabase(silent: true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textWhite,
                          side: const BorderSide(color: Color(0xFF3D4256)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: _isRefreshing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textWhite,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Refresh From Database'),
                      ),
                    ],
                  ),
                ),
    );
  }

  List<Widget> _buildSteps(User user) {
    final kycApproved = _isApproved(user.kycStatus);
    final kycPending = _isPending(user.kycStatus);
    final kycRejected = _isRejected(user.kycStatus);
    final accountActive = _isActiveAccount(user.accountStatus);

    final profileReady = user.displayName.trim().isNotEmpty;

    final steps = <_StepData>[
      _StepData(
        icon: Icons.email_outlined,
        title: 'Email Address',
        subtitle: user.email,
        status:
            user.email.trim().isNotEmpty ? _StepStatus.done : _StepStatus.pending,
      ),
      _StepData(
        icon: Icons.person_outline_rounded,
        title: 'Profile Details',
        subtitle: profileReady
            ? 'Display name: ${user.displayName}'
            : 'Complete your profile information',
        status: profileReady ? _StepStatus.done : _StepStatus.pending,
      ),
      _StepData(
        icon: Icons.badge_outlined,
        title: 'Identity Verification (KYC)',
        subtitle: 'Current state: ${user.kycStatus.replaceAll('_', ' ')}',
        status: kycApproved
            ? _StepStatus.done
            : (kycRejected ? _StepStatus.failed : _StepStatus.pending),
      ),
      _StepData(
        icon: Icons.rule_folder_outlined,
        title: 'Compliance Review',
        subtitle: kycApproved
            ? 'Manual checks completed'
            : (kycPending
                ? 'Under review by compliance team'
                : (kycRejected
                    ? 'Please resubmit your identity documents'
                    : 'Waiting for document submission')),
        status: kycApproved
            ? _StepStatus.done
            : (kycRejected ? _StepStatus.failed : _StepStatus.pending),
      ),
      _StepData(
        icon: Icons.shield_outlined,
        title: 'Account Standing',
        subtitle: 'Account status: ${user.accountStatus}',
        status: accountActive ? _StepStatus.done : _StepStatus.failed,
      ),
    ];

    return steps
        .map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _VerificationStep(
              icon: step.icon,
              title: step.title,
              subtitle: step.subtitle,
              status: step.status,
            ),
          ),
        )
        .toList();
  }

  static Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
            color: const Color(0xFFA0A4B8),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(
              'Unable to load verification status',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: const Color(0xFFA0A4B8)),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: const Color(0xFF0B1220),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineWarning extends StatelessWidget {
  const _InlineWarning({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x33FF6B6B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x66FF6B6B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.kycStatus,
    required this.accountStatus,
    required this.isApproved,
    required this.isPending,
    required this.isRejected,
    required this.isActiveAccount,
  });

  final String kycStatus;
  final String accountStatus;
  final bool isApproved;
  final bool isPending;
  final bool isRejected;
  final bool isActiveAccount;

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFF3D4256);
    Color iconColor = const Color(0xFFA0A4B8);
    IconData icon = Icons.verified_user_outlined;
    String title = 'Verification Not Started';
    String subtitle =
        'Your verification state is read live from database: $kycStatus.';
    List<Color> gradient = const [Color(0xFF1E2434), Color(0xFF1A1F2E)];

    if (!isActiveAccount) {
      borderColor = AppColors.error;
      iconColor = AppColors.error;
      icon = Icons.block_rounded;
      title = 'Account Restricted';
      subtitle = 'Account status is $accountStatus. Contact support for help.';
      gradient = const [Color(0xFF3D1F26), Color(0xFF2B1A20)];
    } else if (isApproved) {
      borderColor = AppColors.accentGreen;
      iconColor = AppColors.accentGreen;
      icon = Icons.verified_rounded;
      title = 'Fully Verified';
      subtitle = 'KYC approved and account active.';
      gradient = const [Color(0xFF1A3A2A), Color(0xFF1A2E24)];
    } else if (isRejected) {
      borderColor = AppColors.error;
      iconColor = AppColors.error;
      icon = Icons.gpp_bad_rounded;
      title = 'Verification Failed';
      subtitle = 'KYC was rejected. Please submit updated documents.';
      gradient = const [Color(0xFF3D1F26), Color(0xFF2B1A20)];
    } else if (isPending) {
      borderColor = AppColors.accentOrange;
      iconColor = AppColors.accentOrange;
      icon = Icons.hourglass_top_rounded;
      title = 'Under Review';
      subtitle = 'Your documents are being reviewed by compliance.';
      gradient = const [Color(0xFF3A2A1A), Color(0xFF2E241A)];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: const Color(0xFFA0A4B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({
    required this.user,
    required this.lastUpdated,
    required this.isRefreshing,
  });

  final User user;
  final DateTime? lastUpdated;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    String updatedLabel = 'just now';
    if (lastUpdated != null) {
      final diff = DateTime.now().difference(lastUpdated!);
      if (diff.inSeconds < 60) {
        updatedLabel = '${diff.inSeconds}s ago';
      } else if (diff.inMinutes < 60) {
        updatedLabel = '${diff.inMinutes}m ago';
      } else {
        updatedLabel = '${diff.inHours}h ago';
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Column(
        children: [
          _SnapshotRow(label: 'KYC Status', value: user.kycStatus),
          const SizedBox(height: 8),
          _SnapshotRow(label: 'Account Status', value: user.accountStatus),
          const SizedBox(height: 8),
          _SnapshotRow(label: 'Role', value: user.role),
          const SizedBox(height: 8),
          _SnapshotRow(
            label: 'Wallet Balance',
            value: '\$${user.balance.toStringAsFixed(2)}',
          ),
          const Divider(color: Color(0xFF252B3D), height: 22),
          Row(
            children: [
              Icon(
                isRefreshing ? Icons.sync_rounded : Icons.cloud_done_rounded,
                color: const Color(0xFFA0A4B8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isRefreshing
                    ? 'Refreshing data...'
                    : 'Synced with database $updatedLabel',
                style: AppTextStyles.caption
                    .copyWith(color: const Color(0xFFA0A4B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              AppTextStyles.bodySmall.copyWith(color: const Color(0xFFA0A4B8)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepData {
  const _StepData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _StepStatus status;
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
    Color color = AppColors.accentOrange;
    IconData statusIcon = Icons.schedule_rounded;
    switch (status) {
      case _StepStatus.done:
        color = AppColors.accentGreen;
        statusIcon = Icons.check_circle_rounded;
        break;
      case _StepStatus.pending:
        color = AppColors.accentOrange;
        statusIcon = Icons.schedule_rounded;
        break;
      case _StepStatus.failed:
        color = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
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

