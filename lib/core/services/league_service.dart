import '../models/league.dart';
import '../models/standing.dart';
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

  /// Get league by ID
  ///
  /// [leagueId] - The UUID of the league
  /// This would require a backend endpoint like GET /leagues/:id
  /// Currently not implemented in backend, but included for completeness
  Future<League?> getLeagueById(String leagueId) async {
    try {
      final leagues = await getAllLeagues();
      return leagues.firstWhere(
        (league) => league.id == leagueId,
        orElse: () => throw ApiException('League not found'),
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch league: ${e.toString()}');
    }
  }

  /// Search leagues by name or country
  ///
  /// This performs client-side filtering. For better performance,
  /// consider implementing server-side search in the backend
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
