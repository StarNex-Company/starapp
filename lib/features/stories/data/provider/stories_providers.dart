import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/stories/data/models/new_story.dart';
import 'package:starapp/features/stories/data/models/story_creator.dart';
import 'package:starapp/features/stories/data/repositories/api_stories_repository.dart';
import 'package:starapp/features/stories/data/repositories/mock_stories_repository.dart';
import 'package:starapp/features/stories/data/repositories/sample_story_gallery.dart';
import 'package:starapp/features/stories/data/repositories/stories_repository.dart';

final storiesRepositoryProvider = Provider<StoriesRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockStoriesRepository.new,
    api: ApiStoriesRepository.new,
  ),
);

/// What the viewer plays for a story key: the Home or Discover row the
/// creator belongs to, starting at them; a creator outside both rows plays
/// alone. A key with nothing to show plays Discover's row from the start.
/// Expired stories are left out. Stars and likes show at once and roll back
/// if the server rejects them.
final storyReelProvider = AsyncNotifierProvider.autoDispose
    .family<StoryReelNotifier, StoryReel, String>(StoryReelNotifier.new);

class StoryReelNotifier extends AsyncNotifier<StoryReel> {
  StoryReelNotifier(this.storyKey);

  final String storyKey;

  /// Stories already reported as seen while this viewer is open.
  final _viewed = <String>{};

  StoriesRepository get _repository => ref.read(storiesRepositoryProvider);

  @override
  Future<StoryReel> build() async {
    final repository = ref.watch(storiesRepositoryProvider);
    final now = DateTime.now();
    List<StoryCreator> playable(Iterable<StoryCreator> creators) => [
      for (final c in creators)
        if (c.stories.where((s) => !s.isExpired(now)).toList()
            case final stories when stories.isNotEmpty)
          c.copyWith(stories: stories),
    ];

    final rows = <StoryLayout, List<StoryCreator>>{};
    for (final row in StoryLayout.values) {
      final creators = rows[row] = playable(await repository.fetchRow(row));
      final start = creators.indexWhere((c) => c.storyKey == storyKey);
      if (start >= 0) {
        return StoryReel(creators: creators, startIndex: start, layout: row);
      }
    }

    final single = playable([?await repository.fetchCreator(storyKey)]);
    if (single.isNotEmpty) return StoryReel(creators: single, startIndex: 0);

    return StoryReel(
      creators: rows[StoryLayout.discover]!,
      startIndex: 0,
      layout: StoryLayout.discover,
    );
  }

  /// Tells the server the user saw [storyId], once per viewing. Failures
  /// are ignored: nothing on screen depends on it.
  void markViewed(String storyId) {
    if (!_viewed.add(storyId)) return;
    unawaited(_repository.markViewed(storyId).catchError((Object _) {}));
  }

  Future<void> toggleStar(String storyId) => _toggle(
    storyId,
    read: (s) => s.isStarred,
    apply: (s, on) => s.copyWith(isStarred: on),
    request: (on) => _repository.setStarred(storyId, starred: on),
  );

  Future<void> toggleLike(String storyId) => _toggle(
    storyId,
    read: (s) => s.isLiked,
    apply: (s, on) => s.copyWith(isLiked: on),
    request: (on) => _repository.setLiked(storyId, liked: on),
  );

  /// Sends a reply to the story's creator.
  Future<void> reply(String storyId, String text) =>
      _repository.reply(storyId, text);

  Future<void> _toggle(
    String storyId, {
    required bool Function(StoryItem story) read,
    required StoryItem Function(StoryItem story, bool on) apply,
    required Future<void> Function(bool on) request,
  }) async {
    final story = state.value?.story(storyId);
    if (story == null) return;
    final on = !read(story);
    _update(storyId, (s) => apply(s, on));
    try {
      await request(on);
    } catch (_) {
      _update(storyId, (s) => apply(s, !on));
      rethrow;
    }
  }

  void _update(String storyId, StoryItem Function(StoryItem story) change) {
    final reel = state.value;
    if (reel != null) state = AsyncData(reel.updateStory(storyId, change));
  }
}

/// Photos and videos offered in the "Add to story" picker: the sample
/// camera roll until a gallery plugin is added.
final storyGalleryProvider = FutureProvider<List<StoryMedia>>(
  (ref) async => sampleStoryGallery,
);

/// Audience and duration for the story being created (Followers · 24h until
/// changed in the Story settings sheet), and posting it. It lives while
/// story creation is open.
final storySettingsProvider =
    NotifierProvider.autoDispose<StorySettingsNotifier, StorySettings>(
      StorySettingsNotifier.new,
    );

class StorySettingsNotifier extends Notifier<StorySettings> {
  @override
  StorySettings build() => const StorySettings();

  void apply(StorySettings settings) => state = settings;

  /// Uploads [media] to the user's story with the current settings.
  Future<void> post(StoryMedia media, {String caption = ''}) => ref
      .read(storiesRepositoryProvider)
      .createStory(media.path, caption: caption, settings: state);
}
