import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/search/data/models/search_models.dart';
import 'package:starapp/features/search/data/repositories/api_search_repository.dart';
import 'package:starapp/features/search/data/repositories/mock_search_repository.dart';
import 'package:starapp/features/search/data/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockSearchRepository.new,
    api: ApiSearchRepository.new,
  ),
);

final trendingSearchesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(searchRepositoryProvider).fetchTrendingSearches(),
);

/// Creators and challenges matching a (trimmed, non-empty) query. Disposed
/// once no screen shows that query, so typing doesn't pile up results.
final searchResultsProvider = FutureProvider.autoDispose
    .family<SearchResults, String>(
      (ref, query) => ref.watch(searchRepositoryProvider).search(query),
    );

/// The user's recent searches, newest first. Changes show at once and roll
/// back if the server rejects them.
final recentSearchesProvider =
    AsyncNotifierProvider<RecentSearchesNotifier, List<String>>(
      RecentSearchesNotifier.new,
    );

class RecentSearchesNotifier extends AsyncNotifier<List<String>> {
  /// How many searches are shown.
  static const maxCount = 8;

  SearchRepository get _repository => ref.read(searchRepositoryProvider);

  @override
  Future<List<String>> build() =>
      ref.watch(searchRepositoryProvider).fetchRecentSearches();

  /// Records [term] at the top, dropping an earlier copy (in any letter case)
  /// and anything beyond [maxCount].
  Future<void> add(String term) async {
    final recent = state.value ?? const <String>[];
    await _optimistic(
      [
        term,
        ...recent.where((r) => r.toLowerCase() != term.toLowerCase()),
      ].take(maxCount).toList(),
      () => _repository.addRecentSearch(term),
    );
  }

  Future<void> remove(String term) async {
    final recent = state.value;
    if (recent == null || !recent.contains(term)) return;
    await _optimistic(
      [...recent]..remove(term),
      () => _repository.removeRecentSearch(term),
    );
  }

  Future<void> clear() async {
    if (state.value?.isEmpty ?? true) return;
    await _optimistic(const [], _repository.clearRecentSearches);
  }

  Future<void> _optimistic(
    List<String> next,
    Future<void> Function() request,
  ) async {
    final previous = state;
    state = AsyncData(next);
    try {
      await request();
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}
