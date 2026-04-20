import '../models/league.dart';
import '../models/standing.dart';
import '../models/match.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

/// Service for handling league-related API calls
class LeagueService {
  final ApiService _apiService;

  LeagueService(this._apiService);

  /// Get all available leagues
  ///
  /// Returns a list of all leagues from the backend
  /// Throws [ApiException] on error
  Future<List<League>> getAllLeagues() async {
    try {
      final response = await _apiService.get(ApiConstants.leagues);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => League.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException('Failed to fetch leagues');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch leagues: ${e.toString()}');
    }
  }

  /// Get standings for a specific league
  ///
  /// [leagueId] - The UUID of the league
  /// Returns league information along with standings data
  /// Throws [ApiException] on error
  Future<LeagueStandings> getLeagueStandings(String leagueId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.leagueStandings(leagueId),
      );

      if (response.statusCode == 200) {
        return LeagueStandings.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException('Failed to fetch league standings');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch league standings: ${e.toString()}');
    }
  }

  /// Get league by ID – uses the dedicated GET /leagues/:id endpoint
  Future<League> getLeagueById(String leagueId) async {
    try {
      final response = await _apiService.get(ApiConstants.leagueById(leagueId));
      if (response.statusCode == 200) {
        return League.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException('Failed to fetch league');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch league: ${e.toString()}');
    }
  }

  /// Get matches for a league (paginated)
  Future<MatchListResponse> getLeagueMatches(
    String leagueId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.leagueMatches(leagueId),
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.statusCode == 200) {
        return MatchListResponse.fromJson(
            response.data as Map<String, dynamic>);
      } else {
        throw ApiException('Failed to fetch league matches');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch league matches: ${e.toString()}');
    }
  }

  /// Search leagues by name or country (client-side filter)
  Future<List<League>> searchLeagues(String query) async {
    try {
      final leagues = await getAllLeagues();
      final lowerQuery = query.toLowerCase();

      return leagues.where((league) {
        final nameMatch = league.name.toLowerCase().contains(lowerQuery);
        final countryMatch =
            league.country?.toLowerCase().contains(lowerQuery) ?? false;
        return nameMatch || countryMatch;
      }).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to search leagues: ${e.toString()}');
    }
  }
}
