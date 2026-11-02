import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/home/data/models/feed_category.dart';
import 'package:starapp/features/home/data/models/home_feed.dart';
import 'package:starapp/features/home/data/models/post.dart';
import 'package:starapp/features/home/data/provider/home_providers.dart';
import 'package:starapp/features/home/data/repositories/mock_home_repository.dart';

/// Two pages of the mock posts, with the second page's ids renamed.
class _TwoPages extends MockHomeRepository {
  final cursors = <String?>[];

  @override
  Future<Paged<Post>> fetchPosts({
    FeedCategory category = FeedCategory.following,
    String? cursor,
  }) async {
    cursors.add(cursor);
    final page = await super.fetchPosts();
    if (cursor == null) return Paged(items: page.items, nextCursor: 'page2');
    return Paged(
      items: [
        for (final p in page.items)
          Post.fromJson({...p.toJson(), 'id': '${p.id}-2'}),
      ],
    );
  }
}

void main() {
  const mock = MockHomeRepository();

  test('the mock sections parse and cover what the page shows', () async {
    final sections = await mock.fetchSections();

    expect(sections.stories, isNotEmpty);
    expect(sections.stories.every((s) => s.coverUrl != null), isTrue);
    expect(sections.trendingTalents, isNotEmpty);
    expect(
      sections.trendingTalents.any((t) => t.author.tier != null),
      isTrue,
      reason: 'a creator badge',
    );
    expect(sections.suggestedCreators, isNotEmpty);
    expect(
      sections.suggestedCreators.every((s) => s.followedBy.isNotEmpty),
      isTrue,
      reason: '"Followed by" avatars',
    );
  });

  test('the mock feed parses and covers every post layout', () async {
    final page = await mock.fetchPosts();
    final posts = page.items;

    expect(page.hasMore, isFalse);
    expect(posts.any((p) => p.mediaUrls.length == 1), isTrue, reason: 'large');
    expect(
      posts.any((p) => p.mediaUrls.length > 4 && p.mediaCount > 4),
      isTrue,
      reason: 'the "+N" pile',
    );
    expect(posts.any((p) => p.mediaUrls.isEmpty), isTrue, reason: 'text only');
    expect(posts.any((p) => p.authorHasStory), isTrue, reason: 'story ring');
    expect(
      posts.any((p) => p.createdAt.day != DateTime.now().day),
      isTrue,
      reason: '"Yesterday - …"',
    );
    expect(posts.every((p) => p.starredBy.isNotEmpty), isTrue);
  });

  test('toJson round-trips', () async {
    final sections = await mock.fetchSections();
    expect(
      HomeSections.fromJson(sections.toJson()).toJson(),
      sections.toJson(),
    );

    for (final p in (await mock.fetchPosts()).items) {
      expect(Post.fromJson(p.toJson()).toJson(), p.toJson());
    }
  });

  test('missing fields fall back instead of throwing', () {
    final post = Post.fromJson({
      'id': 'x',
      'author': {'id': 'a', 'name': 'A', 'handle': 'a'},
      'mediaUrls': ['https://cdn.example.com/1.jpg'],
    });

    expect(post.text, '');
    expect(post.mediaCount, 1);
    expect(post.stars, 0);
    expect(post.isStarred, isFalse);
    expect(HomeSections.fromJson({}).stories, isEmpty);
  });

  test('loadMore appends the next page, then stops', () async {
    final repository = _TwoPages();
    final container = ProviderContainer(
      overrides: [homeRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(homeFeedProvider.notifier);

    final first = await container.read(homeFeedProvider.future);
    expect(first.posts, hasLength(4));
    expect(notifier.hasMore, isTrue);

    await notifier.loadMore();
    expect(container.read(homeFeedProvider).value!.posts, hasLength(8));
    expect(notifier.hasMore, isFalse);

    await notifier.loadMore();
    expect(repository.cursors, [null, 'page2']);
  });
}
