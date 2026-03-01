import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/constants/app_strings.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import '../../core/extensions/theme_context.dart';

/// Splash Screen - First screen user sees when opening the app
///
/// Features:
/// - Animated logo reveal
/// - App tagline
/// - Progress indicator
/// - Auto-navigation after 5 seconds
///
/// Design:
/// - Theme-aware background gradient
/// - Centered green logo with concentric circles
/// - "FootSmart Pro" title with green "Pro" text
/// - Tagline below
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemUIOverlay();
  }

  /// Configure status bar and navigation bar colors (theme-aware)
  void _setSystemUIOverlay() {
    final isDark = context.isDark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? context.scaffoldBg : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  /// Setup animations for logo reveal
  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  /// Navigate to next screen after delay
  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Animated Logo
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: const _LogoWidget(),
                ),

                const SizedBox(height: 32),

                // App Title with Animation
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(opacity: _fadeAnimation.value, child: child);
                  },
                  child: _buildAppTitle(),
                ),

                const SizedBox(height: 12),

                // Tagline with Animation
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(opacity: _fadeAnimation.value, child: child);
                  },
                  child: Text(
                    AppStrings.appTagline,
                    style: AppTextStyles.tagline.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(flex: 2),

                // Progress Indicator
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: context.borderColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.accent,
                            ),
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build app title with "Pro" in accent color
  Widget _buildAppTitle() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'FootSmart ',
            style: AppTextStyles.displayMedium.copyWith(
              color: context.textPrimary,
            ),
          ),
          TextSpan(
            text: 'Pro',
            style: AppTextStyles.displayMedium.copyWith(
              color: context.accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Logo Widget using the app logo asset
class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.accent.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logorb.png',
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
