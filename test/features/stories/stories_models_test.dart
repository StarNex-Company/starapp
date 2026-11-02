import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/stories/data/models/new_story.dart';
import 'package:starapp/features/stories/data/models/story_creator.dart';
import 'package:starapp/features/stories/data/provider/stories_providers.dart';
import 'package:starapp/features/stories/data/repositories/mock_stories_repository.dart';

/// The mock stories, but every star and like is refused.
class _Rejecting extends MockStoriesRepository {
  @override
  Future<void> setStarred(String storyId, {required bool starred}) async =>
      throw const ServerException(statusCode: 500);
}

void main() {
  const mock = MockStoriesRepository();

  test('the mock rows parse and cover every story the viewer shows', () async {
    final home = await mock.fetchRow(StoryLayout.home);
    final discover = await mock.fetchRow(StoryLayout.discover);
    final stories = [
      for (final c in [...home, ...discover]) ...c.stories,
    ];

    expect(home.map((c) => c.storyKey), [
      'adeboye',
      'tinubu',
      'sarah',
      'funmilayo',
      'gabriel',
    ]);
    expect(discover.map((c) => c.storyKey), ['amina', 'carlos']);
    expect(stories.any((s) => s.mediaUrl != null), isTrue, reason: 'photo');
    expect(stories.any((s) => s.text != null), isTrue, reason: 'text story');
    expect(stories.any((s) => s.fit == StoryFit.contain), isTrue);
    expect(stories.every((s) => !s.isExpired()), isTrue);
    expect(home.every((c) => c.creator.avatarUrl != null), isTrue);
  });

  test('toJson round-trips', () async {
    for (final row in StoryLayout.values) {
      for (final c in await mock.fetchRow(row)) {
        expect(StoryCreator.fromJson(c.toJson()).toJson(), c.toJson());
      }
    }
  });

  test('missing fields fall back instead of throwing', () {
    final story = StoryItem.fromJson({
      'id': 'x',
      'createdAt': '2026-11-01T10:00:00Z',
      'fit': 'somethingNew',
    });

    expect(story.fit, StoryFit.cover);
    expect(story.expiresAt.difference(story.createdAt).inHours, 24);
    expect(story.isStarred, isFalse);
  });

  group('storyReelProvider', () {
    Future<StoryReel> reel(String key, {ProviderContainer? container}) async {
      final c =
          container ??
          ProviderContainer(
            overrides: [storiesRepositoryProvider.overrideWithValue(mock)],
          );
      if (container == null) addTearDown(c.dispose);
      final sub = c.listen(storyReelProvider(key), (_, _) {});
      addTearDown(sub.close);
      return c.read(storyReelProvider(key).future);
    }

    test('plays the row the creator is in, starting at them', () async {
      final home = await reel('sarah');
      expect(home.layout, StoryLayout.home);
      expect(home.creators[home.startIndex].creator.id, 'sarah-angel');

      final discover = await reel('carlos');
      expect(discover.layout, StoryLayout.discover);
      expect(discover.startIndex, 1);
    });

    test('an unknown key plays Discover from the start', () async {
      final fallback = await reel('silver');
      expect(fallback.layout, StoryLayout.discover);
      expect(fallback.startIndex, 0);
    });

    test('a refused star rolls back and rethrows', () async {
      final container = ProviderContainer(
        overrides: [storiesRepositoryProvider.overrideWithValue(_Rejecting())],
      );
      addTearDown(container.dispose);
      await reel('adeboye', container: container);
      final notifier = container.read(storyReelProvider('adeboye').notifier);

      final starring = notifier.toggleStar('adeboye-1');
      expect(
        container
            .read(storyReelProvider('adeboye'))
            .value!
            .story('adeboye-1')!
            .isStarred,
        isTrue,
      );
      await expectLater(starring, throwsA(isA<ServerException>()));
      expect(
        container
            .read(storyReelProvider('adeboye'))
            .value!
            .story('adeboye-1')!
            .isStarred,
        isFalse,
      );
    });
  });

  test('story durations send whole hours', () {
    expect(StoryDuration.h48.hours, 48);
    expect(StoryDuration.h3.label, '3h');
  });
}
