import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';

/// Which board to load: one challenge's live standings, or the all-time Hall
/// of Fame. Sent as `?view=live|allTime`.
enum BoardView { live, allTime }

/// One place on a leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.creator,
    required this.stars,
    this.location,
    this.entryTitle,
    this.talent,
    this.movement = 0,
  });

  factory LeaderboardEntry.fromJson(Json json) => LeaderboardEntry(
    rank: readInt(json['rank']),
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    stars: readInt(json['stars']),
    location: json['location'] as String?,
    entryTitle: json['entryTitle'] as String?,
    talent: json['talent'] as String?,
    movement: readInt(json['movement']),
  );

  final int rank;
  final CreatorSummary creator;
  final int stars;

  /// e.g. "Lagos, NG".
  final String? location;

  /// The entry's title on a challenge board, e.g. "Lamba Groove".
  final String? entryTitle;

  /// The creator's main talent on the all-time board, e.g. "Music".
  final String? talent;

  /// Places gained (positive) or lost (negative) in the latest update.
  final int movement;

  Json toJson() => {
    'rank': rank,
    'creator': creator.toJson(),
    'stars': stars,
    'location': location,
    'entryTitle': entryTitle,
    'talent': talent,
    'movement': movement,
  };
}

/// The signed-in user's own place, pinned above the rankings.
class MyLeaderboardRank {
  const MyLeaderboardRank({
    required this.entry,
    this.starsToTopTen,
    this.topPercent,
    this.region,
  });

  factory MyLeaderboardRank.fromJson(Json json) => MyLeaderboardRank(
    entry: LeaderboardEntry.fromJson(json['entry'] as Json),
    starsToTopTen: (json['starsToTopTen'] as num?)?.toInt(),
    topPercent: (json['topPercent'] as num?)?.toInt(),
    region: json['region'] as String?,
  );

  /// Your row: rank, Stars, movement, entry title and photo.
  final LeaderboardEntry entry;

  /// Live board: Stars still needed to reach 10th; null inside the top 10.
  final int? starsToTopTen;

  /// All-time board: the percentile you're in, e.g. 4 for "Top 4%".
  final int? topPercent;

  /// Where [topPercent] is counted, e.g. "Nigeria".
  final String? region;

  Json toJson() => {
    'entry': entry.toJson(),
    'starsToTopTen': starsToTopTen,
    'topPercent': topPercent,
    'region': region,
  };
}

/// One page of a board (`GET /challenges/{id}/leaderboard?view=`), highest
/// first. The all-time podium is its first three places.
class Leaderboard {
  const Leaderboard({
    required this.view,
    required this.entries,
    required this.updatedAt,
    this.nextCursor,
    this.me,
    this.season,
  });

  factory Leaderboard.fromJson(Json json) {
    final page = Paged.fromJson(json, LeaderboardEntry.fromJson);
    return Leaderboard(
      view: readEnum(BoardView.values, json['view'], BoardView.live),
      entries: page.items,
      nextCursor: page.nextCursor,
      updatedAt: readDate(json['updatedAt']) ?? DateTime.now(),
      me: json['me'] == null
          ? null
          : MyLeaderboardRank.fromJson(json['me'] as Json),
      season: (json['season'] as num?)?.toInt(),
    );
  }

  final BoardView view;
  final List<LeaderboardEntry> entries;

  /// Pass back as `cursor` for the next page; null on the last page.
  final String? nextCursor;

  /// When the standings last changed.
  final DateTime updatedAt;

  /// Null when the user has no place on this board.
  final MyLeaderboardRank? me;

  /// The all-time board's year, e.g. 2026.
  final int? season;

  bool get hasMore => nextCursor != null;

  /// This board with [next]'s places added after its own.
  Leaderboard appending(Leaderboard next) => Leaderboard(
    view: view,
    entries: [...entries, ...next.entries],
    nextCursor: next.nextCursor,
    updatedAt: updatedAt,
    me: me,
    season: season,
  );

  Json toJson() => {
    'view': view.name,
    'items': [for (final e in entries) e.toJson()],
    'nextCursor': nextCursor,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'me': me?.toJson(),
    'season': season,
  };
}
