import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lesson_flow_controller.dart';
import 'package:go_router/go_router.dart';

class LessonOverviewScreen extends ConsumerWidget {
	const LessonOverviewScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		return Scaffold(
			appBar: AppBar(title: const Text('Daily Lesson')),
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text('Today\'s lesson', style: Theme.of(context).textTheme.headlineSmall),
							const SizedBox(height: 8),
							Text('Estimated time: 8–12 minutes', style: Theme.of(context).textTheme.bodyMedium),
							const SizedBox(height: 16),
							Card(
								child: Padding(
									padding: const EdgeInsets.all(16),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: const [
											Text('Activities'),
											SizedBox(height: 8),
											Text('• Speaking warm-up'),
											Text('• Pronunciation practice'),
											Text('• Grammar tiles'),
											Text('• Summary'),
										],
									),
								),
							),
						],
					),
				),
			),
			bottomNavigationBar: SafeArea(
				child: Padding(
					padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
					child: SizedBox(
						width: double.infinity,
						height: 48,
						child: FilledButton(
							onPressed: () {
								ref.read(lessonFlowControllerProvider.notifier).initializeDefaultFlow();
								context.push('/lesson');
							},
							child: const Text('Begin'),
						),
					),
				),
			),
		);
	}
}


