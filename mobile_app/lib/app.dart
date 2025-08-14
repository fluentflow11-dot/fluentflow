import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'core/auth_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure token listener is active for app lifetime
    ref.watch(authTokenListenerProvider);
    final router = ref.watch(appRouterProvider);
    final seed = ref.watch(seedColorProvider);
    return MaterialApp.router(
      title: 'FluentFlow',
      theme: buildThemeFromSeed(seed, Brightness.light),
      darkTheme: buildThemeFromSeed(seed, Brightness.dark),
      routerConfig: router,
    );
  }
}


