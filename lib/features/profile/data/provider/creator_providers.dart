import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';
import 'package:starapp/features/profile/data/repositories/api_creator_repository.dart';
import 'package:starapp/features/profile/data/repositories/creator_repository.dart';
import 'package:starapp/features/profile/data/repositories/mock_creator_repository.dart';

final creatorRepositoryProvider = Provider<CreatorRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockCreatorRepository.new,
    api: ApiCreatorRepository.new,
  ),
);

/// A creator's public profile by id. Follow state isn't here: the page reads
/// `followingProvider`, so a follow anywhere shows everywhere.
final creatorProfileProvider = FutureProvider.autoDispose
    .family<CreatorProfile, String>(
      (ref, creatorId) =>
          ref.watch(creatorRepositoryProvider).fetchCreator(creatorId),
    );

/// The Content tab's videos, a page at a time; [CreatorPostsNotifier.loadMore]
/// appends the next page.
final creatorPostsProvider = AsyncNotifierProvider.autoDispose
    .family<CreatorPostsNotifier, List<CreatorPost>, String>(
      CreatorPostsNotifier.new,
    );

class CreatorPostsNotifier extends AsyncNotifier<List<CreatorPost>> {
  CreatorPostsNotifier(this.creatorId);

  final String creatorId;
  String? _nextCursor;
  bool _loadingMore = false;

  @override
  Future<List<CreatorPost>> build() async {
    final page = await ref
        .watch(creatorRepositoryProvider)
        .fetchPosts(creatorId);
    _nextCursor = page.nextCursor;
    return page.items;
  }

  bool get hasMore => _nextCursor != null;

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final items = state.value;
    final cursor = _nextCursor;
    if (items == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await ref
          .read(creatorRepositoryProvider)
          .fetchPosts(creatorId, cursor: cursor);
      if (!ref.mounted) return;
      _nextCursor = page.nextCursor;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }
}
