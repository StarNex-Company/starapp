import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/utils/json.dart';

/// The tier the user just reached, what it unlocks and how far into it they
/// are (`GET /me/tier`).
class TierLevelUp {
  const TierLevelUp({
    required this.tier,
    required this.minStars,
    required this.maxStars,
    required this.stars,
    this.blurb = '',
    this.perks = const [],
  });

  factory TierLevelUp.fromJson(Json json) => TierLevelUp(
    tier: readEnum(CreatorTier.values, json['tier'], CreatorTier.shootingStar),
    minStars: readInt(json['minStars']),
    maxStars: readInt(json['maxStars']),
    stars: readInt(json['stars']),
    blurb: json['blurb'] as String? ?? '',
    perks: readStrings(json['perks']),
  );

  final CreatorTier tier;

  /// The tier's Star range, inclusive.
  final int minStars;
  final int maxStars;

  /// The user's Stars now.
  final int stars;
  final String blurb;

  /// What the tier unlocks.
  final List<String> perks;

  /// 0..1 through [tier].
  double get progress =>
      maxStars < minStars ? 1 : (stars - minStars) / (maxStars + 1 - minStars);

  Json toJson() => {
    'tier': tier.name,
    'minStars': minStars,
    'maxStars': maxStars,
    'stars': stars,
    'blurb': blurb,
    'perks': perks,
  };
}
