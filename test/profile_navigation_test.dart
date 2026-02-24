import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/features/profile/profile_screen.dart';
import 'package:footsmart_pro/features/profile/screens/personal_information_screen.dart';
import 'package:footsmart_pro/features/profile/screens/verification_status_screen.dart';
import 'package:footsmart_pro/features/profile/screens/notifications_screen.dart';
import 'package:footsmart_pro/features/profile/screens/payment_methods_screen.dart';
import 'package:footsmart_pro/features/profile/screens/betting_history_screen.dart';
import 'package:footsmart_pro/features/profile/screens/responsible_gambling_screen.dart';
import 'package:footsmart_pro/features/profile/screens/help_support_screen.dart';
import 'package:footsmart_pro/features/profile/screens/settings_screen.dart';

// ---------------------------------------------------------------------------
// Minimal app wrapper that only registers the routes needed for profile tests,
// so we don't need the full MaterialApp routes map (which requires every
// dependency screen to be importable).
// ---------------------------------------------------------------------------
Widget _buildTestApp() {
  return MaterialApp(
    initialRoute: AppRoutes.profile,
    routes: {
      AppRoutes.profile: (_) => const ProfileScreen(),
      AppRoutes.personalInformation: (_) => const PersonalInformationScreen(),
      AppRoutes.verificationStatus: (_) => const VerificationStatusScreen(),
      AppRoutes.notifications: (_) => const NotificationsScreen(),
      AppRoutes.paymentMethods: (_) => const PaymentMethodsScreen(),
      AppRoutes.bettingHistory: (_) => const BettingHistoryScreen(),
      AppRoutes.responsibleGambling: (_) => const ResponsibleGamblingScreen(),
      AppRoutes.helpSupport: (_) => const HelpSupportScreen(),
      AppRoutes.settings: (_) => const SettingsScreen(),
      // Required by BottomNavBar taps (not tested here – just prevent crashes)
      AppRoutes.home: (_) => const Scaffold(body: Text('Home')),
      AppRoutes.explore: (_) => const Scaffold(body: Text('Explore')),
      AppRoutes.betting: (_) => const Scaffold(body: Text('Betting')),
      AppRoutes.wallet: (_) => const Scaffold(body: Text('Wallet')),
      AppRoutes.signIn: (_) => const Scaffold(body: Text('SignIn')),
    },
  );
}

/// Tap a profile menu row identified by its label text, then pump until the
/// new screen has settled.  Returns the finder for the destination screen's
/// title so the caller can assert on it.
Future<void> _tapRowAndVerify(
  WidgetTester tester, {
  required String rowLabel,
  required String expectedTitle,
}) async {
  // Scroll the list so the row is visible (profile screen is scrollable).
  await tester.ensureVisible(find.text(rowLabel));
  await tester.pumpAndSettle();

  await tester.tap(find.text(rowLabel));
  await tester.pumpAndSettle();

  // The destination screen's AppBar title must be visible.
  expect(find.text(expectedTitle), findsAtLeastNWidgets(1),
      reason: 'Expected to navigate to "$expectedTitle" after tapping "$rowLabel"');

  // Confirm we can go back.
  final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
  expect(backButton, findsOneWidget);
  await tester.tap(backButton);
  await tester.pumpAndSettle();

  // Back on ProfileScreen.
  expect(find.text('Profile'), findsAtLeastNWidgets(1));
}

void main() {
  group('ProfileScreen menu navigation', () {
    testWidgets('tapping Personal Information navigates to PersonalInformationScreen',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();
      await _tapRowAndVerify(tester,
          rowLabel: 'Personal Information',
          expectedTitle: 'Personal Information');
    });

    testWidgets('tapping Verification Status navigates to VerificationStatusScreen',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();
      await _tapRowAndVerify(tester,
          rowLabel: 'Verification Status',
          expectedTitle: 'Verification Status');
    });

    testWidgets('tapping Notifications navigates to NotificationsScreen',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();
      await _tapRowAndVerify(tester,
          rowLabel: 'Notifications', expectedTitle: 'Notifications');
    });

    testWidgets('tapping Payment Methods navigates to PaymentMethodsScreen',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();
      await _tapRowAndVerify(tester,
          rowLabel: 'Payment Methods', expectedTitle: 'Payment Methods');
    });

    testWidgets('tapping Betting History navigates to BettingHistoryScreen',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();
      await _tapRowAndVerify(tester,
          rowLabel: 'Betting History', expectedTitle: 'Betting History');
    });

    testWidgets(
        'tapping Responsible Gambling navigates to ResponsibleGamblingScreen',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();
      await _tapRowAndVerify(tester,
          rowLabel: 'Responsible Gambling',
          expectedTitle: 'Responsible Gambling');
    });

    testWidgets('tapping Help & Support navigates to HelpSupportScreen',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();
      await _tapRowAndVerify(tester,
          rowLabel: 'Help & Support', expectedTitle: 'Help & Support');
    });

    testWidgets('tapping Settings navigates to SettingsScreen',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();
      await _tapRowAndVerify(tester,
          rowLabel: 'Settings', expectedTitle: 'Settings');
    });
  });
}
