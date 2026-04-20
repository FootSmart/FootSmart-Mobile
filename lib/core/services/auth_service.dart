import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';

  AuthService(this._apiService);

  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request, {bool rememberMe = true}) async {
    final response = await _apiService.post(
      ApiConstants.authLogin,
      data: request.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse, rememberMe: rememberMe);
    return authResponse;
  }

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiService.post(
      ApiConstants.authRegister,
      data: request.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse, rememberMe: true);
    return authResponse;
  }

  /// Request password reset email
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

  /// Reset password with token
  Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
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

  /// Verify reset token validity
  Future<Map<String, dynamic>> verifyResetToken(String token) async {
    final response = await _apiService.post(
      ApiConstants.verifyResetToken,
      data: {'token': token},
    );

    return response.data;
  }

  /// Save authentication data to local storage
  Future<void> _saveAuthData(AuthResponse authResponse, {required bool rememberMe}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);

    // Toujours persister le JWT : sinon [syncTokenToApi] / hot restart n’ont rien à charger → 401 sur wallet.
    // « Se souvenir de moi » reste une préférence (UI / futur), pas une raison d’effacer le token.
    final userJson = authResponse.user.toJson();
    await prefs.setString(_tokenKey, authResponse.accessToken);
    await prefs.setString(_userKey, jsonEncode(userJson));

    _apiService.setAuthToken(authResponse.accessToken);
  }

  /// Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get stored user data
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null) return null;

    try {
      final userMap = jsonDecode(userString) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Validate that the persisted token is still accepted by backend.
  ///
  /// This avoids navigating to authenticated screens with a stale token,
  /// which would immediately cause 401/Unauthorized errors after app restart.
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
        await logout();
        return false;
      }

      // Keep local session on transient failures (offline/server hiccups).
      return true;
    }
  }

  /// Logout - clear all stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    // Clear token from API service
    _apiService.clearAuthToken();
  }

  /// Remet le JWT dans [ApiService] depuis le stockage (ex. après hot restart Flutter :
  /// le singleton perd la mémoire mais le token peut rester dans SharedPreferences).
  Future<void> syncTokenToApi() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    }
  }

  /// Initialize auth state - call on app startup
  Future<void> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    } else {
      _apiService.clearAuthToken();
    }
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? true;
  }

  Future<void> setRememberMe(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
    if (!rememberMe) {
      // Si l'utilisateur désactive "remember me", on supprime les données persistées.
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      _apiService.clearAuthToken();
    }
  }
}
