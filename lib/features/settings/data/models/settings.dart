import 'package:starapp/core/utils/json.dart';

/// Who may start a new conversation with the user.
enum WhoCanMessage { everyone, following, verifiedCompanies, noOne }

/// App-wide preferences from the Settings screen (`GET /me/settings`).
class AppPreferences {
  const AppPreferences({
    required this.autoplayVideos,
    required this.language,
    this.darkMode = false,
  });

  factory AppPreferences.fromJson(Json json) => AppPreferences(
    autoplayVideos: json['autoplayVideos'] as bool? ?? false,
    language: json['language'] as String? ?? 'en-GB',
    darkMode: json['darkMode'] as bool? ?? false,
  );

  /// Not built yet: the toggle stays off and says "Coming soon".
  final bool darkMode;
  final bool autoplayVideos;

  /// The app language as a BCP 47 tag, e.g. "en-GB".
  final String language;

  Json toJson() => {
    'autoplayVideos': autoplayVideos,
    'language': language,
    'darkMode': darkMode,
  };

  AppPreferences copyWith({bool? autoplayVideos}) => AppPreferences(
    darkMode: darkMode,
    autoplayVideos: autoplayVideos ?? this.autoplayVideos,
    language: language,
  );
}

/// Settings ▸ Privacy & Security (`GET /me/privacy`). The toggles and who
/// can message are editable; the other values are shown on rows whose own
/// screens come next.
class PrivacySettings {
  const PrivacySettings({
    required this.privateAccount,
    required this.showInScoutSearch,
    required this.twoFactorAuth,
    required this.liteMode,
    required this.whoCanMessage,
    this.blockedAccounts = 0,
    this.passwordChangedAt,
    this.activeSessions = 1,
  });

  factory PrivacySettings.fromJson(Json json) => PrivacySettings(
    privateAccount: json['privateAccount'] as bool? ?? false,
    showInScoutSearch: json['showInScoutSearch'] as bool? ?? true,
    twoFactorAuth: json['twoFactorAuth'] as bool? ?? false,
    liteMode: json['liteMode'] as bool? ?? false,
    whoCanMessage: readEnum(
      WhoCanMessage.values,
      json['whoCanMessage'],
      WhoCanMessage.everyone,
    ),
    blockedAccounts: readInt(json['blockedAccounts']),
    passwordChangedAt: readDate(json['passwordChangedAt']),
    activeSessions: readInt(json['activeSessions'], 1),
  );

  /// Only approved followers see posts. Also the Settings "Private profile"
  /// toggle.
  final bool privateAccount;
  final bool showInScoutSearch;
  final bool twoFactorAuth;
  final bool liteMode;
  final WhoCanMessage whoCanMessage;
  final int blockedAccounts;

  /// Null if the password was never changed.
  final DateTime? passwordChangedAt;
  final int activeSessions;

  Json toJson() => {
    'privateAccount': privateAccount,
    'showInScoutSearch': showInScoutSearch,
    'twoFactorAuth': twoFactorAuth,
    'liteMode': liteMode,
    'whoCanMessage': whoCanMessage.name,
    'blockedAccounts': blockedAccounts,
    'passwordChangedAt': passwordChangedAt?.toUtc().toIso8601String(),
    'activeSessions': activeSessions,
  };

  PrivacySettings copyWith({
    bool? privateAccount,
    bool? showInScoutSearch,
    bool? twoFactorAuth,
    bool? liteMode,
    WhoCanMessage? whoCanMessage,
  }) {
    return PrivacySettings(
      privateAccount: privateAccount ?? this.privateAccount,
      showInScoutSearch: showInScoutSearch ?? this.showInScoutSearch,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      liteMode: liteMode ?? this.liteMode,
      whoCanMessage: whoCanMessage ?? this.whoCanMessage,
      blockedAccounts: blockedAccounts,
      passwordChangedAt: passwordChangedAt,
      activeSessions: activeSessions,
    );
  }
}

/// The Edit Profile fields that aren't part of the core `CurrentUser`
/// (`GET /me/profile-details`).
class ProfileDetails {
  const ProfileDetails({
    required this.portfolioLink,
    required this.openToOpportunities,
  });

  factory ProfileDetails.fromJson(Json json) => ProfileDetails(
    portfolioLink: json['portfolioLink'] as String? ?? '',
    openToOpportunities: json['openToOpportunities'] as bool? ?? false,
  );

  final String portfolioLink;

  /// Companies can contact the creator.
  final bool openToOpportunities;

  Json toJson() => {
    'portfolioLink': portfolioLink,
    'openToOpportunities': openToOpportunities,
  };
}

/// One talent the creator can list on their profile (`GET /talents`).
class Talent {
  const Talent({required this.name, required this.label, required this.emoji});

  factory Talent.fromJson(Json json) => Talent(
    name: json['name'] as String,
    label: json['label'] as String? ?? json['name'] as String,
    emoji: json['emoji'] as String? ?? '',
  );

  /// Stored on the profile and shown on its chip, e.g. "Production".
  final String name;

  /// Shown in the Add Talent sheet, e.g. "Music production".
  final String label;
  final String emoji;

  Json toJson() => {'name': name, 'label': label, 'emoji': emoji};
}

/// Stand-ins for the camera and photo library (no picker plugin yet): the
/// Change Photo / Change Cover sheets pick from these
/// (`GET /profile-media/presets`).
class ProfileMediaPresets {
  const ProfileMediaPresets({
    required this.photoUrls,
    required this.coverUrls,
    required this.defaultPhotoUrl,
    required this.defaultCoverUrl,
  });

  factory ProfileMediaPresets.fromJson(Json json) => ProfileMediaPresets(
    photoUrls: readStrings(json['photoUrls']),
    coverUrls: readStrings(json['coverUrls']),
    defaultPhotoUrl: json['defaultPhotoUrl'] as String?,
    defaultCoverUrl: json['defaultCoverUrl'] as String?,
  );

  final List<String> photoUrls;
  final List<String> coverUrls;

  /// Shown after "Remove current photo".
  final String? defaultPhotoUrl;

  /// Shown while the profile has no cover of its own.
  final String? defaultCoverUrl;

  Json toJson() => {
    'photoUrls': photoUrls,
    'coverUrls': coverUrls,
    'defaultPhotoUrl': defaultPhotoUrl,
    'defaultCoverUrl': defaultCoverUrl,
  };
}
