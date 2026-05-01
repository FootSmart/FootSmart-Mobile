import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/theme/app_radius.dart';
import 'package:footsmart_pro/shared/widgets/app_button.dart';
import 'package:footsmart_pro/shared/widgets/app_card.dart';
import 'package:footsmart_pro/widgets/custom_text_field.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';
import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';

enum _AuthEntryMode {
  loading,
  form,
  quickAccess,
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthService _authService;

  bool _isLoading = false;
  bool _rememberMe = true;
  _AuthEntryMode _mode = _AuthEntryMode.loading;
  User? _rememberedUser;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService());
    _loadEntryState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadEntryState() async {
    final rememberMe = await _authService.getRememberMe();
    final hasStoredSession =
        rememberMe && await _authService.hasStoredSession();
    final savedUser = hasStoredSession ? await _authService.getUser() : null;

    if (!mounted) return;

    setState(() {
      _rememberMe = rememberMe;
      _rememberedUser = savedUser;
      _mode =
          savedUser != null ? _AuthEntryMode.quickAccess : _AuthEntryMode.form;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authResponse = await _authService.login(
        LoginRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
        rememberMe: _rememberMe,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${authResponse.user.displayName}!'),
          backgroundColor: context.accent,
        ),
      );

      _goToAuthenticatedArea(authResponse.user);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('401') ||
                    e.toString().contains('Unauthorized')
                ? 'Invalid email or password'
                : 'Login failed. Please try again.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleQuickAccess() async {
    setState(() => _isLoading = true);

    final isValid = await _authService.hasValidSession();
    final user = await _authService.getUser();

    if (!mounted) return;

    if (!isValid || user == null) {
      await _authService.clearSavedSession(clearRememberMe: true);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _rememberMe = false;
        _rememberedUser = null;
        _mode = _AuthEntryMode.form;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved session expired. Please sign in again.'),
        ),
      );
      return;
    }

    _goToAuthenticatedArea(user);
  }

  Future<void> _useAnotherAccount() async {
    await _authService.clearSavedSession(clearRememberMe: true);
    if (!mounted) return;

    _emailController.clear();
    _passwordController.clear();

    setState(() {
      _isLoading = false;
      _rememberMe = false;
      _rememberedUser = null;
      _mode = _AuthEntryMode.form;
    });
  }

  void _goToAuthenticatedArea(User user) {
    if (user.role == 'admin') {
      AppRoutes.replace(context, AppRoutes.adminDashboard);
      return;
    }

    if (user.role == 'coach') {
      AppRoutes.replace(context, AppRoutes.coachHome);
      return;
    }

    AppRoutes.replace(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: Stack(
          children: [
            const _PremiumBackdrop(),
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: switch (_mode) {
                  _AuthEntryMode.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  _AuthEntryMode.quickAccess => _buildQuickAccess(context),
                  _AuthEntryMode.form => _buildSignInForm(context),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('sign-in-form'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const _AuthBrandHeader(
            title: 'FootSmart Pro',
            subtitle: 'Your edge before kickoff',
          ),
          const SizedBox(height: 32),
          AppCard(
            elevated: true,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign in',
                    style: AppTextStyles.h1.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Access premium match intelligence and betting analytics.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'name@example.com',
                    prefixIcon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    showPasswordToggle: true,
                    validator: _validatePassword,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                      ),
                      Text(
                        'Remember me',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => AppRoutes.push(
                                  context,
                                  AppRoutes.forgotPassword,
                                ),
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: context.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    label: 'Login',
                    size: AppButtonSize.lg,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleSignIn,
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'New to FootSmart Pro? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () =>
                                  AppRoutes.push(context, AppRoutes.signUp),
                          child: Text(
                            'Create account',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: context.accent,
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
          SizedBox(height: 20),
          Center(
            child: Text(
              '18+ only. Please gamble responsibly.',
              style: AppTextStyles.caption.copyWith(
                color: context.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final user = _rememberedUser;

    return Center(
      key: const ValueKey('quick-access'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: AppCard(
            elevated: true,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _AuthBrandHeader(
                  title: 'FootSmart Pro',
                  subtitle: 'Welcome back',
                  centered: true,
                ),
                const SizedBox(height: 28),
                _UserAvatar(user: user),
                const SizedBox(height: 18),
                Text(
                  user?.displayName ?? 'FootSmart User',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: context.borderSubtle),
                  ),
                  child: Text(
                    'Quick access secured',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Continue',
                  size: AppButtonSize.lg,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleQuickAccess,
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Use another account',
                  variant: AppButtonVariant.ghost,
                  size: AppButtonSize.lg,
                  onPressed: _isLoading ? null : _useAnotherAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool centered;

  const _AuthBrandHeader({
    required this.title,
    required this.subtitle,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final alignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: context.accent,
                boxShadow: [
                  BoxShadow(
                    color: context.accent.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(28, 28),
                  painter: _BrandMarkPainter(),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                title,
                style: AppTextStyles.displayMedium.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final User? user;

  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.accent, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: context.accent.withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initials(context),
              )
            : _initials(context),
      ),
    );
  }

  Widget _initials(BuildContext context) {
    return Container(
      color: context.surfaceBg,
      alignment: Alignment.center,
      child: Text(
        user?.initials ?? 'FS',
        style: AppTextStyles.displayMedium.copyWith(
          color: context.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PremiumBackdrop extends StatelessWidget {
  const _PremiumBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -50,
            child: _glowCircle(
              size: 220,
              color: context.accent.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 110,
            left: -80,
            child: _glowCircle(
              size: 170,
              color: const Color(0xFF0F302B),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -30,
            child: _glowCircle(
              size: 260,
              color: context.accent.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            top: 120,
            right: 36,
            child: _dotCluster(context),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _dotCluster(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        12,
        (index) => Container(
          width: index.isEven ? 5 : 3,
          height: index.isEven ? 5 : 3,
          decoration: BoxDecoration(
            color: context.accent.withValues(
              alpha: index.isEven ? 0.45 : 0.22,
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final fill = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.44, stroke);
    canvas.drawCircle(center, size.width * 0.28, stroke);
    canvas.drawCircle(center, size.width * 0.12, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
