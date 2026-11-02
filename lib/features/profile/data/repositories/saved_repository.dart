import 'package:starapp/features/profile/data/models/saved_item.dart';

/// The signed-in user's saved posts. Screens read `savedItemsProvider`;
/// `savedRepositoryProvider` picks the mock or API implementation.
abstract interface class SavedRepository {
  /// Newest first, only [type] when given; pass the previous page's
  /// `nextCursor` for the next one.
  Future<SavedItems> fetchSaved({SavedKind? type, String? cursor});

  /// Removes the post with [postId] from Saved.
  Future<void> unsave(String postId);
}
