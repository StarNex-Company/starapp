import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';

/// A talent category pill on the Discover tab (`GET /discover/categories`).
/// The "All" pill is the app's own and isn't sent.
class DiscoverCategory {
  const DiscoverCategory({required this.id, required this.name});

  factory DiscoverCategory.fromJson(Json json) => DiscoverCategory(
    id: json['id'] as String,
    name: json['name'] as String,
  );

  /// Stable slug, e.g. `"music"`; also picks the pill's icon.
  final String id;

  /// e.g. "Afrobeats & Music".
  final String name;

  Json toJson() => {'id': id, 'name': name};
}

/// Why a creator is rising, shown as the badge on their story circle.
enum RisingReason {
  /// Gaining Stars fastest.
  stars,
  dance,

  /// Won or placed in a challenge.
  challenge,
  music,
}

/// A creator in the RISING CREATORS story rail (`GET /discover/rising`).
class RisingCreator {
  const RisingCreator({
    required this.creator,
    required this.storyKey,
    required this.reason,
    this.hasUnseenStory = false,
  });

  factory RisingCreator.fromJson(Json json) => RisingCreator(
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    storyKey: json['storyKey'] as String,
    reason: readEnum(RisingReason.values, json['reason'], RisingReason.stars),
    hasUnseenStory: json['hasUnseenStory'] as bool? ?? false,
  );

  final CreatorSummary creator;

  /// Opens their story: `/story?creator=<storyKey>`.
  final String storyKey;
  final RisingReason reason;

  /// Draws the coloured ring; a story already watched gets the grey one.
  final bool hasUnseenStory;

  Json toJson() => {
    'creator': creator.toJson(),
    'storyKey': storyKey,
    'reason': reason.name,
    'hasUnseenStory': hasUnseenStory,
  };
}

/// A creator suggested to follow (`GET /discover/suggestions`). Whether the
/// user follows them is in the shared `followingProvider`.
class SuggestedCreator {
  const SuggestedCreator({
    required this.creator,
    required this.talent,
    this.followedBy = const [],
  });

  factory SuggestedCreator.fromJson(Json json) => SuggestedCreator(
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    talent: json['talent'] as String? ?? '',
    followedBy: readList(json['followedBy'], CreatorSummary.fromJson),
  );

  final CreatorSummary creator;

  /// Their main talent, the reason they're suggested, e.g. "Photography".
  final String talent;

  /// People the user follows who follow this creator; the card shows up to
  /// three.
  final List<CreatorSummary> followedBy;

  String get id => creator.id;

  Json toJson() => {
    'creator': creator.toJson(),
    'talent': talent,
    'followedBy': [for (final c in followedBy) c.toJson()],
  };
}

/// Theme of a featured challenge banner.
enum ArenaTone { gold, navy }

/// A featured arena challenge banner (`GET /discover/challenges`).
class FeaturedChallenge {
  const FeaturedChallenge({
    required this.id,
    required this.arena,
    required this.title,
    required this.description,
    required this.endsAt,
    required this.prizePool,
    required this.submissions,
    this.tone = ArenaTone.navy,
  });

  factory FeaturedChallenge.fromJson(Json json) => FeaturedChallenge(
    id: json['id'] as String,
    arena: json['arena'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    endsAt: readDate(json['endsAt']) ?? DateTime.now(),
    prizePool: Money.fromJson(json['prizePool'] as Json),
    submissions: readInt(json['submissions']),
    tone: readEnum(ArenaTone.values, json['tone'], ArenaTone.navy),
  );

  final String id;

  /// e.g. "Africa Arena" (shown uppercase).
  final String arena;
  final String title;
  final String description;
  final DateTime endsAt;
  final Money prizePool;
  final int submissions;
  final ArenaTone tone;

  Json toJson() => {
    'id': id,
    'arena': arena,
    'title': title,
    'description': description,
    'endsAt': endsAt.toUtc().toIso8601String(),
    'prizePool': prizePool.toJson(),
    'submissions': submissions,
    'tone': tone.name,
  };
}

/// A talent video in the Discover grid (`GET /discover/videos`).
class DiscoverVideo {
  const DiscoverVideo({
    required this.id,
    required this.creator,
    required this.caption,
    this.posterUrl,
    this.isSaved = false,
  });

  factory DiscoverVideo.fromJson(Json json) => DiscoverVideo(
    id: json['id'] as String,
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    caption: json['caption'] as String? ?? '',
    posterUrl: json['posterUrl'] as String?,
    isSaved: json['isSaved'] as bool? ?? false,
  );

  final String id;
  final CreatorSummary creator;
  final String caption;

  /// Thumbnail frame.
  final String? posterUrl;

  /// Whether the user bookmarked it.
  final bool isSaved;

  Json toJson() => {
    'id': id,
    'creator': creator.toJson(),
    'caption': caption,
    'posterUrl': posterUrl,
    'isSaved': isSaved,
  };

  DiscoverVideo copyWith({bool? isSaved}) => DiscoverVideo(
    id: id,
    creator: creator,
    caption: caption,
    posterUrl: posterUrl,
    isSaved: isSaved ?? this.isSaved,
  );
}

/// Sent as `country=<name>`; [all] sends nothing.
enum FilterCountry {
  all('All countries'),
  nigeria('Nigeria'),
  ghana('Ghana'),
  southAfrica('South Africa');

  const FilterCountry(this.label);
  final String label;
}

/// Sent as `sort=<name>`.
enum FilterSort {
  trending('Trending'),
  risingStars('Rising Stars'),
  mostStars('Most Stars');

  const FilterSort(this.label);
  final String label;
}

/// Choices made in the Discover filters sheet.
class DiscoverFilters {
  const DiscoverFilters({
    this.country = FilterCountry.nigeria,
    this.sort = FilterSort.trending,
  });

  final FilterCountry country;
  final FilterSort sort;

  DiscoverFilters copyWith({FilterCountry? country, FilterSort? sort}) =>
      DiscoverFilters(
        country: country ?? this.country,
        sort: sort ?? this.sort,
      );

  @override
  bool operator ==(Object other) =>
      other is DiscoverFilters &&
      other.country == country &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(country, sort);
}
