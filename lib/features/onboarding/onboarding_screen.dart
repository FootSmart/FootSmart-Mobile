import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_strings.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';

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
      iconWidget: const _AnalyticsIcon(),
      iconColor: AppColors.accentGreen,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      buttonText: 'Continue',
    ),
    OnboardingPage(
      iconWidget: const _SecurityIcon(),
      iconColor: AppColors.accentOrange,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      buttonText: 'Continue',
    ),
    OnboardingPage(
      iconWidget: const _HeartIcon(),
      iconColor: AppColors.accentGreen,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      buttonText: 'Get Started',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlay();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primaryDark,
        systemNavigationBarIconBrightness: Brightness.light,
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
      Navigator.pushReplacementNamed(context, AppRoutes.signUp);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, AppRoutes.signUp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
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
                        color: AppColors.textGrey,
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
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _pages[_currentPage].buttonText,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: AppColors.primaryDark,
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
              color: const Color(0xFF1A2332), // Darker circle
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: page.iconColor.withOpacity(0.15),
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
              color: AppColors.textGrey,
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
        color: isActive ? AppColors.accentGreen : AppColors.textGreyDark,
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

// Custom Analytics Icon (Bar Chart)
class _AnalyticsIcon extends StatelessWidget {
  const _AnalyticsIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(50, 50),
      painter: _AnalyticsIconPainter(),
    );
  }
}

class _AnalyticsIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Base line
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.85),
      Offset(size.width * 0.85, size.height * 0.85),
      paint,
    );

    // Vertical bars (3 bars with different heights)
    paint.style = PaintingStyle.fill;

    // Bar 1 (shortest)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.2,
          size.height * 0.65,
          size.width * 0.12,
          size.height * 0.2,
        ),
        const Radius.circular(3),
      ),
      paint,
    );

    // Bar 2 (tallest)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.44,
          size.height * 0.35,
          size.width * 0.12,
          size.height * 0.5,
        ),
        const Radius.circular(3),
      ),
      paint,
    );

    // Bar 3 (medium)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.68,
          size.height * 0.5,
          size.width * 0.12,
          size.height * 0.35,
        ),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Security Icon (Shield)
class _SecurityIcon extends StatelessWidget {
  const _SecurityIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(50, 50),
      painter: _SecurityIconPainter(),
    );
  }
}

class _SecurityIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Shield shape
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.2, size.height * 0.25);
    path.lineTo(size.width * 0.2, size.height * 0.55);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.75,
      size.width * 0.8,
      size.height * 0.55,
    );
    path.lineTo(size.width * 0.8, size.height * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Heart Icon (Responsible Gaming)
class _HeartIcon extends StatelessWidget {
  const _HeartIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(50, 50),
      painter: _HeartIconPainter(),
    );
  }
}

class _HeartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Heart shape
    path.moveTo(size.width * 0.5, size.height * 0.35);

    // Left curve
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.1,
      size.height * 0.3,
      size.width * 0.1,
      size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.1,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.85,
      size.width * 0.5,
      size.height * 0.85,
    );

    // Right curve
    path.cubicTo(
      size.width * 0.5,
      size.height * 0.85,
      size.width * 0.9,
      size.height * 0.7,
      size.width * 0.9,
      size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width * 0.7,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.35,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
