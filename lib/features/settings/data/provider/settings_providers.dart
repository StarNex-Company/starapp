import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/core/session/data/repositories/session_repository.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/features/settings/data/repositories/api_settings_repository.dart';
import 'package:starapp/features/settings/data/repositories/mock_settings_repository.dart';
import 'package:starapp/features/settings/data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockSettingsRepository.new,
    api: ApiSettingsRepository.new,
  ),
);

/// The top-level fields of [after] that differ from [before]: what a PATCH
/// sends.
Json _changes(Json before, Json after) => {
  for (final MapEntry(:key, :value) in after.entries)
    if (before[key] != value) key: value,
};

/// Settings ▸ Preferences (autoplay, language; dark mode is not built).
/// Changes show at once and roll back if the server rejects them.
final preferencesProvider =
    AsyncNotifierProvider<PreferencesNotifier, AppPreferences>(
      PreferencesNotifier.new,
    );

class PreferencesNotifier extends AsyncNotifier<AppPreferences> {
  @override
  Future<AppPreferences> build() =>
      ref.watch(settingsRepositoryProvider).fetchPreferences();

  Future<void> setAutoplayVideos(bool value) async {
    final current = state.value;
    if (current == null) return;
    final next = current.copyWith(autoplayVideos: value);
    final changes = _changes(current.toJson(), next.toJson());
    if (changes.isEmpty) return;
    state = AsyncData(next);
    try {
      await ref.read(settingsRepositoryProvider).updatePreferences(changes);
    } catch (_) {
      if (ref.mounted) state = AsyncData(current);
      rethrow;
    }
  }
}

/// Settings ▸ Privacy & Security, shared with the Settings "Private profile"
/// toggle. Changes show at once and roll back if the server rejects them.
final privacySettingsProvider =
    AsyncNotifierProvider<PrivacySettingsNotifier, PrivacySettings>(
      PrivacySettingsNotifier.new,
    );

class PrivacySettingsNotifier extends AsyncNotifier<PrivacySettings> {
  @override
  Future<PrivacySettings> build() =>
      ref.watch(settingsRepositoryProvider).fetchPrivacySettings();

  Future<void> setPrivateAccount(bool value) =>
      _update((s) => s.copyWith(privateAccount: value));

  Future<void> setShowInScoutSearch(bool value) =>
      _update((s) => s.copyWith(showInScoutSearch: value));

  Future<void> setTwoFactorAuth(bool value) =>
      _update((s) => s.copyWith(twoFactorAuth: value));

  Future<void> setLiteMode(bool value) =>
      _update((s) => s.copyWith(liteMode: value));

  Future<void> setWhoCanMessage(WhoCanMessage value) =>
      _update((s) => s.copyWith(whoCanMessage: value));

  Future<void> _update(PrivacySettings Function(PrivacySettings) change) async {
    final current = state.value;
    if (current == null) return;
    final next = change(current);
    final changes = _changes(current.toJson(), next.toJson());
    if (changes.isEmpty) return;
    state = AsyncData(next);
    try {
      await ref.read(settingsRepositoryProvider).updatePrivacySettings(changes);
    } catch (_) {
      if (ref.mounted) state = AsyncData(current);
      rethrow;
    }
  }
}

/// Edit Profile's portfolio link and "Open to opportunities" (the rest of the
/// profile is the core `currentUserProvider`).
final profileDetailsProvider =
    AsyncNotifierProvider<ProfileDetailsNotifier, ProfileDetails>(
      ProfileDetailsNotifier.new,
    );

class ProfileDetailsNotifier extends AsyncNotifier<ProfileDetails> {
  @override
  Future<ProfileDetails> build() =>
      ref.watch(settingsRepositoryProvider).fetchProfileDetails();

  /// Shows [details] at once; on failure the previous details come back and
  /// the error is rethrown for the screen to show.
  Future<void> save(ProfileDetails details) async {
    final current = state.value;
    final changes = _changes(current?.toJson() ?? const {}, details.toJson());
    if (changes.isEmpty) return;
    final previous = state;
    state = AsyncData(details);
    try {
      await ref.read(settingsRepositoryProvider).updateProfileDetails(changes);
    } catch (_) {
      if (ref.mounted) state = previous;
      rethrow;
    }
  }
}

/// Talents offered by the Add Talent sheet.
final talentCatalogueProvider = FutureProvider<List<Talent>>(
  (ref) => ref.watch(settingsRepositoryProvider).fetchTalentCatalogue(),
);

/// Sample photos and covers the Change Photo / Change Cover sheets pick from.
final profileMediaProvider = FutureProvider<ProfileMediaPresets>(
  (ref) => ref.watch(settingsRepositoryProvider).fetchProfileMedia(),
);

/// Turns Edit Profile's photo and cover choices into URLs to save.
final profileImageUploaderProvider = Provider<ProfileImageUploader>(
  (ref) => ProfileImageUploader(ref.watch(sessionRepositoryProvider)),
);

/// Uploads a photo or cover picked from the device; preset images and URLs
/// the profile already has pass through as they are.
class ProfileImageUploader {
  const ProfileImageUploader(this._session);

  final SessionRepository _session;

  /// A file on the device rather than a URL or a bundled preset.
  static bool isLocalFile(String? image) =>
      image != null &&
      image.isNotEmpty &&
      !image.startsWith('assets/') &&
      !image.startsWith('http://') &&
      !image.startsWith('https://');

  Future<String?> avatar(String? image) async =>
      isLocalFile(image) ? _session.uploadAvatar(image!) : image;

  Future<String?> cover(String? image) async =>
      isLocalFile(image) ? _session.uploadCover(image!) : image;
}
