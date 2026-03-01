import 'package:flutter/material.dart';
import 'package:footsmart_pro/features/auth/screens/sign_in_screen.dart';
import 'package:footsmart_pro/features/auth/screens/sign_up_screen.dart';
import 'package:footsmart_pro/features/auth/screens/forgot_password_screen.dart';
import 'package:footsmart_pro/features/betting/betting_screen.dart';
import 'package:footsmart_pro/features/explore/explore_screen.dart';
import 'package:footsmart_pro/features/explore/competition_hub_screen.dart';
import 'package:footsmart_pro/features/explore/players_hub_screen.dart';
import 'package:footsmart_pro/features/home/home_screen.dart';
import 'package:footsmart_pro/features/match/match_detail_screen.dart';
import 'package:footsmart_pro/features/onboarding/onboarding_screen.dart';
import 'package:footsmart_pro/features/profile/profile_screen.dart';
import 'package:footsmart_pro/features/splash/splash_screen.dart';
import 'package:footsmart_pro/features/wallet/wallet_screen.dart';
import 'package:footsmart_pro/core/models/match.dart';

// Coach screens
import 'package:footsmart_pro/features/coach/screens/coach_home_screen.dart';
import 'package:footsmart_pro/features/coach/screens/coach_tactics_screen.dart';
import 'package:footsmart_pro/features/coach/screens/coach_opponent_screen.dart';
import 'package:footsmart_pro/features/coach/screens/coach_what_if_screen.dart';
import 'package:footsmart_pro/features/coach/screens/coach_perfect_player_screen.dart';
import 'package:footsmart_pro/features/coach/screens/coach_live_console_screen.dart';
import 'package:footsmart_pro/features/coach/screens/coach_broadcast_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String competitionHub = '/competition-hub';
  static const String playersHub = '/players-hub';
  static const String betting = '/betting';
  static const String wallet = '/app/wallet';
  static const String profile = '/app/profile';
  static const String matchDetail = '/match-detail';

  // Coach routes
  static const String coachHome = '/coach-home';
  static const String coachTactics = '/coach-tactics';
  static const String coachOpponent = '/coach-opponent';
  static const String coachWhatIf = '/coach-what-if';
  static const String coachPerfectPlayer = '/coach-perfect-player';
  static const String coachLiveConsole = '/coach-live-console';
  static const String coachBroadcast = '/coach-broadcast';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        signIn: (context) => const SignInScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        signUp: (context) => const SignUpScreen(),
        home: (context) => const HomeScreen(),
        explore: (context) => const ExploreScreen(),
        competitionHub: (context) => const CompetitionHubScreen(),
        playersHub: (context) => const PlayersHubScreen(),
        betting: (context) => const BettingScreen(),
        wallet: (context) => const WalletScreen(),
        profile: (context) => const ProfileScreen(),
        matchDetail: (context) {
          final match =
              ModalRoute.of(context)!.settings.arguments as FootballMatch;
          return MatchDetailScreen(match: match);
        },

        // Coach routes
        coachHome: (context) => const CoachHomeScreen(),
        coachTactics: (context) => const CoachTacticsScreen(),
        coachOpponent: (context) => const CoachOpponentScreen(),
        coachWhatIf: (context) => const CoachWhatIfScreen(),
        coachPerfectPlayer: (context) => const CoachPerfectPlayerScreen(),
        coachLiveConsole: (context) => const CoachLiveConsoleScreen(),
        coachBroadcast: (context) => const CoachBroadcastScreen(),
      };
}
