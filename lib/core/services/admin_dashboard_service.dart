import '../constants/api_constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AdminBettor {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final String accountStatus;
  final double balance;
  final int totalBets;
  final double winRate;

  AdminBettor({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.accountStatus,
    required this.balance,
    required this.totalBets,
    required this.winRate,
  });

  factory AdminBettor.fromJson(Map<String, dynamic> json) {
    return AdminBettor(
      id: (json['id'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['name'] ?? 'Unknown').toString(),
      email: (json['email'] ?? '-').toString(),
      role: (json['role'] ?? 'player').toString(),
      accountStatus: (json['accountStatus'] ?? 'active').toString(),
      balance: _toDouble(json['balance'] ?? json['walletBalance']),
      totalBets: _toInt(json['totalBets'] ?? json['betsCount']),
      winRate: _toDouble(json['winRate']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class AdminDashboardData {
  final Map<String, dynamic> stats;
  final List<AdminBettor> bettors;
  final bool usedFallback;

  AdminDashboardData({
    required this.stats,
    required this.bettors,
    required this.usedFallback,
  });
}

class AdminDashboardService {
  final ApiService _apiService;
  late final AuthService _authService;

  AdminDashboardService(this._apiService) {
    _authService = AuthService(_apiService);
  }

  Future<AdminDashboardData> getDashboardData({int limit = 50}) async {
    await _authService.syncTokenToApi();

    final statsResult = await _getFirstMap([
      ApiConstants.analyticsAdminDashboard,
      ApiConstants.adminDashboard,
      '/admin/stats',
    ]);

    final bettorsResult = await _getFirstList([
      '${ApiConstants.analyticsAdminBettors}?limit=$limit',
      '${ApiConstants.adminBettors}?limit=$limit',
      '${ApiConstants.usersByRole}?role=player&limit=$limit',
      '/users/bettors?limit=$limit',
    ]);

    final bettors = bettorsResult
        .whereType<Map<String, dynamic>>()
        .map(AdminBettor.fromJson)
        .toList();

    final stats = statsResult.isNotEmpty
        ? statsResult
        : _buildFallbackStatsFromBettors(bettors);

    return AdminDashboardData(
      stats: stats,
      bettors: bettors,
      usedFallback: statsResult.isEmpty,
    );
  }

  Future<Map<String, dynamic>> _getFirstMap(List<String> endpoints) async {
    for (final endpoint in endpoints) {
      try {
        final response = await _apiService.get(endpoint);
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['data'] is Map<String, dynamic>) {
            return data['data'] as Map<String, dynamic>;
          }
          return data;
        }
      } catch (_) {
        // Try next endpoint.
      }
    }
    return {};
  }

  Future<List<dynamic>> _getFirstList(List<String> endpoints) async {
    for (final endpoint in endpoints) {
      try {
        final response = await _apiService.get(endpoint);
        final data = response.data;
        if (data is List) return data;
        if (data is Map<String, dynamic>) {
          final users = data['users'];
          if (users is List) return users;
          final items = data['items'];
          if (items is List) return items;
          final innerData = data['data'];
          if (innerData is List) return innerData;
        }
      } catch (_) {
        // Try next endpoint.
      }
    }
    return const [];
  }

  Map<String, dynamic> _buildFallbackStatsFromBettors(List<AdminBettor> bettors) {
    if (bettors.isEmpty) {
      return {
        'totalBettors': 0,
        'activeBettors': 0,
        'totalBets': 0,
        'averageWinRate': 0.0,
        'totalBalance': 0.0,
      };
    }

    final active = bettors
        .where((b) => b.accountStatus.toLowerCase() == 'active')
        .length;
    final totalBets = bettors.fold<int>(0, (sum, b) => sum + b.totalBets);
    final totalBalance = bettors.fold<double>(0, (sum, b) => sum + b.balance);
    final avgWinRate = bettors.fold<double>(0, (sum, b) => sum + b.winRate) /
        bettors.length;

    return {
      'totalBettors': bettors.length,
      'activeBettors': active,
      'totalBets': totalBets,
      'averageWinRate': avgWinRate,
      'totalBalance': totalBalance,
    };
  }
}
