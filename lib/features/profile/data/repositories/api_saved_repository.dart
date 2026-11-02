import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/saved_item.dart';
import 'package:starapp/features/profile/data/repositories/saved_repository.dart';

class ApiSavedRepository implements SavedRepository {
  const ApiSavedRepository(this._client);

  final ApiClient _client;

  @override
  Future<SavedItems> fetchSaved({SavedKind? type, String? cursor}) =>
      _client.get(
        '/me/saved',
        query: {'type': type?.name, 'cursor': cursor},
        decode: (json) => SavedItems.fromJson(json as Json),
      );

  @override
  Future<void> unsave(String postId) =>
      _client.delete<void>('/posts/$postId/save');
}
