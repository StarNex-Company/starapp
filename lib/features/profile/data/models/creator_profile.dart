import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';

/// Where a challenge stands for the creator.
enum CreatorChallengeStatus {
  /// Hasn't opened yet; leads to the upcoming challenges.
  upcoming,

  /// Running; leads to its live standings.
  live,

  /// Closed; leads to its results.
  finished,
}

/// A creator's part in one challenge: a row in the Challenges tab, or the
/// gold banner under the profile actions.
class CreatorChallengeEntry {
  const CreatorChallengeEntry({
    required this.challengeId,
    required this.title,
    required this.status,
    required this.date,
    this.rank,
    this.entrants,
    this.prize,
  });

  factory CreatorChallengeEntry.fromJson(Json json) => CreatorChallengeEntry(
    challengeId: json['challengeId'] as String,
    title: json['title'] as String,
    status: readEnum(
      CreatorChallengeStatus.values,
      json['status'],
      CreatorChallengeStatus.finished,
    ),
    date: readDate(json['date']) ?? DateTime.now(),
    rank: json['rank'] == null ? null : readInt(json['rank']),
    entrants: json['entrants'] == null ? null : readInt(json['entrants']),
    prize: json['prize'] == null ? null : Money.fromJson(json['prize'] as Json),
  );

  final String challengeId;
  final String title;
  final CreatorChallengeStatus status;

  /// When it opens (upcoming), opened (live) or closed (finished).
  final DateTime date;

  /// Current or final position; null while unranked (an entry under review,
  /// or a challenge without a leaderboard).
  final int? rank;
  final int? entrants;

  /// What the creator won; set on a win with a cash prize.
  final Money? prize;

  bool get isWin => status == CreatorChallengeStatus.finished && rank == 1;

  Json toJson() => {
    'challengeId': challengeId,
    'title': title,
    'status': status.name,
    'date': date.toUtc().toIso8601String(),
    'rank': rank,
    'entrants': entrants,
    'prize': prize?.toJson(),
  };
}

/// The Stats tab's performance cards.
class CreatorStats {
  const CreatorStats({
    required this.views30d,
    required this.viewsChange,
    required this.watchRatio,
    required this.entries,
    required this.topCategory,
    this.firstWinAt,
    this.topSubcategory,
  });

  factory CreatorStats.fromJson(Json json) => CreatorStats(
    views30d: readInt(json['views30d']),
    viewsChange: readDouble(json['viewsChange']),
    watchRatio: readDouble(json['watchRatio']),
    entries: readInt(json['entries']),
    topCategory: json['topCategory'] as String? ?? '',
    firstWinAt: readDate(json['firstWinAt']),
    topSubcategory: json['topSubcategory'] as String?,
  );

  /// Views over the last 30 days.
  final int views30d;

  /// Percent change on the 30 days before, e.g. 18 for "+18%".
  final double viewsChange;

  /// Average share of each video watched, 0–1.
  final double watchRatio;

  /// Challenges entered.
  final int entries;
  final String topCategory;

  /// Null until the creator's first win.
  final DateTime? firstWinAt;
  final String? topSubcategory;

  Json toJson() => {
    'views30d': views30d,
    'viewsChange': viewsChange,
    'watchRatio': watchRatio,
    'entries': entries,
    'topCategory': topCategory,
    'firstWinAt': firstWinAt?.toUtc().toIso8601String(),
    'topSubcategory': topSubcategory,
  };
}

/// A video in the Content tab's grid (`GET /creators/{id}/posts`).
class CreatorPost {
  const CreatorPost({
    required this.id,
    required this.views,
    this.thumbnailUrl,
    this.isEntry = false,
  });

  factory CreatorPost.fromJson(Json json) => CreatorPost(
    id: json['id'] as String,
    views: readInt(json['views']),
    thumbnailUrl: json['thumbnailUrl'] as String?,
    isEntry: json['isEntry'] as bool? ?? false,
  );

