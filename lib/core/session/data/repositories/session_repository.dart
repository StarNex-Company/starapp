import 'package:starapp/core/session/data/models/current_user.dart';

/// The signed-in user and their social graph. Screens read
/// `currentUserProvider` / `followingProvider`; `sessionRepositoryProvider`
/// picks [MockSessionRepository] or `ApiSessionRepository` from `AppConfig`.
abstract interface class SessionRepository {
  Future<CurrentUser> fetchCurrentUser();

  /// Saves the editable fields (name, handle, bio, talents, photo, cover)
  /// and returns the stored user.
  Future<CurrentUser> updateProfile(CurrentUser user);

  /// Uploads a new profile photo or cover from a local file; returns its URL
  /// for [updateProfile].
  Future<String> uploadAvatar(String filePath);

  Future<String> uploadCover(String filePath);

  /// Ids of the creators the user follows.
  Future<Set<String>> fetchFollowing();

  Future<void> setFollowing(String creatorId, {required bool following});

  /// Ends the session on the server. The caller clears the stored token.
  Future<void> signOut();
}
