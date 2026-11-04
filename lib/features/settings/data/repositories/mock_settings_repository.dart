import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/features/settings/data/repositories/settings_repository.dart';

/// Serves the fixtures below, shaped like the API responses, through the
/// real `fromJson`. Updates are accepted and dropped.
class MockSettingsRepository implements SettingsRepository {
  const MockSettingsRepository();

  @override
  Future<AppPreferences> fetchPreferences() async =>
      AppPreferences.fromJson(_preferences);

  @override
  Future<void> updatePreferences(Json changes) async {}

  @override
  Future<PrivacySettings> fetchPrivacySettings() async =>
      PrivacySettings.fromJson(_privacy(DateTime.now()));

  @override
  Future<void> updatePrivacySettings(Json changes) async {}

  @override
  Future<ProfileDetails> fetchProfileDetails() async =>
      ProfileDetails.fromJson(_details);

  @override
  Future<void> updateProfileDetails(Json changes) async {}

  @override
  Future<List<Talent>> fetchTalentCatalogue() async =>
      readList(_talents, Talent.fromJson);

  @override
  Future<ProfileMediaPresets> fetchProfileMedia() async =>
      ProfileMediaPresets.fromJson(_media);
}

/// `GET /me/settings`.
const _preferences = {
  'autoplayVideos': false,
  'language': 'en-GB',
  'darkMode': false,
};

/// `GET /me/privacy`.
Json _privacy(DateTime now) => {
  'privateAccount': false,
  'showInScoutSearch': true,
  'twoFactorAuth': true,
  'liteMode': false,
  'whoCanMessage': 'everyone',
  'blockedAccounts': 3,
  'passwordChangedAt': now
      .subtract(const Duration(days: 64))
      .toUtc()
      .toIso8601String(),
  'activeSessions': 2,
};

/// `GET /me/profile-details`.
const _details = {
  'portfolioLink': 'emmanuelayanleye.1@gmail.com',
  'openToOpportunities': false,
};

/// `GET /talents`.
const _talents = [
  {'name': 'Singing', 'label': 'Singing', 'emoji': '🎤'},
  {'name': 'Production', 'label': 'Music production', 'emoji': '🎧'},
  {'name': 'Songwriting', 'label': 'Songwriting', 'emoji': '✍️'},
  {'name': 'Dance', 'label': 'Dance', 'emoji': '💃'},
  {'name': 'Acting', 'label': 'Acting', 'emoji': '🎭'},
  {'name': 'Comedy', 'label': 'Comedy', 'emoji': '😂'},
  {'name': 'Photography', 'label': 'Photography', 'emoji': '📸'},
];

/// `GET /profile-media/presets`.
const _media = {
  'photoUrls': [
    'assets/images/shared/avatar_you.jpg',
    'assets/images/shared/entry_video_frame.jpg',
    'assets/images/shared/creator_amina.jpg',
  ],
  'coverUrls': [
    'assets/images/shared/hub_banner_concept_art.jpg',
    'assets/images/shared/arena_studio.jpg',
    'assets/images/stories/gallery_photo_wall.jpg',
  ],
  'defaultPhotoUrl': 'assets/images/auth_avatar_1.png',
  'defaultCoverUrl': 'assets/images/settings/settings_cover_default.jpg',
};
