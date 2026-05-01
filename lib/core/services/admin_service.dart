import '../constants/api_constants.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _api;

  AdminService(this._api);

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _api.get(ApiConstants.adminDashboard);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getUsers({
    String? search,
    String? role,
    String? accountStatus,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _api.get(
      ApiConstants.adminUsers,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null && role.isNotEmpty) 'role': role,
        if (accountStatus != null && accountStatus.isNotEmpty)
          'accountStatus': accountStatus,
        'limit': limit,
        'offset': offset,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> updateUserPoints(String userId, double points) async {
    await _api.patch(
      ApiConstants.adminUserPoints(userId),
      data: {'points': points},
    );
  }

  Future<void> updateUserStatus(String userId, String accountStatus) async {
    await _api.patch(
      ApiConstants.adminUserStatus(userId),
      data: {'account_status': accountStatus},
    );
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _api.patch(
      ApiConstants.adminUserRole(userId),
      data: {'role': role},
    );
  }

  Future<Map<String, dynamic>> generateTestMatch({
    required String leagueId,
    required String homeTeamId,
    required String awayTeamId,
    required int minutesFromNow,
    required int betCloseMinutesBeforeKickoff,
    required double homeOdds,
    required double drawOdds,
    required double awayOdds,
  }) async {
    final response = await _api.post(
      ApiConstants.adminTestMatch,
      data: {
        'leagueId': leagueId,
        'homeTeamId': homeTeamId,
        'awayTeamId': awayTeamId,
        'minutesFromNow': minutesFromNow,
        'betCloseMinutesBeforeKickoff': betCloseMinutesBeforeKickoff,
        'homeOdds': homeOdds,
        'drawOdds': drawOdds,
        'awayOdds': awayOdds,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> finishMatch(
    String matchId, {
    required int homeGoals,
    required int awayGoals,
  }) async {
    final response = await _api.post(
      ApiConstants.adminFinishMatch(matchId),
      data: {
        'homeGoals': homeGoals,
        'awayGoals': awayGoals,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> runSettlement() async {
    final response = await _api.post(ApiConstants.adminSettle);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getAdminMatches({
    String? status,
    String? leagueId,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _api.get(
      ApiConstants.adminMatches,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (leagueId != null && leagueId.isNotEmpty) 'leagueId': leagueId,
        if (search != null && search.isNotEmpty) 'search': search,
        'limit': limit,
        'offset': offset,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateMatch(
    String matchId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _api.patch(
      '${ApiConstants.adminMatches}/$matchId',
      data: payload,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteMatch(String matchId) async {
    await _api.delete('${ApiConstants.adminMatches}/$matchId');
  }

  Future<Map<String, dynamic>?> getMatchOdds(String matchId) async {
    final response = await _api.get(ApiConstants.adminMatchOdds(matchId));
    if (response.data == null) return null;
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateMatchOdds(
    String matchId, {
    required double homeOdds,
    required double drawOdds,
    required double awayOdds,
  }) async {
    final response = await _api.patch(
      ApiConstants.adminMatchOdds(matchId),
      data: {
        'homeOdds': homeOdds,
        'drawOdds': drawOdds,
        'awayOdds': awayOdds,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getAdminBets({
    String? status,
    String? userId,
    String? matchId,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _api.get(
      ApiConstants.adminBets,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        if (matchId != null && matchId.isNotEmpty) 'matchId': matchId,
        'limit': limit,
        'offset': offset,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> runFullTestScenario({
    required String userEmail,
    required double points,
    required String leagueId,
    required String homeTeamId,
    required String awayTeamId,
  }) async {
    final response = await _api.post(
      ApiConstants.adminFullTestScenario,
      data: {
        'userEmail': userEmail,
        'points': points,
        'leagueId': leagueId,
        'homeTeamId': homeTeamId,
        'awayTeamId': awayTeamId,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> resetUserPoints(String userId, double points) async {
    await _api.post(
      ApiConstants.adminUserResetPoints(userId),
      data: {'points': points},
    );
  }
}
