import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../core/analytics.dart';
import '../../core/hive_init.dart';
import 'onboarding_steps.dart';

enum OnboardingStep {
  account,
  goals,
  level,
  schedule,
  notifications,
  microphoneLanguage,
}

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  int _index = 0;

  static const List<OnboardingStep> _steps = [
    OnboardingStep.account,
    OnboardingStep.goals,
    OnboardingStep.level,
    OnboardingStep.schedule,
    OnboardingStep.notifications,
    OnboardingStep.microphoneLanguage,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cache = ref.read(appCacheProvider);
      final savedIndex = cache.getPref<int>('onboard_step_index') ?? 0;
      if (savedIndex > 0 && savedIndex < _steps.length) {
        setState(() => _index = savedIndex);
        try {
          ref.read(appAnalyticsProvider).logOnboardingResume();
          ref.read(appAnalyticsProvider).logOnboardingStepView(step: _steps[_index].name, index: _index + 1);
        } catch (_) {}
      }
    });
  }

  Future<void> _persistIndex() async {
    try {
      await ref.read(appCacheProvider).setPref('onboard_step_index', _index);
    } catch (_) {}
  }

  bool _validateCurrent() {
    final messenger = ScaffoldMessenger.of(context);
    switch (_steps[_index]) {
      case OnboardingStep.goals:
        final goals = ref.read(onboardingGoalsProvider);
        if (goals.isEmpty) {
          messenger.showSnackBar(const SnackBar(content: Text('Please choose at least one goal')));
          return false;
        }
        return true;
      case OnboardingStep.level:
        final level = ref.read(onboardingLevelProvider);
        if (level == null) {
          messenger.showSnackBar(const SnackBar(content: Text('Please select your level')));
          return false;
        }
        return true;
      case OnboardingStep.schedule:
        final days = ref.read(onboardingDaysProvider);
        if (days.isEmpty) {
          messenger.showSnackBar(const SnackBar(content: Text('Pick at least one practice day')));
          return false;
        }
        return true;
      case OnboardingStep.account:
      case OnboardingStep.notifications:
      case OnboardingStep.microphoneLanguage:
        return true;
    }
  }

  void _next() {
    if (!_validateCurrent()) return;
    if (_index < _steps.length - 1) {
      setState(() => _index += 1);
      ref.read(appAnalyticsProvider).logOnboardingStepView(step: _steps[_index].name, index: _index + 1);
      _persistIndex();
    } else {
      // Completed onboarding: return to app home (later we will persist completion)
      if (!mounted) return;
      ref.read(appAnalyticsProvider).logOnboardingComplete();
      // Persist completion so onboarding doesn't show again
      ref.read(appCacheProvider).setPref('onboard_complete', true);
      ref.read(appCacheProvider).setPref('onboard_step_index', null);
      context.go('/');
    }
  }

  void _back() {
    if (_index > 0) {
      setState(() => _index -= 1);
      _persistIndex();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  String _titleFor(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.account:
        return 'Create Account or Sign In';
      case OnboardingStep.goals:
        return 'Choose Your Goals';
      case OnboardingStep.level:
        return 'Select Your Level';
      case OnboardingStep.schedule:
        return 'Pick a Practice Schedule';
      case OnboardingStep.notifications:
        return 'Enable Notifications';
      case OnboardingStep.microphoneLanguage:
        return 'Microphone & Language';
    }
  }

  Widget _bodyFor(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.account:
        return const AccountStepContent();
      case OnboardingStep.goals:
        return const GoalsStepContent();
      case OnboardingStep.level:
        return const LevelStepContent();
      case OnboardingStep.schedule:
        return const ScheduleStepContent();
      case OnboardingStep.notifications:
        return const NotificationsStepContent();
      case OnboardingStep.microphoneLanguage:
        return const MicrophoneStepContent();
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _titleFor(step),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: context.spacing.md),
            Text('Step ${_index + 1} of ${_steps.length} (placeholder).'),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Log start and current step view on first build
    ref.read(appAnalyticsProvider).logOnboardingStart();
    ref.read(appAnalyticsProvider).logOnboardingStepView(step: _steps[_index].name, index: _index + 1);
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: const Text('Onboarding'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
        actions: [
          if (_steps[_index] == OnboardingStep.notifications || _steps[_index] == OnboardingStep.microphoneLanguage)
            TextButton(
              onPressed: () {
                try { ref.read(appAnalyticsProvider).logOnboardingSkip(step: _steps[_index].name); } catch (_) {}
                _next();
              },
              child: const Text('Skip'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.lg),
          child: Column(
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_steps.length, (i) {
                  final active = i <= _index;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.symmetric(horizontal: i == 0 ? 0 : context.spacing.xs),
                      decoration: BoxDecoration(
                        color: active ? color.primary : color.surfaceContainerHighest,
                        borderRadius: context.radii.brSm,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: context.spacing.lg),
              // Body
              Expanded(child: _bodyFor(_steps[_index])),
              SizedBox(height: context.spacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _back,
                      child: const Text('Back'),
                    ),
                  ),
                  SizedBox(width: context.spacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(_index == _steps.length - 1 ? 'Finish' : 'Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


