import 'package:starapp/features/search/data/models/search_models.dart';

/// Search results and suggestions. Screens read the providers in
/// `search_providers.dart`; `searchRepositoryProvider` picks the mock or API
/// implementation.
abstract interface class SearchRepository {
  /// Creators and challenges matching [query].
  Future<SearchResults> search(String query);

  /// Popular terms for the trending chips.
  Future<List<String>> fetchTrendingSearches();

  /// The user's recent searches, newest first.
  Future<List<String>> fetchRecentSearches();

  Future<void> addRecentSearch(String term);

  Future<void> removeRecentSearch(String term);

  Future<void> clearRecentSearches();
}
