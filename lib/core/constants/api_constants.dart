/// API configuration constants for FootSmart backend
class ApiConstants {
  ApiConstants._();

  // Base URL - For Android emulator use 10.0.2.2, for iOS simulator use localhost
  // For physical device, use your computer's actual IP address
  static const String baseUrl = 'http://10.0.2.2:3001';

  // API Version
  static const String apiVersion = 'v1';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints

  // Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // League endpoints
  static const String leagues = '/leagues';
  static String leagueStandings(String leagueId) =>
      '/leagues/$leagueId/standings';

  // Match endpoints
  static const String matches = '/matches';
  static String matchDetails(String matchId) => '/matches/$matchId';
  static const String upcomingMatches = '/matches/upcoming';
  static const String liveMatches = '/matches/live';

  // Prediction endpoints
  static const String predictions = '/predictions';
  static String matchPredictions(String matchId) =>
      '/predictions/match/$matchId';

  // Betting endpoints
  static const String bets = '/bets';
  static const String myBets = '/bets/my';
  static String betDetails(String betId) => '/bets/$betId';

  // Wallet endpoints
  static const String wallet = '/wallet';
  static const String walletBalance = '/wallet/balance';
  static const String walletDeposit = '/wallet/deposit';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletTransactions = '/wallet/transactions';

  // Analytics endpoints
  static const String analytics = '/analytics';
  static const String userStats = '/analytics/user/stats';
  static String teamAnalytics(String teamId) => '/analytics/team/$teamId';

  // User profile endpoints
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile/update';

  // Headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
}
