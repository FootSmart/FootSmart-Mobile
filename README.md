# FootSmart Pro

A Flutter mobile app prototype for football betting insights, risk awareness, and user onboarding.

`FootSmart Pro` focuses on a dark, modern UI with core journey screens already wired: splash -> onboarding -> auth -> home.

## Highlights

- Animated splash experience with branded logo and progress indicator.
- 3-step onboarding focused on analytics, security, and responsible gaming.
- Sign up / sign in forms with basic validation and navigation.
- Home dashboard with:
  - Risk meter card.
  - Featured matches and odds blocks.
  - Trending bets section.
  - Top predictors leaderboard preview.
- Reusable design system foundations (`AppColors`, `AppTextStyles`, `AppStrings`).

## Current Scope

This repository is currently a **UI-first prototype**.

- Authentication is mocked (sign-in uses delayed navigation).
- Real APIs, persistence flows, wallet operations, and live betting logic are not connected yet.
- Several feature screens exist in the codebase for future expansion, but only the main route flow is currently wired in `AppRoutes`.

## Tech Stack

- Flutter (Material 3, dark theme)
- Dart SDK `>=3.0.0 <4.0.0`
- Key packages already included:
  - UI: `google_fonts`, `flutter_svg`, `shimmer`, `lottie`, `animations`
  - State: `provider`
  - Network: `http`, `dio`
  - Storage: `shared_preferences`, `hive`, `hive_flutter`
  - Media & Charts: `image_picker`, `cached_network_image`, `fl_chart`, `syncfusion_flutter_charts`
  - Utilities: `intl`, `uuid`, `local_auth`, `qr_flutter`

## Project Structure

```text
lib/
  core/
    constants/
    routes/
    utils/
  features/
    splash/
    onboarding/
    auth/
    home/
    analytics/
    betting/
    wallet/
    profile/
    match/
    kyc/
    leaderboard/
  widgets/
  main.dart
```

## Getting Started

### 1. Prerequisites

- Flutter SDK installed
- Dart SDK (comes with Flutter)
- Android Studio / VS Code + Flutter plugins
- At least one configured device or emulator

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

### 4. Useful commands

```bash
flutter analyze
flutter test
```

## Routing Flow (Current)

The app starts at `SplashScreen` and then moves through:

1. `/` -> Splash
2. `/onboarding` -> Onboarding
3. `/sign-up` or `/sign-in` -> Auth
4. `/home` -> Home dashboard

Defined in `lib/core/routes/app_routes.dart`.

## Notes

- App orientation is locked to portrait.
- Theme is configured as dark by default.
- Target audience is 18+; responsible gambling messaging is included in the UX copy.

## Next Steps

- Connect authentication to backend services.
- Wire feature modules into bottom navigation and route map.
- Add state management architecture for live data.
- Integrate API clients and local caching strategy.
- Add widget and integration tests for critical flows.

## License

No license file is currently defined in this repository.
