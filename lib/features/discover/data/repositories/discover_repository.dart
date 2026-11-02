import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';

/// The Discover tab's content. Screens read the providers in
/// `discover_providers.dart`; `discoverRepositoryProvider` picks the mock or
/// API implementation.
abstract interface class DiscoverRepository {
  /// Talent category pills, in display order.
  Future<List<DiscoverCategory>> fetchCategories();

  /// Creators in the RISING CREATORS story rail.
  Future<List<RisingCreator>> fetchRisingCreators();

  /// Creators suggested to follow, best match first.
  Future<List<SuggestedCreator>> fetchSuggestedCreators();

  /// Stops suggesting [creatorId].
  Future<void> dismissSuggestion(String creatorId);

  Future<List<FeaturedChallenge>> fetchFeaturedChallenges();

  /// Talent videos for the grid, narrowed to [category] (null for all) and
  /// [filters]; pass the previous page's `nextCursor` for the next one.
  Future<Paged<DiscoverVideo>> fetchVideos({
    String? category,
    DiscoverFilters filters = const DiscoverFilters(),
    String? cursor,
  });

  /// Bookmarks [videoId], or removes the bookmark.
  Future<void> setSaved(String videoId, {required bool saved});
}
