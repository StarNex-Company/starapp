import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/data/repositories/api_my_profile_repository.dart';
import 'package:starapp/features/profile/data/repositories/mock_my_profile_repository.dart';
import 'package:starapp/features/profile/data/repositories/my_profile_repository.dart';

final myProfileRepositoryProvider = Provider<MyProfileRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockMyProfileRepository.new,
    api: ApiMyProfileRepository.new,
  ),
);

/// The own-profile content below the basics: tier progress, passport,
/// challenge history and stats. The basics (name, avatar, counts, tier)
/// come from `currentUserProvider`.
final myProfileProvider = FutureProvider<MyProfile>(
  (ref) => ref.watch(myProfileRepositoryProvider).fetchMyProfile(),
);

/// The profile's post grid. [MyProfilePostsNotifier.loadMore] appends the
/// next page.
final myProfilePostsProvider =
    AsyncNotifierProvider<MyProfilePostsNotifier, List<ProfileGridPost>>(
      MyProfilePostsNotifier.new,
    );

class MyProfilePostsNotifier extends AsyncNotifier<List<ProfileGridPost>> {
  String? _nextCursor;
  bool _loadingMore = false;

  @override
  Future<List<ProfileGridPost>> build() async {
    final page = await ref.watch(myProfileRepositoryProvider).fetchPosts();
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
          .read(myProfileRepositoryProvider)
          .fetchPosts(cursor: cursor);
      _nextCursor = page.nextCursor;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }
}

/// The live figures on the Shortcuts page, fetched afresh on each visit.
final shortcutsSummaryProvider = FutureProvider.autoDispose<ShortcutsSummary>(
  (ref) => ref.watch(myProfileRepositoryProvider).fetchShortcuts(),
);
