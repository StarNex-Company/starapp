import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/utils/json.dart';

/// Progress from the current tier to the next one. Shown on My Profile's
/// tier card and on Star Insights' Total Stars card.
class TierProgress {
  const TierProgress({
    required this.nextTier,
    required this.progress,
    required this.starsToNext,
    this.nextPerk = '',
    this.topPercent,
    this.region = '',
  });

  factory TierProgress.fromJson(Json json) => TierProgress(
    nextTier: readEnumOrNull(CreatorTier.values, json['nextTier']),
    progress: readDouble(json['progress']).clamp(0.0, 1.0),
    starsToNext: readInt(json['starsToNext']),
    nextPerk: json['nextPerk'] as String? ?? '',
    topPercent: json['topPercent'] == null ? null : readInt(json['topPercent']),
    region: json['region'] as String? ?? '',
  );

  /// Null at the top tier.
  final CreatorTier? nextTier;

  /// 0–1 through the current tier.
  final double progress;
  final int starsToNext;

  /// The next tier's headline perk, e.g. "priority placement".
  final String nextPerk;

  /// The creator's rank as a top percentage of [region]: 4 is "Top 4% in
  /// Nigeria". Null while unranked.
  final int? topPercent;
  final String region;

  Json toJson() => {
    'nextTier': nextTier?.name,
    'progress': progress,
    'starsToNext': starsToNext,
    'nextPerk': nextPerk,
    'topPercent': topPercent,
    'region': region,
  };
}

/// The AI Talent Passport's score components. Serialized by name.
enum PassportMetricKind {
  consistency('Consistency'),
  engagement('Engagement'),
  improvement('Improvement'),
  challenge('Challenge');

  const PassportMetricKind(this.label);

  final String label;
}

/// One score component, e.g. Consistency 96%.
class PassportMetric {
  const PassportMetric(this.kind, this.percent);

  /// Null for a kind this app version doesn't know, so lists can skip it.
  static PassportMetric? maybeFromJson(Json json) {
    final kind = readEnumOrNull(PassportMetricKind.values, json['kind']);
    return kind == null ? null : PassportMetric(kind, readInt(json['percent']));
  }

  /// The known metrics in [value]; unknown kinds are dropped.
  static List<PassportMetric> readAll(Object? value) =>
      readList(value, maybeFromJson).nonNulls.toList();

  final PassportMetricKind kind;

  /// 0–100.
  final int percent;

  Json toJson() => {'kind': kind.name, 'percent': percent};
}
