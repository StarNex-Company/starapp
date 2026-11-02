import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';

/// The signed-in creator's own profile content. Screens read the providers
/// in `my_profile_providers.dart`; `myProfileRepositoryProvider` picks the
/// mock or API implementation.
abstract interface class MyProfileRepository {
  /// Tier progress, passport summary, challenge history and stats.
  Future<MyProfile> fetchMyProfile();

  /// The profile grid, newest first; pass the previous page's `nextCursor`
  /// for the next one.
  Future<Paged<ProfileGridPost>> fetchPosts({String? cursor});

  /// The live figures on the Shortcuts page.
  Future<ShortcutsSummary> fetchShortcuts();
}
