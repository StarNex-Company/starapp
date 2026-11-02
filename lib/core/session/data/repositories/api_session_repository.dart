import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/core/session/data/repositories/session_repository.dart';
import 'package:starapp/core/utils/json.dart';

class ApiSessionRepository implements SessionRepository {
  const ApiSessionRepository(this._client);

  final ApiClient _client;

  @override
  Future<CurrentUser> fetchCurrentUser() =>
      _client.get('/me', decode: (json) => CurrentUser.fromJson(json as Json));

  @override
  Future<CurrentUser> updateProfile(CurrentUser user) => _client.patch(
    '/me',
    data: {
      'fullName': user.fullName,
      'handle': user.handle,
      'bio': user.bio,
      'talents': user.talents,
      'avatarUrl': user.avatarUrl,
      'coverUrl': user.coverUrl,
    },
    decode: (json) => CurrentUser.fromJson(json as Json),
  );

  @override
  Future<String> uploadAvatar(String filePath) => _client.upload(
    '/me/avatar',
    filePath: filePath,
    decode: (json) => (json as Json)['url'] as String,
  );

  @override
  Future<String> uploadCover(String filePath) => _client.upload(
    '/me/cover',
    filePath: filePath,
    decode: (json) => (json as Json)['url'] as String,
  );

  @override
  Future<Set<String>> fetchFollowing() => _client.get(
    '/me/following/ids',
    decode: (json) => readStrings(json).toSet(),
  );

  @override
  Future<void> setFollowing(String creatorId, {required bool following}) =>
      following
      ? _client.put<void>('/creators/$creatorId/follow')
      : _client.delete<void>('/creators/$creatorId/follow');

  @override
  Future<void> signOut() => _client.post<void>('/auth/logout');
}
