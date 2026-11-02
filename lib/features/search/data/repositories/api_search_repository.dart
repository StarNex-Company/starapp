import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/search/data/models/search_models.dart';
import 'package:starapp/features/search/data/repositories/search_repository.dart';

class ApiSearchRepository implements SearchRepository {
  const ApiSearchRepository(this._client);

  final ApiClient _client;

  @override
  Future<SearchResults> search(String query) => _client.get(
    '/search',
    query: {'q': query},
    decode: (json) => SearchResults.fromJson(json as Json),
  );

  @override
  Future<List<String>> fetchTrendingSearches() =>
      _client.get('/search/trending', decode: readStrings);

  @override
  Future<List<String>> fetchRecentSearches() =>
      _client.get('/search/recent', decode: readStrings);

  @override
  Future<void> addRecentSearch(String term) =>
      _client.post<void>('/search/recent', data: {'term': term});

  @override
  Future<void> removeRecentSearch(String term) =>
      _client.delete<void>('/search/recent/${Uri.encodeComponent(term)}');

  @override
  Future<void> clearRecentSearches() => _client.delete<void>('/search/recent');
}
