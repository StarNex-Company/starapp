import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/profile/data/models/my_post.dart';
import 'package:starapp/features/profile/data/repositories/api_my_post_repository.dart';
import 'package:starapp/features/profile/data/repositories/mock_my_post_repository.dart';
import 'package:starapp/features/profile/data/repositories/my_post_repository.dart';

final myPostRepositoryProvider = Provider<MyPostRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockMyPostRepository.new,
    api: ApiMyPostRepository.new,
  ),
);

/// One of the user's posts by id.
final myPostProvider = FutureProvider.family<MyPost, String>(
  (ref, id) => ref.watch(myPostRepositoryProvider).fetchPost(id),
);

/// Stars, saves and deletions on the user's own posts, shared so a post
/// deleted here disappears wherever the posts are listed. Each change shows
/// at once and rolls back, rethrowing, if the server rejects it.
final myPostInteractionsProvider =
    NotifierProvider<MyPostInteractionsNotifier, MyPostInteractions>(
      MyPostInteractionsNotifier.new,
    );

class MyPostInteractionsNotifier extends Notifier<MyPostInteractions> {
  MyPostRepository get _repository => ref.read(myPostRepositoryProvider);

  @override
  MyPostInteractions build() => const MyPostInteractions();

  /// Stars or un-stars [post].
  Future<void> toggleStar(MyPost post) async {
    final before = state.starred;
    final starred = !state.isStarred(post);
    state = state.copyWith(starred: {...before, post.id: starred});
    try {
      await _repository.setStarred(post.id, starred: starred);
    } catch (_) {
      state = state.copyWith(starred: _restore(state.starred, before, post.id));
      rethrow;
    }
  }

  /// Saves or un-saves [post].
  Future<void> toggleSave(MyPost post) async {
    final before = state.saved;
    final saved = !state.isSaved(post);
    state = state.copyWith(saved: {...before, post.id: saved});
    try {
      await _repository.setSaved(post.id, saved: saved);
    } catch (_) {
      state = state.copyWith(saved: _restore(state.saved, before, post.id));
      rethrow;
    }
  }

  Future<void> delete(String postId) async {
    state = state.copyWith(deleted: {...state.deleted, postId});
    try {
      await _repository.deletePost(postId);
    } catch (_) {
      state = state.copyWith(deleted: {...state.deleted}..remove(postId));
      rethrow;
    }
  }

  /// [current] with [id] put back as it was in [before], leaving changes to
  /// other posts made in the meantime.
  static Map<String, bool> _restore(
    Map<String, bool> current,
    Map<String, bool> before,
    String id,
  ) {
    final restored = {...current}..remove(id);
    if (before[id] case final value?) restored[id] = value;
    return restored;
  }
}
