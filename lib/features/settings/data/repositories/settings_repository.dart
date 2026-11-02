import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/settings/data/models/settings.dart';

/// The user's settings. Screens read the providers in
/// `settings_providers.dart`; `settingsRepositoryProvider` picks the mock or
/// API implementation.
///
/// The `update…` calls send only the fields that changed, e.g.
/// `{"whoCanMessage": "following"}`.
abstract interface class SettingsRepository {
  Future<AppPreferences> fetchPreferences();

  Future<void> updatePreferences(Json changes);

  Future<PrivacySettings> fetchPrivacySettings();

  Future<void> updatePrivacySettings(Json changes);

  Future<ProfileDetails> fetchProfileDetails();

  Future<void> updateProfileDetails(Json changes);

  /// Talents offered by the Add Talent sheet, in display order.
  Future<List<Talent>> fetchTalentCatalogue();

  Future<ProfileMediaPresets> fetchProfileMedia();
}
