import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/core/session/data/repositories/mock_session_repository.dart';
import 'package:starapp/features/home/data/models/feed_category.dart';
import 'package:starapp/features/home/data/models/home_feed.dart';
import 'package:starapp/features/home/data/models/post.dart';
import 'package:starapp/features/home/data/provider/home_providers.dart';
import 'package:starapp/features/home/data/repositories/home_repository.dart';
import 'package:starapp/features/home/data/repositories/mock_home_repository.dart';
import 'package:starapp/features/home/presentation/pages/home_page.dart';
import 'package:starapp/features/home/presentation/widgets/feed_primitives.dart';
import 'package:starapp/features/home/presentation/widgets/post_card.dart';
import 'package:starapp/features/home/presentation/widgets/suggested_creators.dart';
import 'package:starapp/features/home/presentation/widgets/trending_talents.dart';

/// Serves the mock feed (or fails) and records what the page sends back.
/// With [rejectChanges], every change is refused like a server error.
class _RecordingRepository implements HomeRepository {
  _RecordingRepository({this.fail = false, this.rejectChanges = false});

  bool fail;
  final bool rejectChanges;
  final calls = <String>[];

  Future<void> _record(String call) async {
    calls.add(call);
    if (rejectChanges) throw const ServerException(statusCode: 500);
  }

  @override
  Future<HomeSections> fetchSections() async {
    if (fail) throw StateError('offline');
    return const MockHomeRepository().fetchSections();
  }

  @override
  Future<Paged<Post>> fetchPosts({
    FeedCategory category = FeedCategory.following,
    String? cursor,
  }) async {
    if (fail) throw StateError('offline');
    calls.add('posts ${category.name}');
    return const MockHomeRepository().fetchPosts();
  }

  @override
  Future<void> setStarred(String postId, {required bool starred}) =>
      _record('star $postId $starred');

  @override
  Future<void> setBookmarked(String postId, {required bool bookmarked}) =>
      _record('bookmark $postId $bookmarked');

  @override
  Future<void> setReported(String postId, {required bool reported}) =>
      _record('report $postId $reported');

  @override
  Future<void> hideSuggestion(String creatorId) => _record('hide $creatorId');
}

/// Follows go to the shared session; records them in the feed's call log.
class _RecordingSession extends MockSessionRepository {
  _RecordingSession(this.calls);

  final List<String> calls;

  @override
  Future<void> setFollowing(
    String creatorId, {
    required bool following,
  }) async => calls.add('follow $creatorId $following');
}

