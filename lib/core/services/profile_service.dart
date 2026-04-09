import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class ProfileService {
  final ApiService _apiService;
  static const String _userKey = 'user_data';
  static const String _statsKey = 'user_stats';

  ProfileService(this._apiService);

  /// Fetch current user profile from backend
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);
      if (response.statusCode == 200) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        await _saveUserLocally(user);
        return user;
      }
    } catch (e) {
      // If backend call fails, try to get from local storage
      return _getUserLocally();
    }
    return _getUserLocally();
  }

  /// Fetch user stats from backend
  Future<UserStats?> getUserStats() async {
    try {
      final response = await _apiService.get(ApiConstants.userStats);
      if (response.statusCode == 200) {
        final stats = UserStats.fromJson(response.data as Map<String, dynamic>);
        await _saveStatsLocally(stats);
        return stats;
      }
    } catch (e) {
      // If backend call fails, try to get from local storage
      return _getStatsLocally();
    }
    return _getStatsLocally();
  }

  /// Update user profile
  Future<User?> updateProfile(Map<String, dynamic> updatedData) async {
    try {
      final response = await _apiService.put(
        ApiConstants.updateProfile,
        data: updatedData,
      );
      if (response.statusCode == 200) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        await _saveUserLocally(user);
        return user;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Upload avatar image (multipart/form-data)
  Future<User?> uploadAvatar(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      ),
    });

    final response = await _apiService.put(
      ApiConstants.uploadAvatar,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    if (response.statusCode == 200) {
      final user = User.fromJson(response.data as Map<String, dynamic>);
      await _saveUserLocally(user);
      return user;
    }
    return null;
  }

  /// Save user locally
  Future<void> _saveUserLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  /// Get user from local storage
  Future<User?> _getUserLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null) return null;

    try {
      final userData = jsonDecode(userString) as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Save stats locally
  Future<void> _saveStatsLocally(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = jsonEncode({
      'totalBets': stats.totalBets,
      'winRate': stats.winRate,
      'totalWon': stats.totalWon,
      'roi': stats.roi,
      'wins': stats.wins,
      'losses': stats.losses,
      'totalStaked': stats.totalStaked,
      'memberSince': stats.memberSince?.toIso8601String(),
    });
    await prefs.setString(_statsKey, statsJson);
  }

  /// Get stats from local storage
  Future<UserStats?> _getStatsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final statsString = prefs.getString(_statsKey);

    if (statsString == null) return null;

    try {
      final statsData = jsonDecode(statsString) as Map<String, dynamic>;
      return UserStats.fromJson(statsData);
    } catch (e) {
      return null;
    }
  }

  /// Clear cached profile data on logout
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_statsKey);
  }
}
