import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';

class CrashlyticsNavigationObserver extends NavigatorObserver {
  bool get _enabled => Firebase.apps.isNotEmpty;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('didPush', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('didPop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log('didReplace', newRoute, oldRoute);
  }

  void _log(String action, Route<dynamic>? route, Route<dynamic>? previousRoute) {
    final currentName = route?.settings.name ?? route?.settings.toString() ?? 'unknown';
    final previousName = previousRoute?.settings.name ?? previousRoute?.settings.toString() ?? 'unknown';
    final msg = '[nav] $action → current=$currentName, previous=$previousName';
    if (_enabled) {
      FirebaseCrashlytics.instance.log(msg);
    }
  }
}


