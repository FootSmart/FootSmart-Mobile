import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

/// Base API service for handling HTTP requests
class ApiService {
  late final Dio _dio;
  String? _authToken;
  late final List<String> _fallbackBaseUrls;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  String _resolveBaseUrl() {
    const envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envBaseUrl.isNotEmpty) return envBaseUrl;

    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return 'http://$host:3009/api';
    }

    return ApiConstants.baseUrl;
  }

  List<String> _resolveFallbackBaseUrls() {
    if (!kIsWeb) return const [];

    final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
    final urls = <String>[
      'http://$host:3009/api',
      'http://$host:3008/api',
      'http://$host:3001/api',
    ];

    const envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envBaseUrl.isNotEmpty) {
      urls.remove(envBaseUrl);
      urls.insert(0, envBaseUrl);
    }

    return urls;
  }

  bool _isRetriableNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown;
  }

  Future<Response> _requestWithFallback(
    Future<Response> Function() request,
  ) async {
    DioException? lastError;

    for (final baseUrl in _fallbackBaseUrls) {
      _dio.options.baseUrl = baseUrl;
      try {
        return await request();
      } on DioException catch (e) {
        lastError = e;
        if (!_isRetriableNetworkError(e)) rethrow;
      }
    }

    if (lastError != null) throw lastError;
    throw ApiException('No internet connection');
  }

  ApiService._internal() {
    _fallbackBaseUrls = _resolveFallbackBaseUrls();
    _dio = Dio(BaseOptions(
      baseUrl: _resolveBaseUrl(),
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: ApiConstants.defaultHeaders,
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Handle response
          return handler.next(response);
        },
        onError: (error, handler) {
          // Handle errors
          _handleError(error);
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _requestWithFallback(
        () => _dio.get(
          path,
          queryParameters: queryParameters,
          options: options,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _requestWithFallback(
        () => _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _requestWithFallback(
        () => _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _requestWithFallback(
        () => _dio.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static String _messageFromResponseData(dynamic data) {
    if (data == null) return 'Server error occurred';
    if (data is String) return data.isEmpty ? 'Server error occurred' : data;
    if (data is Map) {
      final m = data['message'];
      if (m is String) return m;
      if (m is List && m.isNotEmpty) return m.first.toString();
      return data['error']?.toString() ?? 'Server error occurred';
    }
    return 'Server error occurred';
  }

  /// Handle API errors
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ApiException(
            'Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _messageFromResponseData(error.response?.data);
        throw ApiException('Error $statusCode: $message');
      case DioExceptionType.cancel:
        throw ApiException('Request was cancelled');
      case DioExceptionType.connectionError:
        throw ApiException('No internet connection');
      default:
        throw ApiException('An unexpected error occurred');
    }
  }
}

/// Custom API exception
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
