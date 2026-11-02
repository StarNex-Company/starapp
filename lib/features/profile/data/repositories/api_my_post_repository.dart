import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/my_post.dart';
import 'package:starapp/features/profile/data/repositories/my_post_repository.dart';

class ApiMyPostRepository implements MyPostRepository {
  const ApiMyPostRepository(this._client);

  final ApiClient _client;

  @override
  Future<MyPost> fetchPost(String id) => _client.get(
    '/me/posts/$id',
    decode: (json) => MyPost.fromJson(json as Json),
  );

  @override
  Future<void> setStarred(String postId, {required bool starred}) => starred
      ? _client.post<void>('/posts/$postId/star')
      : _client.delete<void>('/posts/$postId/star');

  @override
  Future<void> setSaved(String postId, {required bool saved}) => saved
      ? _client.post<void>('/posts/$postId/save')
      : _client.delete<void>('/posts/$postId/save');

  @override
  Future<void> deletePost(String postId) =>
      _client.delete<void>('/posts/$postId');
}
