import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/utils/json.dart';

/// A person as every list shows them: feed authors, suggestions, search
/// results, leaderboards, followers, comments. The full profile is
/// `CreatorProfile` in the profile feature.
class CreatorSummary {
  const CreatorSummary({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarUrl,
    this.tier,
    this.isVerified = false,
  });

  factory CreatorSummary.fromJson(Json json) => CreatorSummary(
    id: json['id'] as String,
    name: json['name'] as String,
    handle: json['handle'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    tier: readEnumOrNull(CreatorTier.values, json['tier']),
    isVerified: json['isVerified'] as bool? ?? false,
  );

  final String id;
  final String name;

  /// Without the leading `@`.
  final String handle;

  /// Network URL (or an asset path in mock data); null shows a placeholder.
  final String? avatarUrl;
  final CreatorTier? tier;
  final bool isVerified;

  Json toJson() => {
    'id': id,
    'name': name,
    'handle': handle,
    'avatarUrl': avatarUrl,
    'tier': tier?.name,
    'isVerified': isVerified,
  };

  @override
  bool operator ==(Object other) =>
      other is CreatorSummary &&
      other.id == id &&
      other.name == name &&
      other.handle == handle &&
      other.avatarUrl == avatarUrl &&
      other.tier == tier &&
      other.isVerified == isVerified;

  @override
  int get hashCode =>
      Object.hash(id, name, handle, avatarUrl, tier, isVerified);
}
