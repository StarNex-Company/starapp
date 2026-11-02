import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/home/data/models/feed_category.dart';
import 'package:starapp/features/home/data/models/home_feed.dart';
import 'package:starapp/features/home/data/models/post.dart';
import 'package:starapp/features/home/data/repositories/home_repository.dart';

class ApiHomeRepository implements HomeRepository {
  const ApiHomeRepository(this._client);

  final ApiClient _client;

  @override
  Future<HomeSections> fetchSections() => _client.get(
    '/home',
    decode: (json) => HomeSections.fromJson(json as Json),
  );

  @override
  Future<Paged<Post>> fetchPosts({
    FeedCategory category = FeedCategory.following,
    String? cursor,
  }) => _client.get(
    '/feed',
    query: {'tab': category.name, 'cursor': cursor},
    decode: (json) => Paged.fromJson(json as Json, Post.fromJson),
  );

  @override
  Future<void> setStarred(String postId, {required bool starred}) =>
      _toggle('/posts/$postId/star', on: starred);

  @override
  Future<void> setBookmarked(String postId, {required bool bookmarked}) =>
      _toggle('/posts/$postId/bookmark', on: bookmarked);

  @override
  Future<void> setReported(String postId, {required bool reported}) =>
      _toggle('/posts/$postId/report', on: reported);

  @override
  Future<void> hideSuggestion(String creatorId) =>
      _client.post<void>('/suggested-creators/$creatorId/dismiss');

  /// `PUT` turns a per-user flag on, `DELETE` turns it off.
  Future<void> _toggle(String path, {required bool on}) =>
      on ? _client.put<void>(path) : _client.delete<void>(path);
}
