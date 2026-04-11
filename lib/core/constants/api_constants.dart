/// API configuration constants for FootSmart backend
class ApiConstants {
  ApiConstants._();

  // Base URL - For Android emulator use 10.0.2.2, for iOS simulator use localhost
  // For physical device, use your computer's actual IP address
  static const String baseUrl = 'http://10.0.2.2:3008/api';

  // API Version
  static const String apiVersion = 'v1';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ─── Endpoints ───────────────────────────────────────────────────────────

  // Auth
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String profile = '/users/me';
  static const String updateProfile = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyResetToken = '/auth/verify-reset-token';

  // ─── Leagues ─────────────────────────────────────────────────────────────
  static const String leagues = '/leagues';
  static String leagueById(String id) => '/leagues/$id';
  static String leagueStandings(String id) => '/leagues/$id/standings';
  static String leagueMatches(String id) => '/leagues/$id/matches';
  static const String leagueStatsOverview = '/leagues/stats/overview';

  // ─── Teams ───────────────────────────────────────────────────────────────
  static const String teams = '/teams';
  static String teamDetails(String id) => '/teams/$id';
  static String teamFull(String id) => '/teams/$id/full';
  static String teamPlayers(String id) => '/teams/$id/players';
  static String teamStats(String id) => '/teams/$id/stats';
  static String leagueTopScorers(String leagueId) =>
      '/teams/league/$leagueId/top-scorers';
  static String playerStats(String playerId) =>
      '/teams/players/$playerId/stats';

  // ─── Matches ─────────────────────────────────────────────────────────────
  static const String matches = '/matches';
  static const String upcomingMatches = '/matches/upcoming';
  static const String liveMatches = '/matches/live';
  static String matchDetails(String id) => '/matches/$id';
  static String teamMatches(String teamId) => '/matches/team/$teamId';
  static String teamForm(String teamId) => '/matches/team/$teamId/form';
  static String teamFixtures(String teamId) => '/matches/team/$teamId/fixtures';

  // ─── Predictions ─────────────────────────────────────────────────────────
  static const String predictions = '/predictions';
  static String matchPredictions(String matchId) =>
      '/predictions/match/$matchId';

  // ─── Bets ────────────────────────────────────────────────────────────────
  static const String bets = '/bets';
  static const String placeBet = '/bets/place';
  static const String myBets = '/bets/my';
  static String betDetails(String betId) => '/bets/$betId';
  static String matchOdds(String matchId) => '/bets/match/$matchId/odds';

  // ─── Wallet ──────────────────────────────────────────────────────────────
  static const String wallet = '/wallet';
  static const String walletBalance = '/wallet/balance';
  static const String walletDeposit = '/wallet/deposit';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletTransactions = '/wallet/transactions';

  // ─── Payments (Stripe) ────────────────────────────────────────────────────
  static const String stripeSetupIntent = '/payments/stripe/setup-intent';
  static const String stripeDepositIntent = '/payments/stripe/deposit-intent';
  static const String stripePaymentMethods = '/payments/stripe/payment-methods';

  // ─── Analytics ───────────────────────────────────────────────────────────
  static const String analytics = '/analytics';
  static const String userStats = '/analytics/user/stats';
  static String teamAnalytics(String teamId) => '/analytics/team/$teamId';

  // ─── Headers ─────────────────────────────────────────────────────────────
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
}
