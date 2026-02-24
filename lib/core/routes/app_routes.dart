import 'package:flutter/material.dart';
import 'package:footsmart_pro/features/auth/screens/sign_in_screen.dart';
import 'package:footsmart_pro/features/auth/screens/sign_up_screen.dart';
import 'package:footsmart_pro/features/betting/betting_screen.dart';
import 'package:footsmart_pro/features/explore/explore_screen.dart';
import 'package:footsmart_pro/features/explore/competition_hub_screen.dart';
import 'package:footsmart_pro/features/explore/players_hub_screen.dart';
import 'package:footsmart_pro/features/home/home_screen.dart';
import 'package:footsmart_pro/features/onboarding/onboarding_screen.dart';
import 'package:footsmart_pro/features/profile/profile_screen.dart';
import 'package:footsmart_pro/features/profile/screens/personal_information_screen.dart';
import 'package:footsmart_pro/features/profile/screens/verification_status_screen.dart';
import 'package:footsmart_pro/features/profile/screens/notifications_screen.dart';
import 'package:footsmart_pro/features/profile/screens/payment_methods_screen.dart';
import 'package:footsmart_pro/features/profile/screens/betting_history_screen.dart';
import 'package:footsmart_pro/features/profile/screens/responsible_gambling_screen.dart';
import 'package:footsmart_pro/features/profile/screens/help_support_screen.dart';
import 'package:footsmart_pro/features/profile/screens/settings_screen.dart';
import 'package:footsmart_pro/features/splash/splash_screen.dart';
import 'package:footsmart_pro/features/wallet/wallet_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String competitionHub = '/competition-hub';
  static const String playersHub = '/players-hub';
  static const String betting = '/betting';
  static const String wallet = '/app/wallet';
  static const String profile = '/app/profile';

  // Profile sub-routes
  static const String personalInformation = '/app/profile/info';
  static const String verificationStatus = '/app/kyc';
  static const String notifications = '/app/notifications';
  static const String paymentMethods = '/app/payment-methods';
  static const String bettingHistory = '/app/profile/history';
  static const String responsibleGambling = '/app/responsible-gambling';
  static const String helpSupport = '/app/support';
  static const String settings = '/app/settings';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        signIn: (context) => const SignInScreen(),
        signUp: (context) => const SignUpScreen(),
        home: (context) => const HomeScreen(),
        explore: (context) => const ExploreScreen(),
        competitionHub: (context) => const CompetitionHubScreen(),
        playersHub: (context) => const PlayersHubScreen(),
        betting: (context) => const BettingScreen(),
        wallet: (context) => const WalletScreen(),
        profile: (context) => const ProfileScreen(),
        // Profile sub-screens
        personalInformation: (context) => const PersonalInformationScreen(),
        verificationStatus: (context) => const VerificationStatusScreen(),
        notifications: (context) => const NotificationsScreen(),
        paymentMethods: (context) => const PaymentMethodsScreen(),
        bettingHistory: (context) => const BettingHistoryScreen(),
        responsibleGambling: (context) => const ResponsibleGamblingScreen(),
        helpSupport: (context) => const HelpSupportScreen(),
        settings: (context) => const SettingsScreen(),
      };
}
