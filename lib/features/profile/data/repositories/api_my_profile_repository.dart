import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/data/repositories/my_profile_repository.dart';

class ApiMyProfileRepository implements MyProfileRepository {
  const ApiMyProfileRepository(this._client);

  final ApiClient _client;

  @override
  Future<MyProfile> fetchMyProfile() => _client.get(
    '/me/profile',
    decode: (json) => MyProfile.fromJson(json as Json),
  );

  @override
  Future<Paged<ProfileGridPost>> fetchPosts({String? cursor}) => _client.get(
    '/me/posts',
    query: {'cursor': cursor},
    decode: (json) => Paged.fromJson(json as Json, ProfileGridPost.fromJson),
  );

  @override
  Future<ShortcutsSummary> fetchShortcuts() => _client.get(
    '/me/shortcuts',
    decode: (json) => ShortcutsSummary.fromJson(json as Json),
  );
}
