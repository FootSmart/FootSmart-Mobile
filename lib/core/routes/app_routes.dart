import 'package:flutter/material.dart';
import 'package:footsmart_pro/features/auth/screens/sign_in_screen.dart';
import 'package:footsmart_pro/features/auth/screens/sign_up_screen.dart';
import 'package:footsmart_pro/features/betting/betting_screen.dart';
import 'package:footsmart_pro/features/explore/explore_screen.dart';
import 'package:footsmart_pro/features/home/home_screen.dart';
import 'package:footsmart_pro/features/onboarding/onboarding_screen.dart';
import 'package:footsmart_pro/features/splash/splash_screen.dart';
import 'package:footsmart_pro/features/profile/profile_screen.dart';
import 'package:footsmart_pro/features/wallet/wallet_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String wallet = '/wallet';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    wallet: (context) => const WalletScreen(),
  };
  static const String explore = '/explore';
  static const String betting = '/betting';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        signIn: (context) => const SignInScreen(),
        signUp: (context) => const SignUpScreen(),
        home: (context) => const HomeScreen(),
        explore: (context) => const ExploreScreen(),
        betting: (context) => const BettingScreen(),
      };
}
