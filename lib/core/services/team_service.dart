import '../models/team.dart';
import '../models/player.dart'; // Player + PlayerStats
import '../constants/api_constants.dart';
import 'api_service.dart';

/// Service for all team-related API calls
class TeamService {
  final ApiService _apiService;

  TeamService(this._apiService);

  /// All teams, optionally filtered by leagueId
  Future<List<Team>> getAllTeams({String? leagueId}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teams,
        queryParameters: {
          if (leagueId != null) 'leagueId': leagueId,
        },
      );
      return (response.data as List<dynamic>)
          .map((t) => Team.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiException('Failed to fetch teams: $e');
    }
  }

  /// Single team details (name, logo, stadium, country, …)
  Future<Team> getTeamById(String teamId) async {
    try {
      final response = await _apiService.get(ApiConstants.teamDetails(teamId));
      return Team.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to fetch team $teamId: $e');
    }
  }

  /// Team details + full squad in one call
  Future<TeamWithPlayers> getTeamWithPlayers(String teamId) async {
    try {
      final response = await _apiService.get(ApiConstants.teamFull(teamId));
      return TeamWithPlayers.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to fetch team with players: $e');
    }
  }

  /// Squad members with individual player stats
  Future<List<Player>> getTeamPlayers(
    String teamId, {
    bool activeOnly = false,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teamPlayers(teamId),
        queryParameters: {
          if (activeOnly) 'activeOnly': true,
        },
      );
      return (response.data as List<dynamic>)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiException('Failed to fetch team players: $e');
    }
  }

  /// Season-aggregated team stats (streaks, clean sheets, etc.)
  Future<TeamStats> getTeamStats(String teamId, {int? season}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teamStats(teamId),
        queryParameters: {
          if (season != null) 'season': season,
        },
      );
      return TeamStats.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to fetch team stats: $e');
    }
  }

  /// Top goal-scorers across all teams in a league
  Future<List<Player>> getLeagueTopScorers(
    String leagueId, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.leagueTopScorers(leagueId),
        queryParameters: {'limit': limit},
      );
      return (response.data as List<dynamic>)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiException('Failed to fetch top scorers: $e');
    }
  }

  /// Detailed player stats from v_player_stats view
  Future<PlayerStats> getPlayerStats(String playerId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.playerStats(playerId),
      );
      return PlayerStats.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to fetch player stats: $e');
    }
  }
}
