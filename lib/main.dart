import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/services/theme_service.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Même clé que STRIPE_PUBLISHABLE_KEY (Dashboard, mode test). Optionnel si fournie par l’API.
  // Ex. : flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
  const pkFromBuild = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  if (pkFromBuild.isNotEmpty) {
    Stripe.publishableKey = pkFromBuild;
    await Stripe.instance.applySettings();
  }

  // Lock device orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize auth token from storage
  final authService = AuthService(ApiService());
  await authService.initializeAuth();

  // Requis pour DateFormat avec locale (ex. fr_FR) — écrans wallet / paiements
  await initializeDateFormatting('fr_FR', null);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const FootSmartProApp(),
    ),
  );
}

class FootSmartProApp extends StatelessWidget {
  const FootSmartProApp({super.key});

  String _initialRoute() {
    if (!kIsWeb) return AppRoutes.splash;

    final path = Uri.base.path.trim();
    if (path.isNotEmpty && path != '/' && AppRoutes.routes.containsKey(path)) {
      return path;
    }

    return AppRoutes.splash;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        // Update system UI overlay based on theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeService.isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: themeService.isDarkMode
                ? AppColors.primaryDark
                : AppColors.backgroundLight,
            systemNavigationBarIconBrightness:
                themeService.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'FootSmart Pro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          initialRoute: _initialRoute(),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
