import '../models/match.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

/// Service for all match-related API calls
class MatchService {
  final ApiService _apiService;

  MatchService(this._apiService);

  // ─── Helpers ──────────────────────────────────────────────────────────────

  MatchListResponse _parseList(dynamic data) =>
      MatchListResponse.fromJson(data as Map<String, dynamic>);

  FootballMatch _parseMatch(dynamic data) =>
      FootballMatch.fromJson(data as Map<String, dynamic>);

  // ─── Public API ───────────────────────────────────────────────────────────

  /// All matches – filterable, paginated
  ///
  /// [status]   'scheduled' | 'live' | 'finished'
  /// [leagueId] filter by league UUID
  /// [from] / [to] date range ISO strings
  Future<MatchListResponse> getAllMatches({
    String? status,
    String? leagueId,
    String? from,
    String? to,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.matches,
        queryParameters: {
          if (status != null) 'status': status,
          if (leagueId != null) 'leagueId': leagueId,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          'limit': limit,
          'offset': offset,
        },
      );
      return _parseList(response.data);
    } catch (e) {
      throw ApiException('Failed to fetch matches: $e');
    }
  }

  /// Next scheduled fixtures (earliest first)
  Future<MatchListResponse> getUpcomingMatches({
    int limit = 20,
    String? leagueId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.upcomingMatches,
        queryParameters: {
          'limit': limit,
          if (leagueId != null) 'leagueId': leagueId,
        },
      );
      return _parseList(response.data);
    } catch (e) {
      throw ApiException('Failed to fetch upcoming matches: $e');
    }
  }

  /// Currently live matches
  Future<MatchListResponse> getLiveMatches() async {
    try {
      final response = await _apiService.get(ApiConstants.liveMatches);
      return _parseList(response.data);
    } catch (e) {
      throw ApiException('Failed to fetch live matches: $e');
    }
  }

  /// Full match detail with events (goals, cards, subs)
  Future<FootballMatch> getMatchById(String matchId) async {
    try {
      final response =
          await _apiService.get(ApiConstants.matchDetails(matchId));
      return _parseMatch(response.data);
    } catch (e) {
      throw ApiException('Failed to fetch match $matchId: $e');
    }
  }

  /// All matches played by a team (home & away), paginated
  Future<MatchListResponse> getTeamMatches(
    String teamId, {
    String? status,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teamMatches(teamId),
        queryParameters: {
          if (status != null) 'status': status,
          'limit': limit,
          'offset': offset,
        },
      );
      return _parseList(response.data);
    } catch (e) {
      throw ApiException('Failed to fetch team matches: $e');
    }
  }

  /// Recent form (W/D/L) for last N finished matches
  Future<TeamForm> getTeamForm(String teamId, {int last = 5}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teamForm(teamId),
        queryParameters: {'last': last},
      );
      return TeamForm.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to fetch team form: $e');
    }
  }

  /// Upcoming fixtures for a specific team
  Future<List<FootballMatch>> getTeamFixtures(
    String teamId, {
    int limit = 5,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teamFixtures(teamId),
        queryParameters: {'limit': limit},
      );
      return (response.data as List<dynamic>)
          .map((m) => FootballMatch.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiException('Failed to fetch team fixtures: $e');
    }
  }
}
