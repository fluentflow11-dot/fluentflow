import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lesson_flow_controller.dart';

class LessonPlayerScreen extends ConsumerWidget {
	const LessonPlayerScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final state = ref.watch(lessonFlowControllerProvider);
		final controller = ref.read(lessonFlowControllerProvider.notifier);

		Widget content;
		switch (state.currentActivity) {
			case LessonActivityType.speakingWarmup:
				content = const _PlaceholderActivity(title: 'Speaking warm-up');
				break;
			case LessonActivityType.pronunciation:
				content = const _PlaceholderActivity(title: 'Pronunciation practice');
				break;
			case LessonActivityType.grammar:
				content = const _PlaceholderActivity(title: 'Grammar tiles');
				break;
			case LessonActivityType.summary:
				content = const _PlaceholderActivity(title: 'Summary');
				break;
			case LessonActivityType.overview:
			default:
				content = const _PlaceholderActivity(title: 'Overview');
		}

		return Scaffold(
			appBar: AppBar(
				title: Text('Step ${state.currentIndex + 1} of ${state.activities.length}'),
				leading: state.canGoBack
					? IconButton(
						icon: const Icon(Icons.arrow_back),
						onPressed: controller.back,
					)
					: null,
			),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(16),
					child: content,
				),
			),
			bottomNavigationBar: SafeArea(
				child: Padding(
					padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
					child: SizedBox(
						width: double.infinity,
						height: 48,
						child: FilledButton(
							onPressed: state.canGoNext
								? controller.next
								: () => Navigator.of(context).pop(),
							child: Text(state.canGoNext ? 'Next' : 'Finish'),
						),
					),
				),
			),
		);
	}
}

class _PlaceholderActivity extends StatelessWidget {
	const _PlaceholderActivity({required this.title});

	final String title;

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(Icons.school, size: 64, color: Theme.of(context).colorScheme.primary),
					const SizedBox(height: 12),
					Text(title, style: Theme.of(context).textTheme.headlineSmall),
					const SizedBox(height: 8),
					const Text('This is a placeholder. We\'ll implement the full activity next.'),
				],
			),
		);
	}
}


