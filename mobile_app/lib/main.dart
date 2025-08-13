import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/firebase_init.dart';
import 'core/hive_init.dart';
import 'core/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Friendly error UI for build-time exceptions
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Keep minimal to avoid recursion; log details and show a simple fallback
    appLogger.error('Build error', error: details.exception, stackTrace: details.stack);
    return const Material(
      child: Center(child: Text('Something went wrong. Please restart the app.')),
    );
  };

  await initializeFirebaseIfAvailable();
  await initializeFirebaseExtras();
  await initializeHive();

  runZonedGuarded(() {
    runApp(const ProviderScope(child: App()));
  }, (Object error, StackTrace stack) async {
    await appLogger.error('Uncaught zone error', error: error, stackTrace: stack, fatal: true);
  });
}
