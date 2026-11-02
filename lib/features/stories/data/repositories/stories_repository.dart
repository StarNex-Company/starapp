import 'package:starapp/features/stories/data/models/new_story.dart';
import 'package:starapp/features/stories/data/models/story_creator.dart';

/// Stories to watch, the user's reactions to them, and posting a new one.
/// Screens read `storyReelProvider` and `storySettingsProvider`;
/// `storiesRepositoryProvider` picks the mock or API implementation.
abstract interface class StoriesRepository {
  /// Home's or Discover's story row, in order, each with its stories.
  Future<List<StoryCreator>> fetchRow(StoryLayout row);

  /// One creator's stories, for a creator outside both rows; null when they
  /// have none.
  Future<StoryCreator?> fetchCreator(String storyKey);

  /// Records that the user saw the story.
  Future<void> markViewed(String storyId);

  Future<void> setStarred(String storyId, {required bool starred});

  Future<void> setLiked(String storyId, {required bool liked});

  /// Sends [text] to the story's creator.
  Future<void> reply(String storyId, String text);

  /// Uploads the photo or video at [filePath] to the user's story.
  Future<void> createStory(
    String filePath, {
    String caption = '',
    StorySettings settings = const StorySettings(),
  });
}
