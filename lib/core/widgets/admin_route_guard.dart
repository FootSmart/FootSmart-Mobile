import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/auth_service.dart';

class AdminRouteGuard extends StatefulWidget {
  final Widget child;

  const AdminRouteGuard({super.key, required this.child});

  @override
  State<AdminRouteGuard> createState() => _AdminRouteGuardState();
}

class _AdminRouteGuardState extends State<AdminRouteGuard> {
  bool _checking = true;
  bool _isAdmin = false;
  final AuthService _authService = AuthService(ApiService());

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    await _authService.syncTokenToApi();
    final user = await _authService.getUser();

    if (!mounted) return;

    final isAdmin = user?.role == 'admin';
    if (isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      });
    }

    setState(() {
      _isAdmin = isAdmin;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || _isAdmin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return widget.child;
  }
}
