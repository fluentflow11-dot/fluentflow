import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/hive_init.dart';

/// Lightweight models for home screen state
class DailyProgressState {
	DailyProgressState({required this.completedSteps, required this.totalSteps, required this.updatedIsoDate});

	final int completedSteps;
	final int totalSteps;
	final String updatedIsoDate; // yyyy-MM-dd local date string

	double get percent => totalSteps <= 0 ? 0.0 : (completedSteps.clamp(0, totalSteps) / totalSteps);
}

class StreakState {
	StreakState({required this.count, required this.lastActiveIsoDate});

	final int count;
	final String? lastActiveIsoDate; // yyyy-MM-dd local date string or null
}

/// Service responsible for reading/writing home data
class HomeService {
	HomeService(this._ref);

	final Ref _ref;
	static const String _kDailyProgressKey = 'daily_progress_v1'; // JSON map
	static const String _kStreakCountKey = 'streak_count_v1'; // int
	static const String _kStreakLastIsoKey = 'streak_last_iso_v1'; // String yyyy-MM-dd

	String _todayIso() => DateFormat('yyyy-MM-dd').format(DateTime.now());

	DailyProgressState readDailyProgress() {
		final cache = _ref.read(appCacheProvider);
		final raw = cache.readCache<String>(_kDailyProgressKey);
		if (raw == null) {
			return DailyProgressState(completedSteps: 0, totalSteps: 5, updatedIsoDate: _todayIso());
		}
		try {
			final map = jsonDecode(raw) as Map<String, dynamic>;
			final iso = map['iso'] as String? ?? _todayIso();
			final steps = map['completed'] as int? ?? 0;
			final total = map['total'] as int? ?? 5;
			// Reset if persisted date is from a previous day
			if (iso != _todayIso()) {
				return DailyProgressState(completedSteps: 0, totalSteps: total, updatedIsoDate: _todayIso());
			}
			return DailyProgressState(completedSteps: steps, totalSteps: total, updatedIsoDate: iso);
		} catch (_) {
			return DailyProgressState(completedSteps: 0, totalSteps: 5, updatedIsoDate: _todayIso());
		}
	}

	Future<DailyProgressState> incrementDailyProgress({int by = 1}) async {
		final current = readDailyProgress();
		final next = DailyProgressState(
			completedSteps: (current.completedSteps + by).clamp(0, current.totalSteps),
			totalSteps: current.totalSteps,
			updatedIsoDate: _todayIso(),
		);
		await _persistDailyProgress(next);
		return next;
	}

	Future<void> _persistDailyProgress(DailyProgressState state) async {
		final cache = _ref.read(appCacheProvider);
		final map = <String, dynamic>{
			'iso': state.updatedIsoDate,
			'completed': state.completedSteps,
			'total': state.totalSteps,
		};
		await cache.writeCache(_kDailyProgressKey, jsonEncode(map));
	}

	StreakState readStreak() {
		final cache = _ref.read(appCacheProvider);
		final count = cache.getPref<int>(_kStreakCountKey) ?? 0;
		final lastIso = cache.getPref<String>(_kStreakLastIsoKey);
		return StreakState(count: count, lastActiveIsoDate: lastIso);
	}

	Future<StreakState> recordDailyActivity() async {
		final cache = _ref.read(appCacheProvider);
		final lastIso = cache.getPref<String>(_kStreakLastIsoKey);
		final today = _todayIso();
		int nextCount;
		if (lastIso == null) {
			nextCount = 1;
		} else if (lastIso == today) {
			// Already recorded today; keep count
			nextCount = cache.getPref<int>(_kStreakCountKey) ?? 1;
		} else {
			// Compute day difference based on local dates
			final lastDate = DateTime.parse('${lastIso}T00:00:00');
			final todayDate = DateTime.parse('${today}T00:00:00');
			final diffDays = todayDate.difference(lastDate).inDays;
			if (diffDays == 1) {
				nextCount = (cache.getPref<int>(_kStreakCountKey) ?? 0) + 1;
			} else if (diffDays > 1) {
				nextCount = 1; // streak broken
			} else {
				// lastIso is after today (clock change) → keep existing
				nextCount = cache.getPref<int>(_kStreakCountKey) ?? 1;
			}
		}
		await cache.setPref(_kStreakCountKey, nextCount);
		await cache.setPref(_kStreakLastIsoKey, today);
		return StreakState(count: nextCount, lastActiveIsoDate: today);
	}
}

final homeServiceProvider = Provider<HomeService>((ref) => HomeService(ref));

class DailyProgressNotifier extends StateNotifier<DailyProgressState> {
	DailyProgressNotifier(this._ref) : super(_ref.read(homeServiceProvider).readDailyProgress());

	final Ref _ref;

	Future<void> increment({int by = 1}) async {
		state = await _ref.read(homeServiceProvider).incrementDailyProgress(by: by);
	}

	Future<void> refresh() async {
		state = _ref.read(homeServiceProvider).readDailyProgress();
	}
}

class StreakNotifier extends StateNotifier<StreakState> {
	StreakNotifier(this._ref) : super(_ref.read(homeServiceProvider).readStreak());

	final Ref _ref;

	Future<void> recordActivity() async {
		state = await _ref.read(homeServiceProvider).recordDailyActivity();
	}

	Future<void> refresh() async {
		state = _ref.read(homeServiceProvider).readStreak();
	}
}

final dailyProgressProvider = StateNotifierProvider<DailyProgressNotifier, DailyProgressState>((ref) => DailyProgressNotifier(ref));
final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>((ref) => StreakNotifier(ref));


