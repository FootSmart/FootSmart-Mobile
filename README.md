<p align="center">
  <img src="assets/icons/app_icon.png" width="100" alt="FootSmart Pro Logo"/>
</p>

<h1 align="center">FootSmart Pro</h1>

<p align="center">
  <strong>AI-Powered Football Betting & Coaching Platform</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.27-blue?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green" alt="Platform"/>
  <img src="https://img.shields.io/badge/Status-In%20Development-orange" alt="Status"/>
  <img src="https://img.shields.io/badge/License-Proprietary-red" alt="License"/>
</p>

---

## Overview

**FootSmart Pro** is a modern mobile app that combines **football betting intelligence** with **AI-powered coaching tools**. Two distinct experiences in one app — designed for bettors who want smarter insights and coaches who want a competitive edge.

### Bettor Experience
> Analyze matches, track risk, place smart bets, and climb the leaderboard.

### Coach Experience
> Manage tactics, scout opponents with AI, simulate match scenarios, and broadcast to your squad.

---

## Features

### Bettor Mode

| Feature | Description |
|---|---|
| **Risk Meter** | Visual risk assessment before placing bets |
| **Live Odds** | Real-time odds from multiple leagues |
| **Match Analytics** | Deep stats on teams, players, and form |
| **Smart Wallet** | Deposit, withdraw, track betting history |
| **Leaderboard** | Compete with other predictors |

### Coach Mode

| Feature | Description |
|---|---|
| **War Room** | AI daily briefing, team mood ring, next match countdown |
| **Tactics Board** | Interactive pitch with drag & drop formations (6 presets) |
| **Opponent X-Ray** | AI-powered opponent analysis with danger zones & counter-strategies |
| **What-If Room** | Replay past matches — change one decision, see simulated outcomes |
| **Perfect Player** | Build dream player profile with radar chart & find closest squad match |
| **Live Console** | Real-time match co-pilot with AI suggestions & event timeline |
| **Squad Broadcast** | One-way messaging to players with reactions & scheduled messages |

---

## Screenshots

> *Coming soon — app is in active development.*

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.27+ (Material 3) |
| **Language** | Dart 3.0+ |
| **State Management** | Provider |
| **Networking** | Dio, HTTP |
| **Storage** | SharedPreferences, Hive |
| **UI** | Google Fonts (Poppins/Inter), Flutter SVG, Shimmer, Lottie |
| **Charts** | fl_chart, Syncfusion Flutter Charts, Custom `CustomPainter` |
| **Auth** | JWT-based (NestJS backend) |
| **Backend** | NestJS + PostgreSQL ([separate repo](../footsmart-backend)) |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/       # Colors, text styles, API endpoints, strings
│   ├── extensions/      # ThemeContext extension for theme-aware colors
│   ├── models/          # User, Match, League data models
│   ├── routes/          # Named route definitions
│   └── services/        # API, Auth, Theme, League, Match services
├── features/
│   ├── auth/            # Sign in, Sign up, Forgot password
│   ├── betting/         # Betting interface
│   ├── coach/
│   │   ├── screens/     # 7 coach screens (War Room → Broadcast)
│   │   └── widgets/     # Coach bottom nav bar
│   ├── explore/         # Competition & player hubs
│   ├── home/            # Bettor home dashboard
│   ├── match/           # Match detail view
│   ├── onboarding/      # 3-step onboarding flow
│   ├── profile/         # User profile & settings
│   ├── splash/          # Animated splash screen
│   └── wallet/          # Deposit, withdraw, history
├── widgets/             # Shared widgets (nav bar, buttons, text fields)
└── main.dart            # App entry point
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.27.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter plugins
- Android device or emulator (iOS requires Mac + Xcode)

### Install & Run

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/scfoot_smart.git
cd scfoot_smart

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
```

### Quick Test — Coach Mode

Use the static coach login (no backend needed):

```
Email:    coach@coach.com
Password: coachcoach
```

---

## Design System

| Token | Dark Mode | Light Mode |
|---|---|---|
| **Background** | `#0B1220` (Navy) | `#F5F5F5` |
| **Bettor Accent** | `#00FF88` (Electric Green) | `#00CC6A` |
| **Coach Accent** | `#FF7A00` (Orange) | `#FF7A00` |
| **Font** | Poppins (UI), Inter (Stats) | Same |
| **Border Radius** | 12px consistent | Same |

---

## Performance Optimizations

- `ValueNotifier` + `ValueListenableBuilder` for high-frequency updates (drag, sliders)
- `RepaintBoundary` on CustomPainter widgets
- `listEquals` for proper `shouldRepaint` comparison
- Reduced `BoxShadow` blur radius for low-end device compatibility
- `Completer` pattern instead of polling loops
- `dart:math` native trig functions instead of Taylor series approximation

---

## Roadmap

- [x] Bettor UI (Home, Explore, Betting, Wallet, Profile)
- [x] Coach UI (7 screens — War Room to Broadcast)
- [x] Role-based auth routing (Bettor vs Coach)
- [x] Performance optimization for mid-range devices
- [ ] Connect to NestJS backend API
- [ ] Real-time match data integration
- [ ] AI model integration (n8n workflows)
- [ ] Push notifications
- [ ] App Store & Play Store deployment

---

## Backend

The NestJS backend lives in [`../footsmart-backend`](../footsmart-backend) and provides:

- JWT authentication (login, register, password reset)
- League & match data (scraped from football APIs)
- Betting & predictions engine
- Wallet transactions
- Analytics dashboard

---

## Contributing

This is a private project. Contact the maintainer for access.

---

## License

Proprietary — All rights reserved.

---

<p align="center">
  <sub>Built with Flutter & Dart | 18+ Responsible Gaming</sub>
</p>
