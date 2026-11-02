import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/features/settings/data/repositories/settings_repository.dart';

class ApiSettingsRepository implements SettingsRepository {
  const ApiSettingsRepository(this._client);

  final ApiClient _client;

  @override
  Future<AppPreferences> fetchPreferences() => _client.get(
    '/me/settings',
    decode: (json) => AppPreferences.fromJson(json as Json),
  );

  @override
  Future<void> updatePreferences(Json changes) =>
      _client.patch<void>('/me/settings', data: changes);

  @override
  Future<PrivacySettings> fetchPrivacySettings() => _client.get(
    '/me/privacy',
    decode: (json) => PrivacySettings.fromJson(json as Json),
  );

  @override
  Future<void> updatePrivacySettings(Json changes) =>
      _client.patch<void>('/me/privacy', data: changes);

  @override
  Future<ProfileDetails> fetchProfileDetails() => _client.get(
    '/me/profile-details',
    decode: (json) => ProfileDetails.fromJson(json as Json),
  );

  @override
  Future<void> updateProfileDetails(Json changes) =>
      _client.patch<void>('/me/profile-details', data: changes);

  @override
  Future<List<Talent>> fetchTalentCatalogue() => _client.get(
    '/talents',
    decode: (json) => readList(json, Talent.fromJson),
  );

  @override
  Future<ProfileMediaPresets> fetchProfileMedia() => _client.get(
    '/profile-media/presets',
    decode: (json) => ProfileMediaPresets.fromJson(json as Json),
  );
}
