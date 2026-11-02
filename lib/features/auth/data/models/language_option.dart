import 'dart:ui' show Locale;

import 'package:starapp/core/utils/json.dart';

/// One row of the language list (`GET /languages`).
class LanguageOption {
  const LanguageOption({
    required this.name,
    required this.englishName,
    required this.region,
    required this.locale,
  });

  factory LanguageOption.fromJson(Json json) => LanguageOption(
    name: json['name'] as String,
    englishName: json['englishName'] as String? ?? json['name'] as String,
    region: json['region'] as String? ?? '',
    locale: _parseLocale(json['locale'] as String),
  );

  /// Native name, shown as the row title ("Français").
  final String name;

  /// English name, also matched by the search ("French").
  final String englishName;

  /// Second line ("Canada").
  final String region;

  /// Locale saved by Done (language + region; the locale provider persists
  /// the language code). Sent as a BCP 47 tag, e.g. `"fr-CA"`.
  final Locale locale;

  Json toJson() => {
    'name': name,
    'englishName': englishName,
    'region': region,
    'locale': locale.toLanguageTag(),
  };
}

/// `"fr-CA"`, `"fr_CA"`, `"zh-Hans-CN"` or `"es"` → [Locale].
Locale _parseLocale(String tag) {
  final parts = tag.split(RegExp('[-_]'));
  String? script;
  String? country;
  for (final part in parts.skip(1)) {
    if (part.length == 4) {
      script = part;
    } else {
      country = part;
    }
  }
  return Locale.fromSubtags(
    languageCode: parts.first,
    scriptCode: script,
    countryCode: country,
  );
}
