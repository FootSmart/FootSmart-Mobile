import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthService(this._apiService);

  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _apiService.post(
      ApiConstants.authLogin,
      data: request.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse);
    return authResponse;
  }

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiService.post(
      ApiConstants.authRegister,
      data: request.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse);
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
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, authResponse.accessToken);

    // Store user data as JSON string
    final userJson = authResponse.user.toJson();
    await prefs.setString(_userKey, userJson.toString());

    // Update API service with the token
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
      // Parse stored user data (simplified - in production use json.decode)
      return null; // This will be improved with proper JSON parsing
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout - clear all stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    // Clear token from API service
    _apiService.clearAuthToken();
  }

  /// Initialize auth state - call on app startup
  Future<void> initializeAuth() async {
    final token = await getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }
}
