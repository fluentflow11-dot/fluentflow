import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/design_tokens.dart';
import '../../core/hive_init.dart';
import '../../core/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/storage_debug.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
            return IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () async {
                try {
                  await auth.signOut();
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
                    Text('Theme Preview', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: context.spacing.md),
                    Wrap(
                      spacing: context.spacing.md,
                      runSpacing: context.spacing.md,
                      children: [
                        _ColorSwatchBox(label: 'Primary', color: Theme.of(context).colorScheme.primary),
                        _ColorSwatchBox(label: 'Secondary', color: Theme.of(context).colorScheme.secondary),
                        _ColorSwatchBox(label: 'Tertiary', color: Theme.of(context).colorScheme.tertiary),
                        _ColorSwatchBox(label: 'Surface', color: Theme.of(context).colorScheme.surface),
                      ],
                    ),
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


