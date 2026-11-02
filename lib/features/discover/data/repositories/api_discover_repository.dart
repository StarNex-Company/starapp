import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/data/repositories/discover_repository.dart';

class ApiDiscoverRepository implements DiscoverRepository {
  const ApiDiscoverRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<DiscoverCategory>> fetchCategories() => _client.get(
    '/discover/categories',
    decode: (json) => readList(json, DiscoverCategory.fromJson),
  );

  @override
  Future<List<RisingCreator>> fetchRisingCreators() => _client.get(
    '/discover/rising',
    decode: (json) => readList(json, RisingCreator.fromJson),
  );

  @override
  Future<List<SuggestedCreator>> fetchSuggestedCreators() => _client.get(
    '/discover/suggestions',
    decode: (json) => readList(json, SuggestedCreator.fromJson),
  );

  @override
  Future<void> dismissSuggestion(String creatorId) =>
      _client.post<void>('/discover/suggestions/$creatorId/dismiss');

  @override
  Future<List<FeaturedChallenge>> fetchFeaturedChallenges() => _client.get(
    '/discover/challenges',
    decode: (json) => readList(json, FeaturedChallenge.fromJson),
  );

  @override
  Future<Paged<DiscoverVideo>> fetchVideos({
    String? category,
    DiscoverFilters filters = const DiscoverFilters(),
    String? cursor,
  }) => _client.get(
    '/discover/videos',
    query: {
      'category': category,
      'country': filters.country == FilterCountry.all
          ? null
          : filters.country.name,
      'sort': filters.sort.name,
      'cursor': cursor,
    },
    decode: (json) => Paged.fromJson(json as Json, DiscoverVideo.fromJson),
  );

  @override
  Future<void> setSaved(String videoId, {required bool saved}) => saved
      ? _client.put<void>('/videos/$videoId/save')
      : _client.delete<void>('/videos/$videoId/save');
}
