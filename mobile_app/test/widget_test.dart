// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentflow_app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluentflow_app/core/router.dart';

void main() {
  testWidgets('App renders without Firebase by overriding router', (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Test Home'))),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(testRouter),
        ],
        child: const App(),
      ),
    );

    // App should mount a MaterialApp with our test route
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Test Home'), findsOneWidget);
  });
}
