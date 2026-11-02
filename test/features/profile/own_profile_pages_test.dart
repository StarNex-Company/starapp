import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/profile/presentation/pages/my_post_page.dart';
import 'package:starapp/features/profile/presentation/pages/my_profile_page.dart';
import 'package:starapp/features/profile/presentation/pages/saved_page.dart';
import 'package:starapp/features/profile/presentation/pages/shortcuts_page.dart';
import 'package:starapp/features/profile/presentation/pages/star_insights_page.dart';
import 'package:starapp/features/profile/presentation/pages/talent_passport_page.dart';
import 'package:starapp/features/profile/presentation/pages/top_posts_page.dart';

/// Pumps [location] on a phone-sized screen with the default test font,
/// which is wider than Inter and so surfaces overflows.
Future<void> _pump(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, _) => const MyProfilePage(),
        routes: [
          GoRoute(path: 'saved', builder: (_, _) => const SavedPage()),
          GoRoute(
            path: 'insights',
            builder: (_, _) => const StarInsightsPage(),
          ),
          GoRoute(path: 'top-posts', builder: (_, _) => const TopPostsPage()),
          GoRoute(path: 'shortcuts', builder: (_, _) => const ShortcutsPage()),
          GoRoute(
            path: 'passport',
            builder: (_, _) => const TalentPassportPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.post,
        builder: (_, state) =>
            MyPostPage(postId: state.uri.queryParameters['id'] ?? ''),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp.router(routerConfig: router)),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('My Profile shows every tab without layout errors', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.profile);

    expect(find.text('Top 4% in Nigeria'), findsOneWidget);
    expect(find.text('Progress to Stellar'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Stats'), 300);
    await tester.tap(find.text('Challenge History'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('11.8K'), findsOneWidget);
    expect(find.text('Best month yet'), findsOneWidget);
    expect(find.text('62% of your Stars'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shortcuts shows the grid and the list', (tester) async {
    await _pump(tester, AppRoutes.profileShortcuts);
    expect(find.text('8 saved videos'), findsOneWidget);
    expect(find.text('3 of 5 steps complete'), findsOneWidget);

    await tester.tap(find.byTooltip('List view'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Star Insights switches periods without layout errors', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.profileInsights);
    await tester.pumpAndSettle();
    expect(find.text('Last 6 months'), findsOneWidget);
    expect(find.text('+384 this month'), findsOneWidget);
    expect(find.text('Growth boost active · ×1.2'), findsOneWidget);

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(find.text('Last 7 days'), findsOneWidget);

    await tester.tap(find.byTooltip('Date range'));
    await tester.pumpAndSettle();
    expect(find.text('Pick start and end dates'), findsOneWidget);
    await tester.tap(find.text('Last 6 months').last);
    await tester.pumpAndSettle();
    expect(find.text('+1,071 in 6 months'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Top posts, passport and saved render', (tester) async {
    await _pump(tester, AppRoutes.profileTopPosts);
    expect(find.text('Late-night vocal run'), findsOneWidget);

    await _pump(tester, AppRoutes.profilePassport);
    await tester.pumpAndSettle();
    expect(find.text('starapp.io/p/emmanuel'), findsOneWidget);
    expect(find.text('Top 10 · Afro-Dance Takeover'), findsOneWidget);
    expect(find.textContaining(r'· $600 prize'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Kora Studios'), 300);
    expect(find.text('721 Stars away'), findsOneWidget);
    expect(find.text('Preview your Stellar unlock ✨'), findsOneWidget);

    await _pump(tester, AppRoutes.profileSaved);
    await tester.pumpAndSettle();
    expect(find.text('8 saved · only you can see these'), findsOneWidget);
    await tester.ensureVisible(find.text('Audio'));
    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    expect(find.text('3 saved · only you can see these'), findsOneWidget);
    await tester.tap(find.byTooltip('Show as list'));
    await tester.pumpAndSettle();
    expect(find.textContaining('views · saved this week'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('my post stars, saves and opens its menu', (tester) async {
    await _pump(tester, '${AppRoutes.post}?id=late-night-vocal-run');
    expect(find.text('1098'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Star'));
    await tester.pump();
    expect(find.text('1099'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Post options'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('4.2K views · 312 Stars'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Stop the simulated playback before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
