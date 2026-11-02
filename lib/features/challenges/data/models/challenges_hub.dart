import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';

/// The challenges tab (`GET /challenges/hub`): tab counts, the featured
/// arena and the other active arenas.
class ChallengesHub {
  const ChallengesHub({
    required this.activeCount,
    required this.upcomingCount,
    required this.myEntryCount,
    this.featured,
    this.arenas = const [],
  });

  factory ChallengesHub.fromJson(Json json) => ChallengesHub(
    activeCount: readInt(json['activeCount']),
    upcomingCount: readInt(json['upcomingCount']),
    myEntryCount: readInt(json['myEntryCount']),
    featured: json['featured'] == null
        ? null
        : FeaturedArena.fromJson(json['featured'] as Json),
    arenas: readList(json['arenas'], HubArena.fromJson),
  );

  final int activeCount;
  final int upcomingCount;
  final int myEntryCount;
  final FeaturedArena? featured;

  /// Active arenas below the featured one.
  final List<HubArena> arenas;

  Json toJson() => {
    'activeCount': activeCount,
    'upcomingCount': upcomingCount,
    'myEntryCount': myEntryCount,
    'featured': featured?.toJson(),
    'arenas': [for (final a in arenas) a.toJson()],
  };
}

/// The featured arena's hero card, with its live top three.
class FeaturedArena {
  const FeaturedArena({
    required this.challenge,
    required this.podium,
    required this.standingsUpdatedAt,
  });

  factory FeaturedArena.fromJson(Json json) => FeaturedArena(
    challenge: Challenge.fromJson(json['challenge'] as Json),
    podium: readList(json['podium'], LeaderboardEntry.fromJson),
    standingsUpdatedAt: readDate(json['standingsUpdatedAt']) ?? DateTime.now(),
  );

  final Challenge challenge;

  /// The live top three.
  final List<LeaderboardEntry> podium;

  /// When [podium] last changed.
  final DateTime standingsUpdatedAt;

  Json toJson() => {
    'challenge': challenge.toJson(),
    'podium': [for (final e in podium) e.toJson()],
    'standingsUpdatedAt': standingsUpdatedAt.toUtc().toIso8601String(),
  };
}

/// An active arena below the featured one.
class HubArena {
  const HubArena({required this.challenge, required this.preview});

  factory HubArena.fromJson(Json json) => HubArena(
    challenge: Challenge.fromJson(json['challenge'] as Json),
    preview: ArenaPreview.fromJson(json['preview'] as Json? ?? const {}),
  );

  final Challenge challenge;
  final ArenaPreview preview;

  Json toJson() => {
    'challenge': challenge.toJson(),
    'preview': preview.toJson(),
  };
}

/// What an arena card shows between its title and "Participate", picked by
/// `kind`: `"leaders"` or `"banner"`.
sealed class ArenaPreview {
  const ArenaPreview();

  factory ArenaPreview.fromJson(Json json) => switch (json['kind']) {
    'banner' => ArenaBannerPreview(
      imageUrl: json['imageUrl'] as String?,
      theme: json['theme'] as String? ?? '',
    ),
    _ => ArenaLeadersPreview(
      entries: readList(json['entries'], ChallengeEntry.fromJson),
    ),
  };

  Json toJson();
}

/// The leading submissions so far.
final class ArenaLeadersPreview extends ArenaPreview {
  const ArenaLeadersPreview({required this.entries});

  final List<ChallengeEntry> entries;

  @override
  Json toJson() => {
    'kind': 'leaders',
    'entries': [for (final e in entries) e.toJson()],
  };
}

/// A banner with the arena's theme.
final class ArenaBannerPreview extends ArenaPreview {
  const ArenaBannerPreview({required this.imageUrl, required this.theme});

  final String? imageUrl;

  /// e.g. "Solarpunk Horizons".
  final String theme;

  @override
  Json toJson() => {'kind': 'banner', 'imageUrl': imageUrl, 'theme': theme};
}
