import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/auth/auth_screen.dart';
import 'auth_providers.dart';
import 'navigation_observer.dart';

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

  return GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/auth';
      final user = authChanges.asData?.value;

      if (user == null && !isAuthRoute) {
        return '/auth';
      }
      if (user != null && isAuthRoute) {
        return '/';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(ref.read(firebaseAuthProvider).authStateChanges()),
    observers: [CrashlyticsNavigationObserver()],
  );
});


