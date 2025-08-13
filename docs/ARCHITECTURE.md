# FluentFlow Architecture

## Overview
- Flutter app in `mobile_app/` with feature-first structure
- Core stack: Riverpod, go_router, Firebase (Auth, Firestore, Storage, Remote Config, Crashlytics, App Check), Hive

## Structure
- `lib/app.dart`: App root, provides `routerConfig`
- `lib/core/`
  - `router.dart`: `GoRouter` with auth-aware redirects
  - `firebase_init.dart`: Firebase init + App Check, Crashlytics, Remote Config
  - `hive_init.dart`: Hive init and `AppCache` wrapper
  - `auth_providers.dart`: Riverpod providers for `FirebaseAuth` and `AuthService`
  - `logger.dart`: Central logger integrated with Crashlytics
  - `navigation_observer.dart`: Logs route changes to Crashlytics
  - `theme.dart`, `design_tokens.dart`: Material 3 themes and tokens
- `lib/features/`
  - `auth/auth_screen.dart`: Email/Password + Anonymous auth UI
  - `home/home_screen.dart`: Debug UI, Firebase/Hive smoke tests

## Navigation
- go_router with guarded routes:
  - `/auth` when unauthenticated
  - `/` when authenticated
- Crashlytics breadcrumbs via `CrashlyticsNavigationObserver`

## State Management
- Riverpod 2.x providers
  - `authStateChangesProvider` streams `User?`
  - `appCacheProvider` exposes Hive-backed cache/prefs access

## Data
- Firestore debug doc writes in `HomeScreen`
- Storage sample upload/download helpers in `storage_debug.dart`
- Hive boxes `app_prefs`, `cache` opened on startup

## Error Handling & Logging
- Global `runZonedGuarded` in `main.dart`
- `ErrorWidget.builder` friendly fallback
- Crashlytics fatal/non-fatal logging via `AppLogger`

## CI
- GitHub Actions: analyze, test, build APK (debug) on push/PR

## Testing
- Widget test renders app with test router override (no Firebase requirement)


