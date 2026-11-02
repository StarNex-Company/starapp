import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';
import 'package:starapp/features/profile/data/repositories/creator_repository.dart';

class ApiCreatorRepository implements CreatorRepository {
  const ApiCreatorRepository(this._client);

  final ApiClient _client;

  @override
  Future<CreatorProfile> fetchCreator(String creatorId) => _client.get(
    '/creators/$creatorId',
    decode: (json) => CreatorProfile.fromJson(json as Json),
  );

  @override
  Future<Paged<CreatorPost>> fetchPosts(String creatorId, {String? cursor}) =>
      _client.get(
        '/creators/$creatorId/posts',
        query: {'cursor': cursor},
        decode: (json) => Paged.fromJson(json as Json, CreatorPost.fromJson),
      );
}
