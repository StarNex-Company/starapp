import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/profile/data/models/connections.dart';

/// Followers / following lists. Screens read `connectionsProvider`;
/// `connectionsRepositoryProvider` picks the mock or API implementation.
abstract interface class ConnectionsRepository {
  /// [creatorId]'s followers or following, or the signed-in user's when
  /// null. [query] matches names and handles; pass the previous page's
  /// `nextCursor` for the next page.
  Future<Paged<Connection>> fetchConnections(
    String? creatorId,
    ConnectionsTab tab, {
    String query = '',
    String? cursor,
  });
}
