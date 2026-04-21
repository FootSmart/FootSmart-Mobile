import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:footsmart_pro/features/auth/screens/sign_in_screen.dart';
import 'package:footsmart_pro/features/auth/screens/sign_up_screen.dart';
import 'package:footsmart_pro/features/auth/screens/forgot_password_screen.dart';
import 'package:footsmart_pro/features/betting/betting_screen.dart';
import 'package:footsmart_pro/features/explore/explore_screen.dart';
import 'package:footsmart_pro/features/explore/competition_hub_screen.dart';
import 'package:footsmart_pro/features/explore/players_hub_screen.dart';
import 'package:footsmart_pro/features/explore/advanced_match_insights_screen.dart';
import 'package:footsmart_pro/features/explore/ai_prediction_center_screen.dart';
import 'package:footsmart_pro/features/explore/market_movements_screen.dart';
import 'package:footsmart_pro/features/explore/analytics_dashboard_screen.dart';
import 'package:footsmart_pro/features/explore/bet_history_analytics_screen.dart';
import 'package:footsmart_pro/features/explore/strategy_builder_screen.dart';
import 'package:footsmart_pro/features/home/home_screen.dart';
import 'package:footsmart_pro/features/match/match_detail_screen.dart';
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
  static const String profileInfo = '/app/profile/info';
  static const String kyc = '/app/kyc';
  static const String notifications = '/app/notifications';
  static const String paymentMethods = '/app/payment-methods';
  static const String bettingHistory = '/app/profile/history';
  static const String responsibleGambling = '/app/responsible-gambling';
  static const String support = '/app/support';
  static const String settings = '/app/settings';
  static const String matchDetail = '/match-detail';

  // Explore routes
  static const String advancedMatchInsights = '/explore/match-insights';
  static const String aiPredictionCenter = '/explore/ai-predictions';
  static const String marketMovements = '/explore/market-movements';
  static const String analyticsDashboard = '/explore/analytics-dashboard';
  static const String betHistoryAnalytics = '/explore/bet-history-analytics';
  static const String strategyBuilder = '/explore/strategy-builder';

  // Coach routes
  static const String coachHome = '/coach-home';
  static const String coachTactics = '/coach-tactics';
  static const String coachOpponent = '/coach-opponent';
  static const String coachWhatIf = '/coach-what-if';
  static const String coachPerfectPlayer = '/coach-perfect-player';
  static const String coachLiveConsole = '/coach-live-console';
  static const String coachBroadcast = '/coach-broadcast';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: <RouteBase>[
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: signIn, builder: (context, state) => const SignInScreen()),
      GoRoute(path: signUp, builder: (context, state) => const SignUpScreen()),
      GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: explore, builder: (context, state) => const ExploreScreen()),
      GoRoute(
          path: competitionHub,
          builder: (context, state) => const CompetitionHubScreen()),
      GoRoute(
          path: playersHub,
          builder: (context, state) => const PlayersHubScreen()),
      GoRoute(path: betting, builder: (context, state) => const BettingScreen()),
      GoRoute(path: wallet, builder: (context, state) => const WalletScreen()),
      GoRoute(path: profile, builder: (context, state) => const ProfileScreen()),
      GoRoute(
          path: profileInfo,
          builder: (context, state) => const PersonalInformationScreen()),
      GoRoute(
          path: kyc,
          builder: (context, state) => const VerificationStatusScreen()),
      GoRoute(
          path: notifications,
          builder: (context, state) => const NotificationsScreen()),
      GoRoute(
          path: paymentMethods,
          builder: (context, state) => const PaymentMethodsScreen()),
      GoRoute(
          path: bettingHistory,
          builder: (context, state) => const BettingHistoryScreen()),
      GoRoute(
        path: responsibleGambling,
        builder: (context, state) => const ResponsibleGamblingScreen(),
      ),
      GoRoute(path: support, builder: (context, state) => const HelpSupportScreen()),
      GoRoute(path: settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: matchDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is FootballMatch) {
            return MatchDetailScreen(match: extra);
          }
          return const HomeScreen();
        },
      ),

      // Explore routes
      GoRoute(
        path: advancedMatchInsights,
        builder: (context, state) => const AdvancedMatchInsightsScreen(),
      ),
      GoRoute(
        path: aiPredictionCenter,
        builder: (context, state) => const AIPredictionCenterScreen(),
      ),
      GoRoute(
        path: marketMovements,
        builder: (context, state) => const MarketMovementsScreen(),
      ),
      GoRoute(
        path: analyticsDashboard,
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: betHistoryAnalytics,
        builder: (context, state) => const BetHistoryAnalyticsScreen(),
      ),
      GoRoute(
        path: strategyBuilder,
        builder: (context, state) => const StrategyBuilderScreen(),
      ),

      // Coach routes
      GoRoute(path: coachHome, builder: (context, state) => const CoachHomeScreen()),
      GoRoute(
          path: coachTactics,
          builder: (context, state) => const CoachTacticsScreen()),
      GoRoute(
          path: coachOpponent,
          builder: (context, state) => const CoachOpponentScreen()),
      GoRoute(
          path: coachWhatIf,
          builder: (context, state) => const CoachWhatIfScreen()),
      GoRoute(
        path: coachPerfectPlayer,
        builder: (context, state) => const CoachPerfectPlayerScreen(),
      ),
      GoRoute(
        path: coachLiveConsole,
        builder: (context, state) => const CoachLiveConsoleScreen(),
      ),
      GoRoute(
        path: coachBroadcast,
        builder: (context, state) => const CoachBroadcastScreen(),
      ),
    ],
  );

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
        profileInfo: (context) => const PersonalInformationScreen(),
        kyc: (context) => const VerificationStatusScreen(),
        notifications: (context) => const NotificationsScreen(),
        paymentMethods: (context) => const PaymentMethodsScreen(),
        bettingHistory: (context) => const BettingHistoryScreen(),
        responsibleGambling: (context) => const ResponsibleGamblingScreen(),
        support: (context) => const HelpSupportScreen(),
        settings: (context) => const SettingsScreen(),
        matchDetail: (context) {
          final match =
              ModalRoute.of(context)!.settings.arguments as FootballMatch;
          return MatchDetailScreen(match: match);
        },

        // Explore routes
        advancedMatchInsights: (context) =>
            const AdvancedMatchInsightsScreen(),
        aiPredictionCenter: (context) => const AIPredictionCenterScreen(),
        marketMovements: (context) => const MarketMovementsScreen(),
        analyticsDashboard: (context) => const AnalyticsDashboardScreen(),
        betHistoryAnalytics: (context) => const BetHistoryAnalyticsScreen(),
        strategyBuilder: (context) => const StrategyBuilderScreen(),

        // Coach routes
        coachHome: (context) => const CoachHomeScreen(),
        coachTactics: (context) => const CoachTacticsScreen(),
        coachOpponent: (context) => const CoachOpponentScreen(),
        coachWhatIf: (context) => const CoachWhatIfScreen(),
        coachPerfectPlayer: (context) => const CoachPerfectPlayerScreen(),
        coachLiveConsole: (context) => const CoachLiveConsoleScreen(),
        coachBroadcast: (context) => const CoachBroadcastScreen(),
      };

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    return context.push<T>(route, extra: extra);
  }

  static void replace(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    context.pushReplacement(route, extra: extra);
  }

  static void go(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    context.go(route, extra: extra);
  }

  static void clearAndGo(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    context.go(route, extra: extra);
  }

  static bool canPop(BuildContext context) {
    return GoRouter.of(context).canPop();
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    context.pop(result);
  }
}
