import 'package:flutter/material.dart';
import 'package:footsmart_pro/features/auth/screens/sign_in_screen.dart';
import 'package:footsmart_pro/features/auth/screens/sign_up_screen.dart';
import 'package:footsmart_pro/features/home/home_screen.dart';
import 'package:footsmart_pro/features/onboarding/onboarding_screen.dart';
import 'package:footsmart_pro/features/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    home: (context) => const HomeScreen(),
  };
}
