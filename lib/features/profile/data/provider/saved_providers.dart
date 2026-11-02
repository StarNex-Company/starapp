import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/profile/data/models/saved_item.dart';
import 'package:starapp/features/profile/data/repositories/api_saved_repository.dart';
import 'package:starapp/features/profile/data/repositories/mock_saved_repository.dart';
import 'package:starapp/features/profile/data/repositories/saved_repository.dart';

final savedRepositoryProvider = Provider<SavedRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockSavedRepository.new,
    api: ApiSavedRepository.new,
  ),
);

/// The signed-in user's saved posts of one kind (null for all), filtered by
/// the server. Dropped when no longer shown, so switching back to a filter
/// fetches it afresh. [SavedItemsNotifier.loadMore] appends the next page;
/// [SavedItemsNotifier.unsave] removes a post at once and puts it back if
/// the server rejects it.
final savedItemsProvider = AsyncNotifierProvider.autoDispose
    .family<SavedItemsNotifier, SavedItems, SavedKind?>(SavedItemsNotifier.new);

class SavedItemsNotifier extends AsyncNotifier<SavedItems> {
  SavedItemsNotifier(this.type);

  final SavedKind? type;
  bool _loadingMore = false;

  SavedRepository get _repository => ref.read(savedRepositoryProvider);

  @override
  Future<SavedItems> build() =>
      ref.watch(savedRepositoryProvider).fetchSaved(type: type);

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final saved = state.value;
    final cursor = saved?.nextCursor;
    if (saved == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _repository.fetchSaved(type: type, cursor: cursor);
      state = AsyncData(
        saved.copyWith(
          items: [...saved.items, ...page.items],
          total: page.total,
          nextCursor: page.nextCursor,
        ),
      );
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> unsave(String postId) async {
    final saved = state.value;
    if (saved == null) return;
    final index = saved.items.indexWhere((item) => item.id == postId);
    if (index < 0) return;
    final removed = saved.items[index];
    state = AsyncData(
      saved.copyWith(
        items: [...saved.items]..removeAt(index),
        total: saved.total - 1,
        nextCursor: saved.nextCursor,
      ),
    );
    try {
      await _repository.unsave(postId);
    } catch (_) {
      final current = state.value ?? saved;
      state = AsyncData(
        current.copyWith(
          items: [...current.items]
            ..insert(index.clamp(0, current.items.length), removed),
          total: current.total + 1,
          nextCursor: current.nextCursor,
        ),
      );
      rethrow;
    }
  }
}
