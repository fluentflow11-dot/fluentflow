import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fluentflow_app/firebase_options.dart' as firebase_options;

// This file attempts to initialize Firebase if firebase_options.dart is present.
// It safely no-ops if configuration is missing, so builds keep working.
Future<bool> initializeFirebaseIfAvailable() async {
	// 1) Try default platform resources (google-services.json on Android)
	try {
		await Firebase.initializeApp();
		if (kDebugMode) {
			// ignore: avoid_print
			print('[Firebase] Initialized (default resources)');
		}
		return true;
	} catch (_) {
		// Fall through to generated options
	}

	// 2) Try generated options if available
	try {
		final FirebaseOptions options = firebase_options.DefaultFirebaseOptions.currentPlatform;
		await Firebase.initializeApp(options: options);
		if (kDebugMode) {
			// ignore: avoid_print
			print('[Firebase] Initialized (generated options)');
		}
		return true;
	} catch (e) {
		if (kDebugMode) {
			// ignore: avoid_print
			print('[Firebase] Initialization skipped: $e');
		}
		return false;
	}
}

/// Initialize optional Firebase services used in development by this app.
Future<void> initializeFirebaseExtras() async {
  if (Firebase.apps.isEmpty) return;

  // App Check (debug provider for dev; switch to Play Integrity for prod)
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AppCheck] Activated (debug provider)');
    }
  } catch (e) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AppCheck] Activate error: $e');
    }
  }

  // Crashlytics
  try {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Crashlytics] Enabled');
    }
  } catch (e) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Crashlytics] Init error: $e');
    }
  }

  // Remote Config (fetch on startup with short interval for dev)
  try {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(seconds: 0),
    ));
    await rc.setDefaults(const {
      'welcome_message': 'Welcome to FluentFlow!',
    });
    await rc.fetchAndActivate();
    if (kDebugMode) {
      // ignore: avoid_print
      print('[RemoteConfig] Fetched and activated');
    }
  } catch (e) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[RemoteConfig] Init error: $e');
    }
  }
}


