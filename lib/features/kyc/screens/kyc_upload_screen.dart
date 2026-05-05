import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/auth_service.dart';
import 'package:footsmart_pro/core/services/kyc_service.dart';
import 'package:footsmart_pro/widgets/stripe_hosted_setup_page.dart';

class KycUploadScreen extends StatefulWidget {
  const KycUploadScreen({super.key});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends State<KycUploadScreen> {
  static const MethodChannel _permissionChannel =
      MethodChannel('footsmart/native_permissions');

  late final KycService _kycService;
  late final AuthService _authService;

  bool _isStarting = false;
  bool _isSkipping = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _kycService = KycService(api);
    _authService = AuthService(api);
  }

  Future<bool> _ensureCameraPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final status = await _permissionChannel.invokeMethod<String>(
      'requestCameraPermission',
    );

    switch (status) {
      case 'granted':
        return true;
      case 'permanently_denied':
        throw Exception(
          'Camera permission is blocked. Enable it in Android settings to take your selfie and government ID photos.',
        );
      case 'denied':
      default:
        throw Exception(
          'Camera permission is required to take your selfie and government ID photos for KYC verification.',
        );
    }
  }

  Future<void> _startKyc() async {
    if (_isStarting) return;

    setState(() {
      _isStarting = true;
      _error = null;
    });

    try {
      await _ensureCameraPermission();
      await _authService.syncTokenToApi();
      final response = await _kycService.startKyc();
      final url = response.url;

      if (url == null || url.isEmpty) {
        throw Exception('Stripe Identity URL not available');
      }

      if (!mounted) return;

      await Navigator.of(context).push<String?>(
        MaterialPageRoute<String?>(
          fullscreenDialog: true,
          builder: (_) => StripeHostedSetupPage(
            initialUrl: url,
            returnUrlContains: 'footsmart-kyc-return',
            appBarTitle: 'Identity verification',
          ),
        ),
      );

      if (!mounted) return;
      AppRoutes.replace(context, AppRoutes.kycReview);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  Future<void> _skipKyc() async {
    if (_isSkipping) return;
    setState(() {
      _isSkipping = true;
      _error = null;
    });

    try {
      await _authService.syncTokenToApi();
      await _kycService.skipKyc();
      if (!mounted) return;
      AppRoutes.replace(context, AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSkipping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        elevation: 0,
        title: Text(
          'Verify your identity',
          style: AppTextStyles.h4.copyWith(color: AppColors.textWhite),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify your identity',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'To activate your FootSmart account, please complete identity verification.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFFA0A4B8),
                ),
              ),
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
                  'You can skip for now, but your account will stay inactive. '
                  'You will not be able to place bets, use wallet features, withdraw funds, '
                  'or access protected features until KYC is approved.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFFE3C7CE),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isStarting ? null : _startKyc,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: const Color(0xFF0B1220),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isStarting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0B1220),
                          ),
                        )
                      : const Text('Start verification'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSkipping ? null : _skipKyc,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textWhite,
                    side: const BorderSide(color: Color(0xFF3D4256)),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSkipping
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textWhite,
                          ),
                        )
                      : const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
