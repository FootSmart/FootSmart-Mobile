import '../constants/api_constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AnalyticsService {
  final ApiService _apiService;
  late final AuthService _authService;

  AnalyticsService(this._apiService) {
    _authService = AuthService(_apiService);
  }

  /// GET /analytics/user/stats
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      await _authService.syncTokenToApi();
      final response = await _apiService.get(ApiConstants.analyticsUserStats);
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {};
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch user stats: $e');
    }
  }

  /// GET /analytics/matches/insights
  Future<Map<String, dynamic>> getMatchInsights({
    String? leagueId,
    int limit = 30,
  }) async {
    try {
      await _authService.syncTokenToApi();
      final Map<String, dynamic> params = {'limit': limit};
      if (leagueId != null && leagueId.isNotEmpty) {
        params['leagueId'] = leagueId;
      }
      final response = await _apiService.get(
        ApiConstants.analyticsMatchInsights,
        queryParameters: params,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {};
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch match insights: $e');
    }
  }

  /// GET /analytics/market/movements
  Future<List<dynamic>> getMarketMovements({String? leagueId}) async {
    try {
      await _authService.syncTokenToApi();
      final Map<String, dynamic> params = {};
      if (leagueId != null && leagueId.isNotEmpty) {
        params['leagueId'] = leagueId;
      }
      final response = await _apiService.get(
        ApiConstants.analyticsMarketMovements,
        queryParameters: params.isNotEmpty ? params : null,
      );
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data.containsKey('data')) {
        final inner = data['data'];
        if (inner is List) return inner;
      }
      return [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch market movements: $e');
    }
  }

  /// GET /analytics/predictions
  Future<List<dynamic>> getPredictions({
    String? leagueId,
    int limit = 20,
  }) async {
    try {
      await _authService.syncTokenToApi();
      final Map<String, dynamic> params = {'limit': limit};
      if (leagueId != null && leagueId.isNotEmpty) {
        params['leagueId'] = leagueId;
      }
      final response = await _apiService.get(
        ApiConstants.analyticsPredictions,
        queryParameters: params,
      );
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data.containsKey('data')) {
        final inner = data['data'];
        if (inner is List) return inner;
      }
      if (data is Map && data.containsKey('predictions')) {
        final inner = data['predictions'];
        if (inner is List) return inner;
      }
      return [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch predictions: $e');
    }
  }

  /// GET /analytics/match-predictions
  Future<Map<String, dynamic>> getMatchPredictions({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      await _authService.syncTokenToApi();
      final Map<String, dynamic> params = {
        'page': page,
        'pageSize': pageSize,
      };
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }
      final response = await _apiService.get(
        ApiConstants.analyticsMatchPredictions,
        queryParameters: params,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {
        'data': <dynamic>[],
        'page': page,
        'pageSize': pageSize,
        'total': 0,
        'totalPages': 1,
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch match predictions: $e');
    }
  }
}
