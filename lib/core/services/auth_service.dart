import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';

  AuthService(this._apiService);

  Future<AuthResponse> login(
    LoginRequest request, {
    bool rememberMe = true,
  }) async {
    final response = await _apiService.post(
      ApiConstants.authLogin,
      data: request.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse, rememberMe: rememberMe);
    return authResponse;
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiService.post(
      ApiConstants.authRegister,
      data: request.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse, rememberMe: true);
    return authResponse;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _apiService.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );

    return {
      'success': true,
      'message':
          response.data['message'] ?? 'Password reset email sent successfully',
    };
  }

  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    final response = await _apiService.post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );

    return {
      'success': true,
      'message': response.data['message'] ?? 'Password reset successfully',
    };
  }

  Future<Map<String, dynamic>> verifyResetToken(String token) async {
    final response = await _apiService.post(
      ApiConstants.verifyResetToken,
      data: {'token': token},
    );

    return response.data;
  }

  Future<void> _saveAuthData(
    AuthResponse authResponse, {
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = authResponse.user.toJson();

    await prefs.setBool(_rememberMeKey, rememberMe);
    _apiService.setAuthToken(authResponse.accessToken);

    if (rememberMe) {
      await prefs.setString(_tokenKey, authResponse.accessToken);
      await prefs.setString(_userKey, jsonEncode(userJson));
    } else {
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null) return null;

    try {
      final userMap = jsonDecode(userString) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasStoredSession() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && token.isNotEmpty && user != null;
  }

  Future<bool> hasValidSession() async {
    await syncTokenToApi();

    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      await _apiService.get(ApiConstants.profile);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        await clearSavedSession(clearRememberMe: true);
        return false;
      }

      return true;
    }
  }

  Future<void> logout({bool clearRememberMe = false}) async {
    await clearSavedSession(clearRememberMe: clearRememberMe);
  }

  Future<void> clearSavedSession({bool clearRememberMe = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    if (clearRememberMe) {
      await prefs.remove(_rememberMeKey);
    }
    _apiService.clearAuthToken();
  }

  Future<void> syncTokenToApi() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

    if (!rememberMe) {
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      _apiService.clearAuthToken();
      return;
    }

    final token = prefs.getString(_tokenKey);

    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    } else {
      _apiService.clearAuthToken();
    }
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<void> setRememberMe(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
  }
}
