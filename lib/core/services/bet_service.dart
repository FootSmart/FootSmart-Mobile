import '../constants/api_constants.dart';
import '../models/bet.dart';
import 'api_service.dart';

class BetService {
  final ApiService _apiService;

  BetService(this._apiService);

  Future<MatchOdds> getMatchOdds(String matchId) async {
    try {
      final response = await _apiService.get(ApiConstants.matchOdds(matchId));
      return MatchOdds.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch match odds: $e');
    }
  }

  Future<PlaceBetResult> placeBet({
    required String matchId,
    required BetSelection selection,
    required double stake,
  }) async {
    if (stake <= 0) {
      throw ApiException('Stake must be greater than zero');
    }

    try {
      final response = await _apiService.post(
        ApiConstants.placeBet,
        data: {
          'matchId': matchId,
          'selection': selection.apiValue,
          'stake': double.parse(stake.toStringAsFixed(2)),
        },
      );

      return PlaceBetResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to place bet: $e');
    }
  }
}
