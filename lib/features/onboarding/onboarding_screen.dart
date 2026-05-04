import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_strings.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      iconWidget: const _FootballAnalyticsIcon(),
      iconColor: AppColors.accentGreen,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      buttonText: 'Continue',
    ),
    OnboardingPage(
      iconWidget: const _BettingIcon(),
      iconColor: AppColors.accentOrange,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      buttonText: 'Continue',
    ),
    OnboardingPage(
      iconWidget: const _AgeRestrictionIcon(),
      iconColor: AppColors.error,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      buttonText: 'I\'m 18+ — Get Started',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemUIOverlay();
  }

  void _setSystemUIOverlay() {
    final brightness = context.isDark ? Brightness.light : Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        systemNavigationBarColor: context.scaffoldBg,
        systemNavigationBarIconBrightness: brightness,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skip() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    AppRoutes.replace(context, AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: context.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24, top: 16),
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      AppStrings.skip,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),
              ),

              // Continue/Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor:
                          context.isDark ? AppColors.primaryDark : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _pages[_currentPage].buttonText,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: context.isDark
                            ? AppColors.primaryDark
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Icon with dark circle background
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: context.surfaceBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: page.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: page.iconWidget,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Title
          Text(
            page.title,
            style: AppTextStyles.h1.copyWith(
              color: context.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: context.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? context.accent : context.iconInactive,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final Widget iconWidget;
  final Color iconColor;
  final String title;
  final String description;
  final String buttonText;

  OnboardingPage({
    required this.iconWidget,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}

// Custom Football Analytics Icon (Soccer ball + chart)
class _FootballAnalyticsIcon extends StatelessWidget {
  const _FootballAnalyticsIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(50, 50),
      painter: _FootballAnalyticsIconPainter(),
    );
  }
}

class _FootballAnalyticsIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Soccer ball circle
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.55),
      size.width * 0.25,
      paint,
    );

    // Pentagon on ball
    final pentPath = Path();
    final cx = size.width * 0.35;
    final cy = size.height * 0.55;
    final r = size.width * 0.12;
    for (int i = 0; i < 5; i++) {
      final angle = -1.5708 + (i * 6.2832 / 5);
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        pentPath.moveTo(x, y);
      } else {
        pentPath.lineTo(x, y);
      }
    }
    pentPath.close();
    paint.strokeWidth = 1.5;
    canvas.drawPath(pentPath, paint);

    // Trend arrow going up
    paint.strokeWidth = 3;
    final arrowPath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width * 0.85, size.height * 0.25);
    canvas.drawPath(arrowPath, paint);

    // Arrow head
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.35),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Betting Icon (Ticket / Odds)
class _BettingIcon extends StatelessWidget {
  const _BettingIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(50, 50),
      painter: _BettingIconPainter(),
    );
  }
}

class _BettingIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Betting ticket shape
    final ticketPath = Path();
    ticketPath.moveTo(size.width * 0.15, size.height * 0.15);
    ticketPath.lineTo(size.width * 0.85, size.height * 0.15);
    ticketPath.lineTo(size.width * 0.85, size.height * 0.85);
    ticketPath.lineTo(size.width * 0.15, size.height * 0.85);
    ticketPath.close();
    canvas.drawPath(ticketPath, paint);

    // Dashed line in middle
    for (double i = 0.25; i < 0.85; i += 0.1) {
      canvas.drawLine(
        Offset(size.width * i, size.height * 0.5),
        Offset(size.width * (i + 0.05), size.height * 0.5),
        paint..strokeWidth = 2,
      );
    }
    paint.strokeWidth = 3;

    // Odds text lines
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.32),
      Offset(size.width * 0.55, size.height * 0.32),
      paint..strokeWidth = 2.5,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.68),
      Offset(size.width * 0.55, size.height * 0.68),
      paint,
    );

    // Checkmark on right
    paint.strokeWidth = 3;
    paint.color = AppColors.accentOrange;
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.65),
      Offset(size.width * 0.68, size.height * 0.73),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.68, size.height * 0.73),
      Offset(size.width * 0.78, size.height * 0.58),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom 18+ Age Restriction Icon
class _AgeRestrictionIcon extends StatelessWidget {
  const _AgeRestrictionIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(50, 50),
      painter: _AgeRestrictionIconPainter(),
    );
  }
}

class _AgeRestrictionIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Outer circle
    final circlePaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.42,
      circlePaint,
    );

    // "18+" text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '18+',
        style: TextStyle(
          color: AppColors.error,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
