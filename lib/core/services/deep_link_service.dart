import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final initialLink = await _appLinks.getInitialLink();
      _handleDeepLink(initialLink);
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        debugPrint('Error listening to link stream: $err');
      },
    );
  }

  void _handleDeepLink(Uri? uri) {
    if (uri == null) return;
    if (!_isResetLink(uri)) return;
    
    final token = uri.queryParameters['token'];
    if (token == null || token.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRoutes.router.go(AppRoutes.resetPassword, extra: {'token': token});
    });
  }

  bool _isResetLink(Uri uri) {
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();

    if (uri.scheme == 'footsmart') {
      if (host == 'reset-password') return true;
      if (host == 'auth' && path == '/reset-password') return true;
      return path.contains('reset-password');
    }

    if (uri.scheme == 'https' || uri.scheme == 'http') {
      return path.contains('reset-password');
    }

    return false;
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
