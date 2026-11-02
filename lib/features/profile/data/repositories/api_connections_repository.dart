import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/connections.dart';
import 'package:starapp/features/profile/data/repositories/connections_repository.dart';

class ApiConnectionsRepository implements ConnectionsRepository {
  const ApiConnectionsRepository(this._client);

  final ApiClient _client;

  @override
  Future<Paged<Connection>> fetchConnections(
    String? creatorId,
    ConnectionsTab tab, {
    String query = '',
    String? cursor,
  }) => _client.get(
    '${creatorId == null ? '/me' : '/creators/$creatorId'}/${tab.name}',
    query: {'q': query.isEmpty ? null : query, 'cursor': cursor},
    decode: (json) => Paged.fromJson(json as Json, Connection.fromJson),
  );
}