void main() {
  /// Pumps the home tab under a router whose other destinations just print
  /// the location they were opened with. [repository] replaces the mock one.
  Future<void> pumpHome(
    WidgetTester tester, {
    HomeRepository? repository,
  }) async {
    tester.view.physicalSize = const Size(393, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget stub(BuildContext _, GoRouterState s) =>
        Scaffold(body: Text('route:${s.uri}'));
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomePage()),
        for (final path in [
          AppRoutes.notifications,
          AppRoutes.search,
          AppRoutes.story,
          AppRoutes.storyCreate,
          AppRoutes.videos,
          AppRoutes.discoverSuggested,
          '/creator/:id',
        ])
          GoRoute(path: path, builder: stub),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (repository != null)
            homeRepositoryProvider.overrideWithValue(repository),
          if (repository is _RecordingRepository)
            sessionRepositoryProvider.overrideWithValue(
              _RecordingSession(repository.calls),
            ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();
  }

  /// Lets any toast's timer run out so the test ends cleanly.
  Future<void> settleToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('renders the feed in design order without layout errors', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Your story'), findsOneWidget);
    expect(find.text('Trending Talents'), findsOneWidget);
    expect(find.text('Suggested Creators'), findsOneWidget);
    expect(find.text('Featured Opportunity'), findsNothing);
    expect(find.text('Starred by'), findsWidgets);
    expect(find.text('Liked by'), findsNothing);
    expect(find.text('29'), findsOneWidget);
    expect(find.text('@chidi_lens'), findsOneWidget);

    final authors = tester
        .widgetList<PostCard>(find.byType(PostCard))
        .map((card) => card.post.author.name)
        .toList();
    expect(authors, [
      'Gloria H. Kenneth',
      'Pastor E.A Adeboye',
      'President Bola A. Tinubu',
      'Ayeni Micheal',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the greeting shows the signed-in user', (tester) async {
    await pumpHome(tester);
    await tester.pump();

    expect(find.textContaining('Emmanuel 👋'), findsOneWidget);
  });

  testWidgets('post Follow toggles to Following and back', (tester) async {
    await pumpHome(tester);
    final firstPost = find.byType(PostCard).first;

    await tester.tap(
      find.descendant(of: firstPost, matching: find.text('Follow')),
    );
    await tester.pump();
    expect(
      find.descendant(of: firstPost, matching: find.text('Following')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: firstPost, matching: find.text('Following')),
    );
    await tester.pump();
    expect(
      find.descendant(of: firstPost, matching: find.text('Follow')),
      findsOneWidget,
    );
  });

  testWidgets('starring a post bumps its count and back', (tester) async {
    await pumpHome(tester);
    final firstPost = find.byType(PostCard).first;
    Finder inPost(String text) =>
        find.descendant(of: firstPost, matching: find.text(text));

    expect(inPost('108.2k'), findsOneWidget);
    await tester.tap(find.byTooltip('Star').first);
    await tester.pump();
    expect(inPost('108.2k'), findsOneWidget, reason: '108,201 rounds down');
    expect(
      tester.widget<PostCard>(firstPost).post,
      isA<Post>()
          .having((p) => p.isStarred, 'isStarred', isTrue)
          .having((p) => p.stars, 'stars', 108201),
    );

    await tester.tap(find.byTooltip('Remove star').first);
    await tester.pump();
    expect(tester.widget<PostCard>(firstPost).post.stars, 108200);
  });

  testWidgets('bookmark and report toggle with the design toasts', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.byTooltip('Bookmark').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved to your bookmarks'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove bookmark').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Removed from bookmarks'), findsOneWidget);

    await tester.tap(find.byTooltip('Report').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Reported · our team will review this request'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Withdraw report').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Report withdrawn'), findsOneWidget);

    await settleToast(tester);
  });

  testWidgets('a rejected change rolls back and says why', (tester) async {
    await pumpHome(
      tester,
      repository: _RecordingRepository(rejectChanges: true),
    );

    await tester.tap(find.byTooltip('Bookmark').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byTooltip('Remove bookmark'), findsNothing);
    expect(
      find.text('Something went wrong on our side. Please try again.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Dismiss suggestion').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Chidi Visuals'), findsOneWidget);

    await settleToast(tester);
  });

  testWidgets('trending video cycles play → pause → resume', (tester) async {
    await pumpHome(tester);
    final card = find.byType(TrendingTalentCard).first;
    String? value() => tester.getSemantics(card).value;

    expect(value(), 'Playing');
    await tester.tap(card);
    await tester.pump();
    expect(value(), 'Paused');
    await tester.tap(card);
    await tester.pump();
    expect(value(), 'Playing');
    await tester.pump(const Duration(milliseconds: 250));
  });

  testWidgets('dismissing a suggestion hides it with a toast', (tester) async {
    await pumpHome(tester);
    final section = find.byType(SuggestedCreators);
    expect(find.text('Chidi Visuals'), findsOneWidget);

    await tester.tap(
      find.descendant(of: section, matching: find.text('Follow')).first,
    );
    await tester.pump();
    expect(
      find.descendant(of: section, matching: find.text('Following')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Dismiss suggestion').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Chidi Visuals'), findsNothing);
    expect(find.text('Suggestion hidden'), findsOneWidget);

    await settleToast(tester);
  });

  testWidgets('header, stories and section links navigate', (tester) async {
    Future<void> expectRoute(
      Finder target,
      String location, {
      Finder? row,
    }) async {
      await pumpHome(tester);
      // Cards at the end of a horizontal row are only built once scrolled to.
      if (row != null) {
        await tester.dragUntilVisible(target, row, const Offset(-300, 0));
      }
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(find.text('route:$location'), findsOneWidget, reason: location);
    }

    await expectRoute(find.byTooltip('Notifications'), AppRoutes.notifications);
    await expectRoute(find.byTooltip('Search'), AppRoutes.search);
    await expectRoute(find.text('Your story'), AppRoutes.storyCreate);
    await expectRoute(
      find.text('10 Followers'),
      '${AppRoutes.story}?creator=tinubu',
    );
    await expectRoute(find.text('See All'), AppRoutes.discoverSuggested);
    final trending = find.byType(TrendingTalents);
    await expectRoute(
      find.descendant(of: trending, matching: find.byType(FeedViewAllCard)),
      AppRoutes.videos,
      row: find.descendant(of: trending, matching: find.byType(ListView)),
    );
  });

  testWidgets('authors and suggested creators open their profiles', (
    tester,
  ) async {
    Future<void> expectProfile(Finder target, String creatorId) async {
      await pumpHome(tester);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(
        find.text('route:/creator/$creatorId'),
        findsOneWidget,
        reason: creatorId,
      );
    }

    await expectProfile(find.text('Gloria H. Kenneth'), 'gloria');
    await expectProfile(find.text('Chidi Visuals'), 'chidi-visuals');
  });

  testWidgets('feed actions reach the repository', (tester) async {
    final repository = _RecordingRepository();
    await pumpHome(tester, repository: repository);
    final firstPost = find.byType(PostCard).first;
    final section = find.byType(SuggestedCreators);

    await tester.tap(
      find.descendant(of: firstPost, matching: find.text('Follow')),
    );
    await tester.tap(find.byTooltip('Star').first);
    await tester.tap(find.byTooltip('Bookmark').first);
    await tester.tap(find.byTooltip('Report').first);
    await tester.tap(
      find.descendant(of: section, matching: find.text('Follow')).first,
    );
    await tester.tap(find.byTooltip('Dismiss suggestion').first);
    await tester.tap(find.text('Discover'));
    await tester.pump();

    expect(repository.calls, [
      'posts following',
      'follow gloria true',
      'star p1 true',
      'bookmark p1 true',
      'report p1 true',
      'follow chidi-visuals true',
      'hide chidi-visuals',
      'posts discover',
    ]);
    await settleToast(tester);
  });

  testWidgets('a failed load keeps the header and offers a retry', (
    tester,
  ) async {
    final repository = _RecordingRepository(fail: true);
    await pumpHome(tester, repository: repository);
    await tester.pump();

    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.text("Couldn't load this right now."), findsOneWidget);
    expect(find.byType(PostCard), findsNothing);

    repository.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(PostCard), findsWidgets);
  });

  test('compact counts match the design', () {
    expect(108200.compact, '108.2k');
    expect(12000.compact, '12k');
    expect(265800.compact, '265.8k');
    expect(260.compact, '260');
    expect(2500000.compact, '2.5M');
  });

  test('post times read as the design shows them', () {
    final now = DateTime(2026, 11, 1, 18);

    expect(formatPostedAt(DateTime(2026, 11, 1, 14), now: now), '14:00');
    expect(
      formatPostedAt(DateTime(2026, 10, 31, 13, 45), now: now),
      'Yesterday - 13:45',
    );
    expect(
      formatPostedAt(DateTime(2026, 9, 14, 9, 30), now: now),
      'Sep 14 - 09:30',
    );
    expect(
      formatPostedAt(DateTime(2025, 9, 14, 9, 30), now: now),
      'Sep 14, 2025 - 09:30',
    );
  });
}
