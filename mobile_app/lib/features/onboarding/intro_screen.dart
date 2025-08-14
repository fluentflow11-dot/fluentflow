import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_tokens.dart';
import '../../core/hive_init.dart';
import 'package:go_router/go_router.dart';

class OnboardingIntroScreen extends ConsumerWidget {
  const OnboardingIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme;
    final hasProgress = (ref.read(appCacheProvider).getPref<int>('onboard_step_index') ?? 0) > 0;
    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.chat_bubble_outline, size: 96, color: color.primary),
              SizedBox(height: context.spacing.lg),
              Text(
                'Learn English with confidence',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: context.spacing.md),
              Text(
                'Daily lessons, guided practice, and real conversation—powered by AI.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              if (hasProgress) ...[
                FilledButton(
                  onPressed: () {
                    context.go('/onboarding-wizard');
                  },
                  child: const Text('Resume onboarding'),
                ),
                SizedBox(height: context.spacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    final cache = ref.read(appCacheProvider);
                    await cache.setPref('onboard_step_index', 0);
                    if (!context.mounted) return;
                    context.go('/onboarding-wizard');
                  },
                  child: const Text('Start over'),
                ),
              ] else ...[
                FilledButton(
                  onPressed: () {
                    context.go('/onboarding-wizard');
                  },
                  child: const Text('Begin'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


