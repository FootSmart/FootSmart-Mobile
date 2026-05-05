import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

enum _ResetViewState { verifying, invalid, form, success }

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  late final AuthService _authService;

  _ResetViewState _state = _ResetViewState.verifying;
  String? _maskedEmail;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService());
    _verifyToken();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _verifyToken() async {
    setState(() => _state = _ResetViewState.verifying);
    final status = await _authService.verifyResetToken(widget.token);

    if (!mounted) return;

    setState(() {
      _maskedEmail = status.email;
      _state = status.valid ? _ResetViewState.form : _ResetViewState.invalid;
    });
  }

  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await _authService.resetPassword(
      token: widget.token,
      newPassword: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      setState(() => _state = _ResetViewState.success);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to reset password. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: context.iconColor),
                    onPressed: () => AppRoutes.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  elevated: true,
                  padding: const EdgeInsets.all(24),
                  child: _buildContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return switch (_state) {
      _ResetViewState.verifying => _buildVerifying(context),
      _ResetViewState.invalid => _buildInvalid(context),
      _ResetViewState.form => _buildForm(context),
      _ResetViewState.success => _buildSuccess(context),
    };
  }

  Widget _buildVerifying(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.lock_reset, size: 56, color: context.accent),
        const SizedBox(height: 20),
        Text(
          'Checking your reset link...',
          style: AppTextStyles.h2.copyWith(color: context.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Please wait a moment while we verify your token.',
          style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildInvalid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.error_outline, size: 56, color: context.accentOrange),
        const SizedBox(height: 20),
        Text(
          'This reset link is invalid or expired.',
          style: AppTextStyles.h2.copyWith(color: context.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Request a new password reset link to continue.',
          style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        CustomButton(
          text: 'Request new link',
          onPressed: () => AppRoutes.replace(context, AppRoutes.forgotPassword),
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Back to sign in',
          variant: ButtonVariant.outlined,
          onPressed: () => AppRoutes.replace(context, AppRoutes.signIn),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_reset, size: 56, color: context.accent),
          const SizedBox(height: 20),
          Text(
            'Create a new password',
            style: AppTextStyles.h2.copyWith(color: context.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _maskedEmail == null
                ? 'Enter a new password for your account.'
                : 'Resetting password for $_maskedEmail',
            style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _passwordController,
            label: 'New password',
            hint: 'Enter new password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            showPasswordToggle: true,
            validator: Validators.validatePassword,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmController,
            label: 'Confirm password',
            hint: 'Re-enter new password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            showPasswordToggle: true,
            validator: (value) => Validators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          Text(
            'Password must include uppercase, lowercase, number, and special character.',
            style: AppTextStyles.caption.copyWith(color: context.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Reset password',
            onPressed: _isSubmitting ? null : _submitReset,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () => AppRoutes.replace(context, AppRoutes.signIn),
            child: Text(
              'Back to sign in',
              style: AppTextStyles.bodyMedium.copyWith(color: context.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle_outline, size: 56, color: context.accent),
        const SizedBox(height: 20),
        Text(
          'Password reset successfully.',
          style: AppTextStyles.h2.copyWith(color: context.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Please login with your new password.',
          style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        CustomButton(
          text: 'Go to sign in',
          onPressed: () => AppRoutes.replace(context, AppRoutes.signIn),
        ),
      ],
    );
  }
}
