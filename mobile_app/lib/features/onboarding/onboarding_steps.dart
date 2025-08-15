import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../core/auth_providers.dart';
import '../../core/hive_init.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

// ----- Goals Step -----

final onboardingGoalsProvider = StateProvider<List<String>>((ref) {
  final cache = ref.read(appCacheProvider);
  final saved = (cache.getPref<List>('onboard_goals') as List?)?.cast<String>() ?? <String>[];
  return saved;
});

class GoalsStepContent extends ConsumerWidget {
  const GoalsStepContent({super.key});

  static const List<Map<String, String>> goals = [
    {'key': 'speaking', 'label': 'Speaking'},
    {'key': 'listening', 'label': 'Listening'},
    {'key': 'pronunciation', 'label': 'Pronunciation'},
    {'key': 'grammar', 'label': 'Grammar'},
    {'key': 'vocab', 'label': 'Vocabulary'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(onboardingGoalsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose your goals', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: context.spacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: goals.length,
            separatorBuilder: (_, __) => SizedBox(height: context.spacing.sm),
            itemBuilder: (context, index) {
              final g = goals[index];
              final isSelected = selections.contains(g['key']);
              final scheme = Theme.of(context).colorScheme;
              final cardColor = isSelected ? scheme.primaryContainer : scheme.surfaceContainerLowest;
              final borderColor = isSelected ? scheme.primary : scheme.outlineVariant;
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(RadiusTheme().md),
                child: InkWell(
                onTap: () async {
                  final next = [...selections];
                  if (isSelected) {
                    next.remove(g['key']);
                  } else {
                    if (!next.contains(g['key'])) next.add(g['key']!);
                  }
                  ref.read(onboardingGoalsProvider.notifier).state = next;
                  await ref.read(appCacheProvider).setPref('onboard_goals', next);
                },
                  borderRadius: BorderRadius.all(RadiusTheme().md),
                  child: Container(
                    padding: EdgeInsets.all(context.spacing.md),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.all(RadiusTheme().md),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Text(
                      g['label']!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ----- Level Step -----

final onboardingLevelProvider = StateProvider<String?>((ref) {
  final cache = ref.read(appCacheProvider);
  return cache.getPref<String>('onboard_level');
});

class LevelStepContent extends ConsumerWidget {
  const LevelStepContent({super.key});

  static const List<Map<String, String>> levels = [
    {'key': 'beginner', 'label': 'Beginner'},
    {'key': 'intermediate', 'label': 'Intermediate'},
    {'key': 'advanced', 'label': 'Advanced'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(onboardingLevelProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select your level', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: context.spacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: levels.length,
            separatorBuilder: (_, __) => SizedBox(height: context.spacing.sm),
            itemBuilder: (context, index) {
              final l = levels[index];
              final isSelected = level == l['key'];
              final scheme = Theme.of(context).colorScheme;
              final cardColor = isSelected ? scheme.primaryContainer : scheme.surfaceContainerLowest;
              final borderColor = isSelected ? scheme.primary : scheme.outlineVariant;
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(RadiusTheme().md),
                child: InkWell(
                  onTap: () async {
                    ref.read(onboardingLevelProvider.notifier).state = l['key'];
                    await ref.read(appCacheProvider).setPref('onboard_level', l['key']);
                  },
                  borderRadius: BorderRadius.all(RadiusTheme().md),
                  child: Container(
                    padding: EdgeInsets.all(context.spacing.md),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.all(RadiusTheme().md),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Text(
                      l['label']!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ----- Schedule Step -----

final onboardingDaysProvider = StateProvider<List<String>>((ref) {
  final cache = ref.read(appCacheProvider);
  final saved = (cache.getPref<List>('onboard_days') as List?)?.cast<String>() ?? <String>[];
  return saved;
});

final onboardingTimeMinutesProvider = StateProvider<int>((ref) {
  final cache = ref.read(appCacheProvider);
  final saved = ref.read(appCacheProvider).getPref<int>('onboard_time_minutes');
  return saved ?? (18 * 60); // default 18:00
});

class ScheduleStepContent extends ConsumerWidget {
  const ScheduleStepContent({super.key});

  static const List<Map<String, String>> days = [
    {'key': 'mon', 'label': 'Monday'},
    {'key': 'tue', 'label': 'Tuesday'},
    {'key': 'wed', 'label': 'Wednesday'},
    {'key': 'thu', 'label': 'Thursday'},
    {'key': 'fri', 'label': 'Friday'},
    {'key': 'sat', 'label': 'Saturday'},
    {'key': 'sun', 'label': 'Sunday'},
  ];

  String _formatTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(onboardingDaysProvider);
    final timeMinutes = ref.watch(onboardingTimeMinutesProvider);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick your practice days', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: context.spacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: days.length + 1,
            separatorBuilder: (_, __) => SizedBox(height: context.spacing.sm),
            itemBuilder: (context, index) {
              if (index == days.length) {
                // Time picker panel
                final cardColor = scheme.surfaceContainerLowest;
                final borderColor = scheme.outlineVariant;
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(RadiusTheme().md),
                  child: InkWell(
                    onTap: () async {
                      final initial = TimeOfDay(hour: timeMinutes ~/ 60, minute: timeMinutes % 60);
                      final picked = await showTimePicker(context: context, initialTime: initial);
                      if (picked != null) {
                        final minutes = picked.hour * 60 + picked.minute;
                        ref.read(onboardingTimeMinutesProvider.notifier).state = minutes;
                        await ref.read(appCacheProvider).setPref('onboard_time_minutes', minutes);
                      }
                    },
                    borderRadius: BorderRadius.all(RadiusTheme().md),
                    child: Container(
                      padding: EdgeInsets.all(context.spacing.md),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.all(RadiusTheme().md),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Preferred time', style: Theme.of(context).textTheme.titleMedium),
                          Text(_formatTime(timeMinutes), style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final d = days[index];
              final isSelected = selections.contains(d['key']);
              final cardColor = isSelected ? scheme.primaryContainer : scheme.surfaceContainerLowest;
              final borderColor = isSelected ? scheme.primary : scheme.outlineVariant;
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(RadiusTheme().md),
                child: InkWell(
                  onTap: () async {
                    final next = [...selections];
                    if (isSelected) {
                      next.remove(d['key']);
                    } else {
                      if (!next.contains(d['key'])) next.add(d['key']!);
                    }
                    ref.read(onboardingDaysProvider.notifier).state = next;
                    await ref.read(appCacheProvider).setPref('onboard_days', next);
                  },
                  borderRadius: BorderRadius.all(RadiusTheme().md),
                  child: Container(
                    padding: EdgeInsets.all(context.spacing.md),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.all(RadiusTheme().md),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Text(
                      d['label']!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ----- Permissions Steps -----

final onboardingNotificationsGrantedProvider = StateProvider<bool>((ref) {
  final cache = ref.read(appCacheProvider);
  return cache.getPref<bool>('onboard_notifications') ?? false;
});

class NotificationsStepContent extends ConsumerWidget {
  const NotificationsStepContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final granted = ref.watch(onboardingNotificationsGrantedProvider);
    final scheme = Theme.of(context).colorScheme;
    final cardColor = granted ? scheme.primaryContainer : scheme.surfaceContainerLowest;
    final borderColor = granted ? scheme.primary : scheme.outlineVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enable notifications', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: context.spacing.md),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(RadiusTheme().md),
          child: InkWell(
            onTap: () async {
              try {
                final settings = await FirebaseMessaging.instance.requestPermission();
                final ok = settings.authorizationStatus == AuthorizationStatus.authorized ||
                    settings.authorizationStatus == AuthorizationStatus.provisional;
                ref.read(onboardingNotificationsGrantedProvider.notifier).state = ok;
                await ref.read(appCacheProvider).setPref('onboard_notifications', ok);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications disabled. You can enable them later in Settings.')),
                  );
                }
              } catch (_) {}
            },
            borderRadius: BorderRadius.all(RadiusTheme().md),
            child: Container(
              padding: EdgeInsets.all(context.spacing.md),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.all(RadiusTheme().md),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
                  Icon(granted ? Icons.check_circle : Icons.notifications_outlined,
                      color: granted ? scheme.primary : scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final onboardingMicrophoneAllowedProvider = StateProvider<bool>((ref) {
  final cache = ref.read(appCacheProvider);
  return cache.getPref<bool>('onboard_microphone') ?? false;
});

// ----- Language Step -----

final onboardingLanguageProvider = StateProvider<String?>((ref) {
  final cache = ref.read(appCacheProvider);
  return cache.getPref<String>('onboard_language');
});

class LanguageStepContent extends ConsumerStatefulWidget {
  const LanguageStepContent({super.key});

  @override
  ConsumerState<LanguageStepContent> createState() => _LanguageStepContentState();
}

class _LanguageStepContentState extends ConsumerState<LanguageStepContent> {
  String _query = '';

  static const List<Map<String, String>> langs = [
    {'code': 'en', 'label': 'English'},
    {'code': 'es', 'label': 'Spanish'},
    {'code': 'ar', 'label': 'Arabic'},
    {'code': 'fr', 'label': 'French'},
    {'code': 'de', 'label': 'German'},
    {'code': 'pt', 'label': 'Portuguese'},
    {'code': 'hi', 'label': 'Hindi'},
    {'code': 'zh', 'label': 'Chinese'},
    {'code': 'ja', 'label': 'Japanese'},
    {'code': 'ko', 'label': 'Korean'},
  ];

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(onboardingLanguageProvider);
    final filtered = langs
        .where((l) => _query.isEmpty || l['label']!.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose your language', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: context.spacing.md),
        TextField(
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search languages'),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
        SizedBox(height: context.spacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => SizedBox(height: context.spacing.xs),
            itemBuilder: (context, index) {
              final lang = filtered[index];
              final isSelected = selected == lang['code'];
              final cardColor = isSelected ? scheme.primaryContainer : scheme.surfaceContainerLowest;
              final borderColor = isSelected ? scheme.primary : scheme.outlineVariant;
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(RadiusTheme().md),
                child: InkWell(
                  onTap: () async {
                    ref.read(onboardingLanguageProvider.notifier).state = lang['code'];
                    await ref.read(appCacheProvider).setPref('onboard_language', lang['code']);
                  },
                  borderRadius: BorderRadius.all(RadiusTheme().md),
                  child: Container(
                    padding: EdgeInsets.all(context.spacing.md),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.all(RadiusTheme().md),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(lang['label']!, style: Theme.of(context).textTheme.titleMedium),
                        if (isSelected) Icon(Icons.check_circle, color: scheme.primary),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MicrophoneStepContent extends ConsumerWidget {
  const MicrophoneStepContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(onboardingMicrophoneAllowedProvider);
    final scheme = Theme.of(context).colorScheme;
    final cardColor = allowed ? scheme.primaryContainer : scheme.surfaceContainerLowest;
    final borderColor = allowed ? scheme.primary : scheme.outlineVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Microphone access', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: context.spacing.md),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(RadiusTheme().md),
          child: InkWell(
            onTap: () async {
              try {
                final status = await Permission.microphone.request();
                final ok = status.isGranted;
                ref.read(onboardingMicrophoneAllowedProvider.notifier).state = ok;
                await ref.read(appCacheProvider).setPref('onboard_microphone', ok);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Microphone permission denied. You can enable it later in Settings.')),
                  );
                }
              } catch (_) {}
            },
            borderRadius: BorderRadius.all(RadiusTheme().md),
            child: Container(
              padding: EdgeInsets.all(context.spacing.md),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.all(RadiusTheme().md),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Microphone access', style: Theme.of(context).textTheme.titleMedium),
                  Icon(allowed ? Icons.check_circle : Icons.mic_none,
                      color: allowed ? scheme.primary : scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AccountStepContent extends ConsumerWidget {
  const AccountStepContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authChanges = ref.watch(authStateChangesProvider);
    final user = authChanges.asData?.value;
    final signedIn = user != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          signedIn ? 'You are signed in' : 'Sign in to continue',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: context.spacing.sm),
        if (signedIn)
          Text(user!.isAnonymous ? 'Guest session' : (user.email ?? user.uid)),
        if (!signedIn) ...[
          Text(
            'Create an account or sign in with your email or Google to save progress.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: context.spacing.md),
          FilledButton.icon(
            onPressed: () => context.push('/auth'),
            icon: const Icon(Icons.login),
            label: const Text('Sign in / Create account'),
          ),
        ],
      ],
    );
  }
}


