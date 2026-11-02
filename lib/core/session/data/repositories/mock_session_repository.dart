import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/core/session/data/repositories/session_repository.dart';

/// Serves the fixture below, shaped like the `GET /me` response.
class MockSessionRepository implements SessionRepository {
  const MockSessionRepository();

  @override
  Future<CurrentUser> fetchCurrentUser() async => CurrentUser.fromJson(_me);

  @override
  Future<CurrentUser> updateProfile(CurrentUser user) async => user;

  /// Mock mode has no uploads; the picked file's path stands in for its URL.
  @override
  Future<String> uploadAvatar(String filePath) async => filePath;

  @override
  Future<String> uploadCover(String filePath) async => filePath;

  @override
  Future<Set<String>> fetchFollowing() async => _following;

  @override
  Future<void> setFollowing(
    String creatorId, {
    required bool following,
  }) async {}

  @override
  Future<void> signOut() async {}
}

const _me = {
  'id': 'emmanuel',
  'fullName': 'Emmanuel Ayanleye',
  'handle': 'emmanuel',
  'tier': 'risingNova',
  'avatarUrl': 'assets/images/home/avatar_you.jpg',
  'coverUrl': null,
  'location': 'Lagos, Nigeria',
  'bio':
      'Singer & producer making Afro-beats with a soul twist 🎤 Chasing my '
      'first Arena win this October.',
  'talents': ['Singing', 'Production', 'Songwriting'],
  'stars': 1280,
  'followers': 842,
  'following': 316,
  'posts': 14,
  'isVerified': true,
  'isCreator': true,
};

/// `GET /me/following/ids`.
const _following = {
  'amina',
  'efe-okafor',
  'ayeni',
  'silver-sonik',
  'kola-bankole',
  'tunde-beats',
  'maya-lin',
  'david-cole',
  'sarah-angel',
};
