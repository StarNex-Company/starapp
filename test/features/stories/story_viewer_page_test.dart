import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/stories/presentation/pages/story_viewer_page.dart';

void main() {
  Future<void> pumpViewer(WidgetTester tester, String key) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '${AppRoutes.story}?creator=$key',
      routes: [
        GoRoute(
          path: AppRoutes.story,
          builder: (_, s) => StoryViewerPage(
            creator: s.uri.queryParameters['creator']!,
            storyDuration: const Duration(minutes: 1),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Finder semantics(String label) => find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  );

  testWidgets('shows the creator with the story age, and stars it', (
    tester,
  ) async {
    await pumpViewer(tester, 'sarah');

    expect(find.text('Sarah Angel  ·  3h'), findsOneWidget);
    expect(find.text('Match day energy ⚽'), findsOneWidget);

    final star = semantics('Star story');
    expect(tester.widget<Semantics>(star).properties.selected, isFalse);
    await tester.tap(star);
    await tester.pump();
    expect(tester.widget<Semantics>(star).properties.selected, isTrue);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Discover stories use the like button', (tester) async {
    await pumpViewer(tester, 'amina');

    expect(find.text('Chidi Eze  ·  2h'), findsOneWidget);
    expect(semantics('Like story'), findsOneWidget);
    expect(semantics('Star story'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
