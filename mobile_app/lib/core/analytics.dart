import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppAnalytics {
  AppAnalytics(this._analytics);
  final FirebaseAnalytics _analytics;

  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  Future<void> logPasswordResetRequest() async {
    await _analytics.logEvent(name: 'password_reset_request');
  }

  Future<void> logAuthError({required String code, String? message}) async {
    await _analytics.logEvent(name: 'auth_error', parameters: {
      'code': code,
      if (message != null && message.isNotEmpty) 'message': message,
    });
  }

  Future<void> logOnboardingStart() async {
    await _analytics.logEvent(name: 'onboarding_start');
  }

  Future<void> logOnboardingStepView({required String step, required int index}) async {
    await _analytics.logEvent(name: 'onboarding_step_view', parameters: {
      'step': step,
      'index': index,
    });
  }

  Future<void> logOnboardingComplete() async {
    await _analytics.logEvent(name: 'onboarding_complete');
  }

  Future<void> logOnboardingSkip({required String step}) async {
    await _analytics.logEvent(name: 'onboarding_skip', parameters: {
      'step': step,
    });
  }

  Future<void> logOnboardingResume() async {
    await _analytics.logEvent(name: 'onboarding_resume');
  }

  Future<void> logOnboardingStepDuration({required String step, required int durationMs}) async {
    await _analytics.logEvent(name: 'onboarding_step_duration', parameters: {
      'step': step,
      'duration_ms': durationMs,
    });
  }

  Future<void> logOnboardingTotalDuration({required int totalDurationMs, required int stepsSkipped}) async {
    await _analytics.logEvent(name: 'onboarding_total_duration', parameters: {
      'total_ms': totalDurationMs,
      'skipped': stepsSkipped,
    });
  }
}

final analyticsProvider = Provider<FirebaseAnalytics>((ref) => FirebaseAnalytics.instance);

final appAnalyticsProvider = Provider<AppAnalytics>((ref) {
  final fa = ref.watch(analyticsProvider);
  return AppAnalytics(fa);
});


