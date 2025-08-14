import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/firebase_init.dart';
import 'core/hive_init.dart';
import 'core/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Friendly error UI for build-time exceptions
  ErrorWidget.builder = (FlutterErrorDetails details) {
    appLogger.error('Build error', error: details.exception, stackTrace: details.stack);
    return const Material(
      child: Center(child: Text('Something went wrong. Please restart the app.')),
    );
  };

  await initializeFirebaseIfAvailable();
  await initializeFirebaseExtras();
  await initializeHive();

  // Debug: show current user to verify session persistence on cold start
  // ignore: avoid_print
  print('[Auth] currentUser: \'${FirebaseAuth.instance.currentUser?.uid ?? 'null'}\'');

  runApp(const ProviderScope(child: App()));
}
