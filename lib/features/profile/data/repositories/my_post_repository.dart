import 'package:starapp/features/profile/data/models/my_post.dart';

/// The signed-in user's own posts. Screens read `myPostProvider` /
/// `myPostInteractionsProvider`; `myPostRepositoryProvider` picks the mock
/// or API implementation.
abstract interface class MyPostRepository {
  Future<MyPost> fetchPost(String id);

  Future<void> setStarred(String postId, {required bool starred});

  Future<void> setSaved(String postId, {required bool saved});

  Future<void> deletePost(String postId);
}
