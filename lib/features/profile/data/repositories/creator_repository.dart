import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';

/// Other creators' public profiles. Screens read `creatorProfileProvider`
/// and `creatorPostsProvider`; `creatorRepositoryProvider` picks the mock or
/// API implementation.
abstract interface class CreatorRepository {
  Future<CreatorProfile> fetchCreator(String creatorId);

  /// Newest first; pass the previous page's `nextCursor` for the next one.
  Future<Paged<CreatorPost>> fetchPosts(String creatorId, {String? cursor});
}