  final String id;
  final int views;
  final String? thumbnailUrl;

  /// A challenge entry, marked with the gold "Entry" pill.
  final bool isEntry;

  Json toJson() => {
    'id': id,
    'views': views,
    'thumbnailUrl': thumbnailUrl,
    'isEntry': isEntry,
  };
}

/// Another creator's public profile (`GET /creators/{id}`): the
/// [CreatorSummary] fields at the top level, plus the rest below. The posts
/// come separately, a page at a time.
class CreatorProfile {
  const CreatorProfile({
    required this.creator,
    this.coverUrl,
    this.location = '',
    this.bio = '',
    this.talents = const [],
    this.stars = 0,
    this.followers = 0,
    this.following = 0,
    this.wins = 0,
    this.isFollowing = false,
    this.hasStory = false,
    this.isCoFounder = false,
    this.featuredChallenge,
    this.challenges = const [],
    this.stats,
  });

  factory CreatorProfile.fromJson(Json json) => CreatorProfile(
    creator: CreatorSummary.fromJson(json),
    coverUrl: json['coverUrl'] as String?,
    location: json['location'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
    talents: readStrings(json['talents']),
    stars: readInt(json['stars']),
    followers: readInt(json['followers']),
    following: readInt(json['following']),
    wins: readInt(json['wins']),
    isFollowing: json['isFollowing'] as bool? ?? false,
    hasStory: json['hasStory'] as bool? ?? false,
    isCoFounder: json['isCoFounder'] as bool? ?? false,
    featuredChallenge: json['featuredChallenge'] == null
        ? null
        : CreatorChallengeEntry.fromJson(json['featuredChallenge'] as Json),
    challenges: readList(json['challenges'], CreatorChallengeEntry.fromJson),
    stats: json['stats'] == null
        ? null
        : CreatorStats.fromJson(json['stats'] as Json),
  );

  final CreatorSummary creator;
  final String? coverUrl;
  final String location;
  final String bio;
  final List<String> talents;
  final int stars;

  /// Including the signed-in user when [isFollowing].
  final int followers;
  final int following;
  final int wins;

  /// Whether the signed-in user followed them when this was fetched. Live
  /// follow state is `followingProvider`; see [followersWhen].
  final bool isFollowing;

  /// A live story: the photo gets a ring and opens the story viewer.
  final bool hasStory;

  /// Star App team member: the extra badge after the name.
  final bool isCoFounder;

  /// The gold banner, e.g. "Ranked #4 in Afro-Dance Takeover".
  final CreatorChallengeEntry? featuredChallenge;
  final List<CreatorChallengeEntry> challenges;

  /// Null for creators without enough activity to chart.
  final CreatorStats? stats;

  String get id => creator.id;
  String get name => creator.name;
  String get handle => creator.handle;
  String? get avatarUrl => creator.avatarUrl;
  bool get isVerified => creator.isVerified;
  CreatorTier get tier => creator.tier ?? CreatorTier.shootingStar;
  String get firstName => name.split(' ').first;

  /// Shareable link, without the scheme.
  String get profileLink => 'starapp.io/@$handle';

  /// [followers] with the user's current follow state applied, so a follow
  /// made since the fetch shows at once.
  int followersWhen({required bool following}) =>
      followers - (isFollowing ? 1 : 0) + (following ? 1 : 0);

  Json toJson() => {
    ...creator.toJson(),
    'coverUrl': coverUrl,
    'location': location,
    'bio': bio,
    'talents': talents,
    'stars': stars,
    'followers': followers,
    'following': following,
    'wins': wins,
    'isFollowing': isFollowing,
    'hasStory': hasStory,
    'isCoFounder': isCoFounder,
    'featuredChallenge': featuredChallenge?.toJson(),
    'challenges': [for (final c in challenges) c.toJson()],
    'stats': stats?.toJson(),
  };
}
