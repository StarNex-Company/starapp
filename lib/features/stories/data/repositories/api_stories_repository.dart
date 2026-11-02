import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/stories/data/models/new_story.dart';
import 'package:starapp/features/stories/data/models/story_creator.dart';
import 'package:starapp/features/stories/data/repositories/stories_repository.dart';

class ApiStoriesRepository implements StoriesRepository {
  const ApiStoriesRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<StoryCreator>> fetchRow(StoryLayout row) => _client.get(
    '/stories',
    query: {'row': row.name},
    decode: (json) => readList(json, StoryCreator.fromJson),
  );

  @override
  Future<StoryCreator?> fetchCreator(String storyKey) async {
    try {
      return await _client.get(
        '/stories/$storyKey',
        decode: (json) => StoryCreator.fromJson(json as Json),
      );
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<void> markViewed(String storyId) =>
      _client.post<void>('/stories/$storyId/view');

  @override
  Future<void> setStarred(String storyId, {required bool starred}) =>
      _toggle('/stories/$storyId/star', on: starred);

  @override
  Future<void> setLiked(String storyId, {required bool liked}) =>
      _toggle('/stories/$storyId/like', on: liked);

  @override
  Future<void> reply(String storyId, String text) =>
      _client.post<void>('/stories/$storyId/replies', data: {'text': text});

  @override
  Future<void> createStory(
    String filePath, {
    String caption = '',
    StorySettings settings = const StorySettings(),
  }) => _client.upload<void>(
    '/stories',
    filePath: filePath,
    field: 'media',
    fields: {
      'caption': caption,
      'audience': settings.audience.name,
      'durationHours': settings.duration.hours,
    },
  );

  /// `PUT` turns a per-user flag on, `DELETE` turns it off.
  Future<void> _toggle(String path, {required bool on}) =>
      on ? _client.put<void>(path) : _client.delete<void>(path);
}
