import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/features/settings/data/repositories/mock_settings_repository.dart';

void main() {
  const repository = MockSettingsRepository();

  test('the fixtures parse and cover what the screens show', () async {
    final preferences = await repository.fetchPreferences();
    final privacy = await repository.fetchPrivacySettings();
    final details = await repository.fetchProfileDetails();
    final talents = await repository.fetchTalentCatalogue();
    final media = await repository.fetchProfileMedia();

    expect(preferences.language, 'en-GB');
    expect(privacy.whoCanMessage, WhoCanMessage.everyone);
    expect(privacy.passwordChangedAt, isNotNull);
    expect(details.portfolioLink, isNotEmpty);
    expect(talents, isNotEmpty);
    expect(media.photoUrls, isNotEmpty);
    expect(media.coverUrls, isNotEmpty);
    expect(media.defaultCoverUrl, isNotNull);
  });

  test('toJson round-trips', () async {
    final preferences = await repository.fetchPreferences();
    final privacy = await repository.fetchPrivacySettings();
    final details = await repository.fetchProfileDetails();
    final media = await repository.fetchProfileMedia();

    expect(
      AppPreferences.fromJson(preferences.toJson()).toJson(),
      preferences.toJson(),
    );
    expect(
      PrivacySettings.fromJson(privacy.toJson()).toJson(),
      privacy.toJson(),
    );
    expect(
      ProfileDetails.fromJson(details.toJson()).toJson(),
      details.toJson(),
    );
    expect(
      ProfileMediaPresets.fromJson(media.toJson()).toJson(),
      media.toJson(),
    );
    for (final t in await repository.fetchTalentCatalogue()) {
      expect(Talent.fromJson(t.toJson()).toJson(), t.toJson());
    }
  });

  test('who can message is sent by its name', () {
    final privacy = PrivacySettings.fromJson({'whoCanMessage': 'noOne'});
    expect(privacy.whoCanMessage, WhoCanMessage.noOne);
    expect(
      privacy
          .copyWith(whoCanMessage: WhoCanMessage.following)
          .toJson()['whoCanMessage'],
      'following',
    );
    expect(
      PrivacySettings.fromJson({'whoCanMessage': 'somethingNew'}).whoCanMessage,
      WhoCanMessage.everyone,
    );
  });
}
