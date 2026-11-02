import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/data/repositories/api_discover_repository.dart';
import 'package:starapp/features/discover/data/repositories/discover_repository.dart';
import 'package:starapp/features/discover/data/repositories/mock_discover_repository.dart';

final discoverRepositoryProvider = Provider<DiscoverRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockDiscoverRepository.new,
    api: ApiDiscoverRepository.new,
  ),
);

final discoverCategoriesProvider = FutureProvider<List<DiscoverCategory>>(
  (ref) => ref.watch(discoverRepositoryProvider).fetchCategories(),
);

/// The selected category pill's id; null is "All".
final discoverCategoryProvider =
    NotifierProvider<DiscoverCategoryNotifier, String?>(
      DiscoverCategoryNotifier.new,
    );

class DiscoverCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) => state = categoryId;
}

final risingCreatorsProvider = FutureProvider<List<RisingCreator>>(
  (ref) => ref.watch(discoverRepositoryProvider).fetchRisingCreators(),
);

final featuredChallengesProvider = FutureProvider<List<FeaturedChallenge>>(
  (ref) => ref.watch(discoverRepositoryProvider).fetchFeaturedChallenges(),
);

/// Choices made in the Discover filters sheet; starts from the
/// [DiscoverFilters] defaults.
final discoverFiltersProvider =
    NotifierProvider<DiscoverFiltersNotifier, DiscoverFilters>(
      DiscoverFiltersNotifier.new,
    );

class DiscoverFiltersNotifier extends Notifier<DiscoverFilters> {
  @override
  DiscoverFilters build() => const DiscoverFilters();

  void apply(DiscoverFilters filters) => state = filters;
}

/// Creators suggested to follow, minus the ones dismissed. Shared by the
/// Discover carousel and the "Suggested for you" page so both stay in step;
/// follows go through the shared `followingProvider`.
final suggestedCreatorsProvider =
    AsyncNotifierProvider<SuggestedCreatorsNotifier, List<SuggestedCreator>>(
      SuggestedCreatorsNotifier.new,
    );

class SuggestedCreatorsNotifier extends AsyncNotifier<List<SuggestedCreator>> {
  DiscoverRepository get _repository => ref.read(discoverRepositoryProvider);

  @override
  Future<List<SuggestedCreator>> build() =>
      ref.watch(discoverRepositoryProvider).fetchSuggestedCreators();

  /// Drops [creatorId] at once; it comes back if the server rejects it.
  Future<void> dismiss(String creatorId) async {
    final creators = state.value;
    if (creators == null || !creators.any((c) => c.id == creatorId)) return;
    state = AsyncData([
      for (final c in creators)
        if (c.id != creatorId) c,
    ]);
    try {
      await _repository.dismissSuggestion(creatorId);
    } catch (_) {
      state = AsyncData(creators);
      rethrow;
    }
  }
}

/// Talent videos in the Discover grid for the selected category and
/// filters. [DiscoverVideosNotifier.loadMore] appends the next page.
final discoverVideosProvider =
    AsyncNotifierProvider<DiscoverVideosNotifier, List<DiscoverVideo>>(
      DiscoverVideosNotifier.new,
    );

class DiscoverVideosNotifier extends AsyncNotifier<List<DiscoverVideo>> {
  String? _nextCursor;
  bool _loadingMore = false;

  DiscoverRepository get _repository => ref.read(discoverRepositoryProvider);

  String? get _category => ref.read(discoverCategoryProvider);
  DiscoverFilters get _filters => ref.read(discoverFiltersProvider);

  @override
  Future<List<DiscoverVideo>> build() async {
    final page = await ref
        .watch(discoverRepositoryProvider)
        .fetchVideos(
          category: ref.watch(discoverCategoryProvider),
          filters: ref.watch(discoverFiltersProvider),
        );
    _nextCursor = page.nextCursor;
    return page.items;
  }

  bool get hasMore => _nextCursor != null;

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final videos = state.value;
    final cursor = _nextCursor;
    if (videos == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _repository.fetchVideos(
        category: _category,
        filters: _filters,
        cursor: cursor,
      );
      _nextCursor = page.nextCursor;
      state = AsyncData([...videos, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }

  /// Bookmarks [videoId], or removes the bookmark, at once; reverts if the
  /// server rejects it.
  Future<void> toggleSaved(String videoId) async {
    final videos = state.value;
    final video = videos?.where((v) => v.id == videoId).firstOrNull;
    if (videos == null || video == null) return;
    final saved = !video.isSaved;
    state = AsyncData([
      for (final v in videos) v.id == videoId ? v.copyWith(isSaved: saved) : v,
    ]);
    try {
      await _repository.setSaved(videoId, saved: saved);
    } catch (_) {
      state = AsyncData(videos);
      rethrow;
    }
  }
}
