import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final AuthService _authService;

  bool _isLoading = false;
  bool _emailSent = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await _authService.forgotPassword(_emailController.text.trim());

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _emailSent = true;
        });
        _startCountdown();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Reset link sent to your email'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to send reset email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _countdown == 0;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.accent.withValues(alpha: 0.08),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon:
                              Icon(Icons.arrow_back, color: context.iconColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppCard(
                        elevated: true,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.accent.withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.lock_reset,
                                size: 56,
                                color: context.accent,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Reset your password',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _emailSent
                                  ? 'We sent a password reset link to your email. Please check your inbox.'
                                  : 'Enter your email address and we will send you a secure reset link.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: context.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email address',
                              hint: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                              enabled: !_isLoading && canResend,
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: _emailSent && !canResend
                                  ? 'Resend in ${_countdown}s'
                                  : _emailSent
                                      ? 'Resend reset link'
                                      : 'Send reset link',
                              onPressed: canResend && !_isLoading
                                  ? _sendResetEmail
                                  : null,
                              isLoading: _isLoading,
                            ),
                            if (_emailSent && canResend) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Did not receive the email? Check your spam folder or try again.',
                                style: AppTextStyles.caption.copyWith(
                                  color: context.textTertiary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Remember your password? ',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: context.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Sign In',
                                      style: TextStyle(
                                        color: context.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}
