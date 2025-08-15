import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import 'auth_providers.dart';
import 'navigation_observer.dart';
import '../features/profile/profile_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/auth/age_gate_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_init.dart';
import '../features/onboarding/intro_screen.dart';
import '../features/onboarding/wizard_screen.dart';
import '../features/lesson/lesson_overview_screen.dart';
import '../features/lesson/lesson_player_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authChanges = ref.watch(authStateChangesProvider);

  // Preload any cached token best-effort (optional; can be used for diagnostics or future needs)
  // This runs once when the provider is built; errors ignored.
  (() async {
    try {
      const storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
      await storage.read(key: 'ff_id_token');
    } catch (_) {}
  })();

  return GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/lesson-overview',
        name: 'lesson-overview',
        builder: (context, state) => const LessonOverviewScreen(),
      ),
      GoRoute(
        path: '/lesson',
        name: 'lesson',
        builder: (context, state) => const LessonPlayerScreen(),
      ),
      GoRoute(
        path: '/onboarding-intro',
        name: 'onboarding-intro',
        builder: (context, state) => const OnboardingIntroScreen(),
      ),
      GoRoute(
        path: '/onboarding-wizard',
        name: 'onboarding-wizard',
        builder: (context, state) => const OnboardingWizardScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/age-gate',
        name: 'age-gate',
        builder: (context, state) => const AgeGateScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/auth';
      final isAgeGateRoute = state.matchedLocation == '/age-gate';
      final isForgotRoute = state.matchedLocation == '/forgot-password';
      final isProfileRoute = state.matchedLocation == '/profile';
      final user = authChanges.asData?.value;
      // Simple local checks using Hive prefs
      final prefsBox = Hive.box(appPrefsBoxName);
      final ageGateVerified = prefsBox.get('age_gate_verified') == true;
      final onboardingComplete = prefsBox.get('onboard_complete') == true;

      if (!isAgeGateRoute && !ageGateVerified) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[router] redirect → /age-gate (ageGateVerified=false, from=${state.matchedLocation})');
        }
        return '/age-gate';
      }

      // While onboarding is incomplete, allow navigating to onboarding routes and auth/forgot pages; redirect all else to intro
      if (
        ageGateVerified &&
        !onboardingComplete &&
        state.matchedLocation != '/onboarding-intro' &&
        state.matchedLocation != '/onboarding-wizard' &&
        state.matchedLocation != '/auth' &&
        state.matchedLocation != '/forgot-password'
      ) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[router] redirect → /onboarding-intro (onboarding incomplete, from=${state.matchedLocation})');
        }
        return '/onboarding-intro';
      }

      if (user == null && !isAuthRoute && !isForgotRoute && ageGateVerified && onboardingComplete) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[router] redirect → /auth (signed out, onboarding complete)');
        }
        return '/auth';
      }
      if (user != null && isAuthRoute) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[router] redirect → / (already signed in, trying to visit /auth)');
        }
        return '/';
      }
      // If user is newly signed-in, allow navigating to /profile manually after first login.
      if (user != null && isProfileRoute) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[router] redirect → / (prevent direct /profile)');
        }
        return '/';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(ref.read(firebaseAuthProvider).authStateChanges()),
    observers: [CrashlyticsNavigationObserver()],
  );
});


