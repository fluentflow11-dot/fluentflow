import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String appPrefsBoxName = 'app_prefs';
const String cacheBoxName = 'cache';

Future<void> initializeHive() async {
  await Hive.initFlutter();
  // Open common boxes at startup so they're ready synchronously later.
  await Future.wait([
    Hive.openBox(appPrefsBoxName),
    Hive.openBox(cacheBoxName),
  ]);
  if (kDebugMode) {
    // ignore: avoid_print
    print('[Hive] Initialized and boxes opened');
  }
}

class AppCache {
  AppCache(this._cache, this._prefs);

  final Box _cache;
  final Box _prefs;

  Future<void> writeCache(String key, Object? value) async => _cache.put(key, value);
  T? readCache<T>(String key) => _cache.get(key) as T?;

  Future<void> setPref(String key, Object? value) async => _prefs.put(key, value);
  T? getPref<T>(String key) => _prefs.get(key) as T?;
}

final appCacheProvider = Provider<AppCache>((ref) {
  final cache = Hive.box(cacheBoxName);
  final prefs = Hive.box(appPrefsBoxName);
  return AppCache(cache, prefs);
});


