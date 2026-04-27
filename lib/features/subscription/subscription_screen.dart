import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/models/user.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/profile_service.dart';
import 'package:footsmart_pro/core/services/premium_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late final ProfileService _profileService;
  late final PremiumService _premiumService;

  User? _user;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(ApiService());
    _premiumService = PremiumService();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _profileService.getCurrentUser();

    if (!mounted) return;

    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _subscribe() async {
    setState(() => _isPurchasing = true);

    try {
      final userId = _user?.id;

      if (userId == null) {
        throw Exception('User not loaded yet.');
      }

      final offerings = await _premiumService.getOfferings(userId: userId);
      final package = offerings.current?.monthly ?? offerings.current?.annual;

      if (package == null) {
        throw Exception('No subscription packages available yet.');
      }

      final info = await _premiumService.purchasePackage(
        userId: userId,
        package: package,
      );

      final hasAccess = info.entitlements.active.isNotEmpty;

      if (hasAccess) {
        await Future.delayed(const Duration(seconds: 2));
        await _loadUser();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription unavailable: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);

    try {
      final userId = _user?.id;

      if (userId == null) {
        throw Exception('User not loaded yet.');
      }

      await _premiumService.restorePurchases(userId: userId);
      await Future.delayed(const Duration(seconds: 2));
      await _loadUser();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases restored.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _cancelSubscription() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Subscriptions are managed from Google Play. Open Play Store > Payments & subscriptions > Subscriptions.',
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Not available';

    final date = value.toLocal();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final isSubscribed = user?.hasPremiumAccess ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: Text(
          'Subscription',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadUser,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF252B3D)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF252B3D), Color(0xFF1A1F2E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isSubscribed
                        ? Icons.workspace_premium_rounded
                        : Icons.lock_outline_rounded,
                    color: isSubscribed
                        ? AppColors.accentGreen
                        : const Color(0xFFA0A4B8),
                    size: 42,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSubscribed ? 'Premium Active' : 'Premium Locked',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSubscribed
                        ? 'Your premium access is active.'
                        : 'Subscribe to unlock premium tools.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFFA0A4B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Status',
                  value: isSubscribed ? 'Active' : 'Not subscribed',
                  valueColor: isSubscribed
                      ? AppColors.accentGreen
                      : const Color(0xFFA0A4B8),
                ),
                _InfoRow(
                  label: 'Plan',
                  value: user?.subscriptionPlan ?? 'None',
                ),
                _InfoRow(
                  label: 'Ends on',
                  value: _formatDate(user?.subscriptionEndsAt),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isSubscribed)
              ElevatedButton.icon(
                onPressed: _isPurchasing ? null : _subscribe,
                icon: const Icon(Icons.workspace_premium_outlined),
                label: Text(_isPurchasing ? 'Loading...' : 'Subscribe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: const Color(0xFF0B1220),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _isPurchasing ? null : _cancelSubscription,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Manage / Cancel Subscription'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF87171),
                  side: const BorderSide(color: Color(0xFF252B3D)),
                  backgroundColor: const Color(0xFF1A1F2E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isPurchasing ? null : _restore,
              child: const Text('Restore purchases'),
            ),
            const SizedBox(height: 12),
            Text(
              'Cancellation is handled through Google Play subscriptions.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFFA0A4B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF252B3D)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFFA0A4B8),
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? AppColors.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}