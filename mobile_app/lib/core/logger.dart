import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';

class AppLogger {
  bool get _crashlyticsAvailable => Firebase.apps.isNotEmpty;

  void debug(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
    _log(message);
  }

  void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
    _log(message);
  }

  void warn(String message) {
    if (kDebugMode) {
      debugPrint('[WARN] $message');
    }
    _log('WARN: $message');
  }

  Future<void> error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('  error: $error');
      if (stackTrace != null) debugPrint('  stack: $stackTrace');
      if (context.isNotEmpty) debugPrint('  context: $context');
    }
    _log('ERROR: $message');
    if (_crashlyticsAvailable) {
      final crashlytics = FirebaseCrashlytics.instance;
      // Attach context as custom keys (best-effort).
      for (final entry in context.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value is String) {
          await crashlytics.setCustomKey(key, value);
        } else if (value is int) {
          await crashlytics.setCustomKey(key, value);
        } else if (value is double) {
          await crashlytics.setCustomKey(key, value);
        } else if (value is bool) {
          await crashlytics.setCustomKey(key, value);
        } else if (value != null) {
          await crashlytics.setCustomKey(key, value.toString());
        }
      }
      // Record the error if provided; otherwise log the message as a breadcrumb.
      if (error != null) {
        await crashlytics.recordError(error, stackTrace, reason: message, fatal: fatal);
      } else {
        crashlytics.log(message);
      }
    }
  }

  void _log(String message) {
    if (_crashlyticsAvailable) {
      FirebaseCrashlytics.instance.log(message);
    }
  }
}

final AppLogger appLogger = AppLogger();


