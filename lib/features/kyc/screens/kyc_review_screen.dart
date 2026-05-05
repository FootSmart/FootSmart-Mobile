import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/auth_service.dart';
import 'package:footsmart_pro/core/services/kyc_service.dart';

class KycReviewScreen extends StatefulWidget {
  const KycReviewScreen({super.key});

  @override
  State<KycReviewScreen> createState() => _KycReviewScreenState();
}

class _KycReviewScreenState extends State<KycReviewScreen> {
  late final KycService _kycService;
  late final AuthService _authService;

  bool _isLoading = true;
  String? _status;
  String? _error;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _kycService = KycService(api);
    _authService = AuthService(api);
    _refreshStatus();
  }

  String _normalized(String? value) => (value ?? '').trim().toLowerCase();

  bool get _isApproved => _normalized(_status) == 'approved';
  bool get _isRejected => _normalized(_status) == 'rejected';
  bool get _isManualReview => _normalized(_status) == 'manual_review';

  Future<void> _refreshStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.syncTokenToApi();
      final status = await _kycService.getStatus();
      if (!mounted) return;

      setState(() {
        _status = status.kycStatus;
        _isLoading = false;
      });

      if (_isApproved) {
        AppRoutes.replace(context, AppRoutes.kycSuccess);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
          onPressed: () => AppRoutes.replace(context, AppRoutes.home),
        ),
        title: Text('Verification review',
            style: AppTextStyles.h4.copyWith(color: AppColors.textWhite)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accentGreen),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your verification is being reviewed.',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your account will activate automatically after approval.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFFA0A4B8),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_error != null)
                      Text(
                        _error!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error),
                      ),
                    if (_isRejected) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B1A20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF6B2E3A)),
                        ),
                        child: Text(
                          'Verification was rejected. Please retry with updated documents.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: const Color(0xFFE3C7CE)),
                        ),
                      ),
                    ] else if (_isManualReview) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1F2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF252B3D)),
                        ),
                        child: Text(
                          'Your verification is under manual review. We will notify you when it is complete.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: const Color(0xFFA0A4B8)),
                        ),
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _refreshStatus,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textWhite,
                          side: const BorderSide(color: Color(0xFF3D4256)),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Refresh status'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRejected
                            ? () => AppRoutes.replace(context, AppRoutes.kyc)
                            : () => AppRoutes.replace(context, AppRoutes.home),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: const Color(0xFF0B1220),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(_isRejected ? 'Retry verification' : 'Back to home'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
