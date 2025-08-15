import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LessonActivityType {
	overview,
	speakingWarmup,
	pronunciation,
	grammar,
	summary,
}

@immutable
class LessonFlowState {
	const LessonFlowState({required this.activities, required this.currentIndex});

	final List<LessonActivityType> activities;
	final int currentIndex;

	LessonActivityType get currentActivity => activities[currentIndex];
	bool get canGoBack => currentIndex > 0;
	bool get canGoNext => currentIndex < activities.length - 1;
}

class LessonFlowController extends StateNotifier<LessonFlowState> {
	LessonFlowController() : super(const LessonFlowState(activities: <LessonActivityType>[], currentIndex: 0));

	void initializeDefaultFlow() {
		state = const LessonFlowState(
			activities: <LessonActivityType>[
				LessonActivityType.speakingWarmup,
				LessonActivityType.pronunciation,
				LessonActivityType.grammar,
				LessonActivityType.summary,
			],
			currentIndex: 0,
		);
	}

	void next() {
		if (!state.canGoNext) return;
		state = LessonFlowState(activities: state.activities, currentIndex: state.currentIndex + 1);
	}

	void back() {
		if (!state.canGoBack) return;
		state = LessonFlowState(activities: state.activities, currentIndex: state.currentIndex - 1);
	}
}

final lessonFlowControllerProvider = StateNotifierProvider<LessonFlowController, LessonFlowState>((ref) {
	return LessonFlowController();
});


