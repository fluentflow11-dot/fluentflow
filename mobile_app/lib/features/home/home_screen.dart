import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/design_tokens.dart';
import '../../core/hive_init.dart';
import '../../core/auth_providers.dart';
import '../../core/analytics.dart';
import '../../core/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/storage_debug.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:go_router/go_router.dart';
import '../onboarding/onboarding_steps.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FluentFlow'),
        actions: [
          Consumer(builder: (context, ref, _) {
            final auth = ref.watch(authServiceProvider);
            final analytics = ref.watch(appAnalyticsProvider);
            return IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign out?'),
                    content: const Text('You will need to sign in again to continue.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sign out')),
                    ],
                  ),
                );
                if (confirmed != true) return;
                try {
                  await auth.signOut();
                  await analytics.logLogout();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-out error: $e')));
                }
              },
            );
          })
        ],
      ),
      body: kDebugMode
          ? SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.spacing.lg,
                  context.spacing.lg,
                  context.spacing.lg,
                  context.spacing.lg + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session status
                    Builder(builder: (context) {
                      final user = FirebaseAuth.instance.currentUser;
                      final label = user == null
                          ? 'Not signed in'
                          : (user.isAnonymous ? 'Signed in (guest)' : 'Signed in as ${user.email ?? user.uid}');
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(context.spacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          borderRadius: context.radii.brMd,
                        ),
                        child: Text(label),
                      );
                    }),
                    SizedBox(height: context.spacing.lg),
                    Text('Theme Preview', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: context.spacing.md),
                    _InteractiveSwatches(),
                    SizedBox(height: context.spacing.lg),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Elevated Button'),
                    ),
                    SizedBox(height: context.spacing.sm),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Outlined Button'),
                    ),
                    SizedBox(height: context.spacing.sm),
                    const TextField(decoration: InputDecoration(labelText: 'Input')),
                    SizedBox(height: context.spacing.md),
                    // Remote Config sample display
                    Builder(builder: (context) {
                      final welcome = FirebaseRemoteConfig.instance.getString('welcome_message');
                      return Text('RC welcome_message: ${welcome.isEmpty ? '(empty)' : welcome}');
                    }),
                    SizedBox(height: context.spacing.lg),
                    FilledButton.icon(
                      onPressed: () async {
                        if (!kDebugMode) return;
                        final scaffold = ScaffoldMessenger.of(context);
                        try {
                          final now = DateTime.now().toIso8601String();
                          await FirebaseFirestore.instance.collection('debug').doc('ping').set({'at': now});
                          final snap = await FirebaseFirestore.instance.collection('debug').doc('ping').get();
                          scaffold.showSnackBar(
                            SnackBar(content: Text('Firestore OK: ${snap.data()}')),
                          );
                        } catch (e) {
                          scaffold.showSnackBar(
                            SnackBar(content: Text('Firestore error: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.cloud_done),
                      label: const Text('Debug: Test Firestore'),
                    ),
                    SizedBox(height: context.spacing.md),
                    FilledButton.icon(
                      onPressed: () async {
                        if (!kDebugMode) return;
                        await FirebaseCrashlytics.instance.recordError('Test non-fatal error', StackTrace.current, reason: 'debug-button');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Non-fatal logged to Crashlytics')));
                      },
                      icon: const Icon(Icons.error_outline),
                      label: const Text('Debug: Log non-fatal'),
                    ),
                    SizedBox(height: context.spacing.md),
                    FilledButton.icon(
                      onPressed: () {
                        if (!kDebugMode) return;
                        // Intentionally throw to crash the app to verify fatal reporting.
                        throw StateError('Intentional crash (debug button)');
                      },
                      icon: const Icon(Icons.warning_amber),
                      label: const Text('Debug: Crash app (fatal)'),
                    ),
                    SizedBox(height: context.spacing.md),
                    FilledButton.icon(
                      onPressed: () async {
                        if (!kDebugMode) return;
                        final scaffold = ScaffoldMessenger.of(context);
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            scaffold.showSnackBar(const SnackBar(content: Text('No user; sign in first')));
                            return;
                          }
                          final path = await storageDebug.uploadHello(user);
                          scaffold.showSnackBar(SnackBar(content: Text('Storage upload OK: $path')));
                        } catch (e) {
                          scaffold.showSnackBar(SnackBar(content: Text('Storage upload error: $e')));
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Debug: Upload to Storage'),
                    ),
                    SizedBox(height: context.spacing.md),
                    FilledButton.icon(
                      onPressed: () async {
                        if (!kDebugMode) return;
                        final scaffold = ScaffoldMessenger.of(context);
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            scaffold.showSnackBar(const SnackBar(content: Text('No user; sign in first')));
                            return;
                          }
                          final text = await storageDebug.downloadHello(user);
                          scaffold.showSnackBar(SnackBar(content: Text(text.isEmpty ? 'No file yet' : 'Downloaded: $text')));
                        } catch (e) {
                          scaffold.showSnackBar(SnackBar(content: Text('Storage download error: $e')));
                        }
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Debug: Download from Storage'),
                    ),
                    SizedBox(height: context.spacing.md),
                    // Verify users/{uid} read/write with current auth
                    FilledButton.icon(
                      onPressed: () async {
                        if (!kDebugMode) return;
                        final scaffold = ScaffoldMessenger.of(context);
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            scaffold.showSnackBar(const SnackBar(content: Text('No user; sign in first')));
                            return;
                          }
                          final uid = user.uid;
                          final now = DateTime.now().toIso8601String();
                          await FirebaseFirestore.instance.collection('users').doc(uid).set({
                            'uid': uid,
                            'lastDebugWrite': now,
                          }, SetOptions(merge: true));
                          final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                          scaffold.showSnackBar(SnackBar(content: Text('users/$uid OK: ${snap.data()}')));
                        } catch (e) {
                          scaffold.showSnackBar(SnackBar(content: Text('users/{uid} error: $e')));
                        }
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('Debug: Test users/{uid} read/write'),
                    ),
                    SizedBox(height: context.spacing.md),
                    // Reset age gate and show it again
                    FilledButton.icon(
                      onPressed: () async {
                        if (!kDebugMode) return;
                        final cache = ref.read(appCacheProvider);
                        await cache.setPref('age_gate_verified', false);
                        await cache.setPref('birthdate_millis', null);
                        if (!context.mounted) return;
                        context.go('/age-gate');
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Debug: Reset age gate'),
                    ),
                    SizedBox(height: context.spacing.md),
                    // Open onboarding intro screen
                    FilledButton.icon(
                      onPressed: () {
                        if (!kDebugMode) return;
                        context.go('/onboarding-intro');
                      },
                      icon: const Icon(Icons.rocket_launch_outlined),
                      label: const Text('Debug: Open onboarding intro'),
                    ),
                    SizedBox(height: context.spacing.md),
                    // Reset onboarding completion and preferences
                    FilledButton.icon(
                      onPressed: () async {
                        if (!kDebugMode) return;
                        final cache = ref.read(appCacheProvider);
                        await cache.setPref('onboard_complete', false);
                        await cache.setPref('onboard_level', null);
                        await cache.setPref('onboard_days', <String>[]);
                        await cache.setPref('onboard_time_minutes', null);
                        await cache.setPref('onboard_notifications', false);
                        await cache.setPref('onboard_microphone', false);
                        // Also reset in-memory state providers
                        ref.read(onboardingGoalsProvider.notifier).state = <String>[];
                        ref.read(onboardingLevelProvider.notifier).state = null;
                        ref.read(onboardingDaysProvider.notifier).state = <String>[];
                        ref.read(onboardingTimeMinutesProvider.notifier).state = 18 * 60;
                        ref.read(onboardingNotificationsGrantedProvider.notifier).state = false;
                        ref.read(onboardingMicrophoneAllowedProvider.notifier).state = false;
                        if (!context.mounted) return;
                        context.go('/onboarding-intro');
                      },
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Debug: Reset onboarding'),
                    ),
                    SizedBox(height: context.spacing.md),
                    // Show cached token prefix (debug)
                    Consumer(builder: (context, ref, _) {
                      return FilledButton.icon(
                        onPressed: () async {
                          if (!kDebugMode) return;
                          final scaffold = ScaffoldMessenger.of(context);
                          try {
                            final token = await ref.read(authSessionManagerProvider).readCachedIdToken();
                            final prefix = (token == null || token.length < 12) ? token ?? '(none)' : '${token.substring(0, 12)}...';
                            scaffold.showSnackBar(SnackBar(content: Text('Cached ID token: $prefix')));
                          } catch (e) {
                            scaffold.showSnackBar(SnackBar(content: Text('Token read error: $e')));
                          }
                        },
                        icon: const Icon(Icons.vpn_key),
                        label: const Text('Debug: Show cached token prefix'),
                      );
                    }),
                    SizedBox(height: context.spacing.md),
                    FilledButton.icon(
                      onPressed: () async {
                        if (!kDebugMode) return;
                        final scaffold = ScaffoldMessenger.of(context);
                        try {
                      final appCache = ref.read(appCacheProvider);
                          final now = DateTime.now().toIso8601String();
                          await appCache.writeCache('ping', now);
                          final readBack = appCache.readCache<String>('ping');
                      if (!context.mounted) return;
                      scaffold.showSnackBar(SnackBar(content: Text('Hive OK: $readBack')));
                        } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hive error: $e')));
                        }
                      },
                      icon: const Icon(Icons.sd_storage),
                      label: const Text('Debug: Test Hive Cache'),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: Text('Home')),
    );
  }
}

class _ColorSwatchBox extends StatelessWidget {
  const _ColorSwatchBox({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: context.radii.brSm,
        border: Border.all(color: Colors.black12),
      ),
      width: 120,
      height: 72,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
    );
  }
}

class _InteractiveSwatches extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [
      {'label': 'Blue', 'color': Colors.blue},
      {'label': 'Purple', 'color': Colors.deepPurple},
      {'label': 'Green', 'color': Colors.green},
      {'label': 'Orange', 'color': Colors.deepOrange},
    ];
    return Wrap(
      spacing: context.spacing.md,
      runSpacing: context.spacing.md,
      children: options.map((opt) {
        final color = opt['color'] as Color;
        final label = opt['label'] as String;
        return InkWell(
          onTap: () async {
            ref.read(seedColorProvider.notifier).state = color;
            await ref.read(appCacheProvider).setPref('theme_seed', color.value);
          },
          borderRadius: context.radii.brSm,
          child: _ColorSwatchBox(label: '$label (tap to apply)', color: color),
        );
      }).toList(),
    );
  }
}


