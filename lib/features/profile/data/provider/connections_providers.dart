import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/profile/data/models/connections.dart';
import 'package:starapp/features/profile/data/provider/creator_providers.dart';
import 'package:starapp/features/profile/data/repositories/api_connections_repository.dart';
import 'package:starapp/features/profile/data/repositories/connections_repository.dart';
import 'package:starapp/features/profile/data/repositories/mock_connections_repository.dart';

final connectionsRepositoryProvider = Provider<ConnectionsRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockConnectionsRepository.new,
    api: ApiConnectionsRepository.new,
  ),
);

/// A list to show: whose (`null` = the signed-in user) and which one.
typedef ConnectionsKey = ({String? creatorId, ConnectionsTab tab});

/// The people in one followers / following list, a page at a time, narrowed
/// by [ConnectionsNotifier.search]. Follow state isn't here: rows read
/// `followingProvider`, so a follow anywhere shows everywhere.
final connectionsProvider = AsyncNotifierProvider.autoDispose
    .family<ConnectionsNotifier, List<Connection>, ConnectionsKey>(
      ConnectionsNotifier.new,
    );

class ConnectionsNotifier extends AsyncNotifier<List<Connection>> {
  ConnectionsNotifier(this.key);

  final ConnectionsKey key;
  String _query = '';
  String? _nextCursor;
  bool _loadingMore = false;

  /// Bumped by every search, so a slower earlier response can't overwrite a
  /// newer one.
  int _generation = 0;

  ConnectionsRepository get _repository =>
      ref.read(connectionsRepositoryProvider);

  @override
  Future<List<Connection>> build() async {
    _generation++;
    final page = await ref
        .watch(connectionsRepositoryProvider)
        .fetchConnections(key.creatorId, key.tab, query: _query);
    _nextCursor = page.nextCursor;
    return page.items;
  }

  /// The search the list is narrowed by.
  String get query => _query;

  bool get hasMore => _nextCursor != null;

  /// Replaces the list with the people matching [query]. The current list
  /// stays up until they arrive.
  Future<void> search(String query) async {
    final q = query.trim();
    if (q == _query) return;
    _query = q;
    final generation = ++_generation;
    try {
      final page = await _repository.fetchConnections(
        key.creatorId,
        key.tab,
        query: q,
      );
      if (!ref.mounted || generation != _generation) return;
      _nextCursor = page.nextCursor;
      state = AsyncData(page.items);
    } catch (error, stack) {
      if (!ref.mounted || generation != _generation) return;
      state = AsyncError(error, stack);
    }
  }

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final items = state.value;
    final cursor = _nextCursor;
    if (items == null || cursor == null || _loadingMore) return;
    final generation = _generation;
    _loadingMore = true;
    try {
      final page = await _repository.fetchConnections(
        key.creatorId,
        key.tab,
        query: _query,
        cursor: cursor,
      );
      if (!ref.mounted || generation != _generation) return;
      _nextCursor = page.nextCursor;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }
}

/// Header name and the two counts: the signed-in user's (`null`) from
/// `currentUserProvider`, anyone else's from their profile.
final connectionsOwnerProvider = FutureProvider.autoDispose
    .family<ConnectionsOwner, String?>((ref, creatorId) async {
      if (creatorId == null) {
        final me = await ref.watch(currentUserProvider.future);
        return ConnectionsOwner(
          name: me.fullName,
          followers: me.followers,
          following: me.following,
        );
      }
      final following = ref.watch(
        followingProvider.select((ids) => ids.contains(creatorId)),
      );
      final creator = await ref.watch(creatorProfileProvider(creatorId).future);
      return ConnectionsOwner(
        name: creator.name,
        followers: creator.followersWhen(following: following),
        following: creator.following,
      );
    });
