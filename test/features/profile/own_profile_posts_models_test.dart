import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/features/profile/data/models/my_post.dart';
import 'package:starapp/features/profile/data/models/saved_item.dart';
import 'package:starapp/features/profile/data/provider/my_post_providers.dart';
import 'package:starapp/features/profile/data/provider/saved_providers.dart';
import 'package:starapp/features/profile/data/repositories/mock_my_post_repository.dart';
import 'package:starapp/features/profile/data/repositories/mock_saved_repository.dart';
import 'package:starapp/features/profile/data/repositories/my_post_repository.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_style.dart';

void main() {
  group('My post', () {
    test('a post parses, falls back for unknown ids and round-trips', () async {
      const repository = MockMyPostRepository();
      final post = await repository.fetchPost('gbedu-dance-cover');

      expect(post.title, 'Gbedu dance cover');
      expect(post.duration, const Duration(seconds: 12));
      expect(post.posterUrl, isNotNull);
      expect((await repository.fetchPost('nope')).id, 'late-night-vocal-run');
      expect(MyPost.fromJson(post.toJson()).toJson(), post.toJson());
    });

    test('a failed star rolls back and rethrows', () async {
      final container = ProviderContainer(
        overrides: [
          myPostRepositoryProvider.overrideWithValue(_FailingPosts()),
        ],
      );
      addTearDown(container.dispose);
      final post = await const MockMyPostRepository().fetchPost(
        'late-night-vocal-run',
      );
      final notifier = container.read(myPostInteractionsProvider.notifier);

      final star = notifier.toggleStar(post);
      expect(container.read(myPostInteractionsProvider).starsOf(post), 1099);
      await expectLater(star, throwsStateError);
      expect(container.read(myPostInteractionsProvider).isStarred(post), false);
      expect(container.read(myPostInteractionsProvider).starsOf(post), 1098);

      await expectLater(notifier.delete(post.id), throwsStateError);
      expect(container.read(myPostInteractionsProvider).deleted, isEmpty);
    });
  });

  group('Saved', () {
    test('pages parse, filter by type and round-trip', () async {
      const repository = MockSavedRepository();
      final first = await repository.fetchSaved();

      expect(first.items, hasLength(6));
      expect(first.hasMore, isTrue);
      expect(first.total, 8);
      final second = await repository.fetchSaved(cursor: first.nextCursor);
      expect(second.items, hasLength(2));
      expect(second.hasMore, isFalse);

      final all = [...first.items, ...second.items];
      expect({for (final i in all) i.kind}, SavedKind.values.toSet());
      expect({
        for (final i in all) formatSavedWhen(i.savedAt),
      }, containsAll(['this week', 'last week']));

      final audio = await repository.fetchSaved(type: SavedKind.audio);
      expect(audio.items.every((i) => i.kind == SavedKind.audio), isTrue);
      expect(audio.total, audio.items.length);

      expect(SavedItems.fromJson(first.toJson()).toJson(), first.toJson());
    });

    test('loadMore appends and unsave removes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = savedItemsProvider(null);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await container.read(provider.future);
      await container.read(provider.notifier).loadMore();
      expect(container.read(provider).value!.items, hasLength(8));

      await container.read(provider.notifier).unsave('sahel-soul');
      final saved = container.read(provider).value!;
      expect(saved.items.map((i) => i.id), isNot(contains('sahel-soul')));
      expect(saved.total, 7);
    });

    test('formatSavedWhen names the week, then the month', () {
      final now = DateTime(2026, 11, 20);
      expect(formatSavedWhen(DateTime(2026, 11, 18), now: now), 'this week');
      expect(formatSavedWhen(DateTime(2026, 11, 10), now: now), 'last week');
      expect(formatSavedWhen(DateTime(2026, 10, 2), now: now), 'in October');
      expect(
        formatSavedWhen(DateTime(2025, 10, 2), now: now),
        'in October 2025',
      );
    });
  });
}

class _FailingPosts implements MyPostRepository {
  @override
  Future<MyPost> fetchPost(String id) =>
      const MockMyPostRepository().fetchPost(id);

  @override
  Future<void> setStarred(String postId, {required bool starred}) async =>
      throw StateError('offline');

  @override
  Future<void> setSaved(String postId, {required bool saved}) async =>
      throw StateError('offline');

  @override
  Future<void> deletePost(String postId) async => throw StateError('offline');
}
