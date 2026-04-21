import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/routes/app_routes.dart';
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
    const ProviderScope(
      child: FootSmartProApp(),
    ),
  );
}

class FootSmartProApp extends ConsumerWidget {
  const FootSmartProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            isDark ? const Color(0xFF0D1117) : const Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'FootSmart Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: AppRoutes.router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final textScaler = media.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.2,
        );

        return MediaQuery(
          data: media.copyWith(textScaler: textScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
