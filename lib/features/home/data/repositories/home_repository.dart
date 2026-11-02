import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/home/data/models/feed_category.dart';
import 'package:starapp/features/home/data/models/home_feed.dart';
import 'package:starapp/features/home/data/models/post.dart';

/// The home tab's content and the user's reactions to it. Screens read
/// `homeFeedProvider`; `homeRepositoryProvider` picks the mock or API
/// implementation. Follows go through the shared `followingProvider`.
abstract interface class HomeRepository {
  /// Stories, trending talents and suggested creators.
  Future<HomeSections> fetchSections();

  /// Posts for [category], newest first; pass the previous page's
  /// `nextCursor` for the next one.
  Future<Paged<Post>> fetchPosts({
    FeedCategory category = FeedCategory.following,
    String? cursor,
  });

  Future<void> setStarred(String postId, {required bool starred});

  Future<void> setBookmarked(String postId, {required bool bookmarked});

  /// Files a report on the post, or withdraws it.
  Future<void> setReported(String postId, {required bool reported});

  /// Stops suggesting this creator.
  Future<void> hideSuggestion(String creatorId);
}
