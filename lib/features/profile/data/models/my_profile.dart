import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/profile_progress.dart';

export 'package:starapp/features/profile/data/models/profile_progress.dart';

/// `GET /me/profile`: everything on the signed-in creator's own profile
/// beyond the basics in `CurrentUser` (name, avatar, counts and tier come
/// from `currentUserProvider`). The post grid pages separately
/// (`GET /me/posts`).
class MyProfile {
  const MyProfile({
    required this.tierProgress,
    required this.passport,
    this.isFounder = false,
    this.challenges = const [],
    this.stats = const [],
  });

  factory MyProfile.fromJson(Json json) => MyProfile(
    tierProgress: TierProgress.fromJson(json['tierProgress'] as Json),
    passport: PassportSummary.fromJson(json['passport'] as Json),
    isFounder: json['isFounder'] as bool? ?? false,
    challenges: readList(json['challenges'], ChallengeHistoryEntry.fromJson),
    stats: readList(json['stats'], ProfileStat.maybeFromJson).nonNulls.toList(),
  );

  final TierProgress tierProgress;
  final PassportSummary passport;

  /// Shows the co-founder badge beside the name.
  final bool isFounder;

  /// Newest first. The profile's "My challenges" section shows the first two.
  final List<ChallengeHistoryEntry> challenges;

  /// The "Stats" tab cards, in order.
  final List<ProfileStat> stats;

  Json toJson() => {
    'tierProgress': tierProgress.toJson(),
    'passport': passport.toJson(),
    'isFounder': isFounder,
    'challenges': [for (final c in challenges) c.toJson()],
    'stats': [for (final s in stats) s.toJson()],
  };
}

/// AI Talent Passport score and its headline metrics.
class PassportSummary {
  const PassportSummary({required this.score, this.metrics = const []});

  factory PassportSummary.fromJson(Json json) => PassportSummary(
    score: readInt(json['score']),
    metrics: PassportMetric.readAll(json['metrics']),
  );

  /// Out of 100.
  final int score;
  final List<PassportMetric> metrics;

  Json toJson() => {
    'score': score,
    'metrics': [for (final m in metrics) m.toJson()],
  };
}

enum ChallengeStanding {
  /// Still running; opens the live leaderboard.
  live,

  /// Finished with a placing; opens the results.
  placed,

  /// A one-off challenge that was simply completed.
  completed,
}

/// A challenge the creator entered, for "My challenges" and the Challenge
/// History tab.
class ChallengeHistoryEntry {
  const ChallengeHistoryEntry({
    required this.id,
    required this.title,
    required this.standing,
    required this.enteredAt,
    this.endedAt,
    this.rank,
    this.entrants,
    this.stars,
  });

  factory ChallengeHistoryEntry.fromJson(Json json) => ChallengeHistoryEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    standing: readEnum(
      ChallengeStanding.values,
      json['standing'],
      ChallengeStanding.completed,
    ),
    enteredAt: readDate(json['enteredAt']) ?? DateTime.now(),
    endedAt: readDate(json['endedAt']),
    rank: json['rank'] == null ? null : readInt(json['rank']),
    entrants: json['entrants'] == null ? null : readInt(json['entrants']),
    stars: json['stars'] == null ? null : readInt(json['stars']),
  );

  final String id;
  final String title;
  final ChallengeStanding standing;
  final DateTime enteredAt;

  /// When the challenge closed; null while [ChallengeStanding.live].
  final DateTime? endedAt;

  /// Current or final position, 1-based.
  final int? rank;

  /// How many creators entered.
  final int? entrants;

  /// Stars the entry has earned so far (live) or was awarded (completed).
  final int? stars;

  Json toJson() => {
    'id': id,
    'title': title,
    'standing': standing.name,
    'enteredAt': enteredAt.toUtc().toIso8601String(),
    'endedAt': endedAt?.toUtc().toIso8601String(),
    'rank': rank,
    'entrants': entrants,
    'stars': stars,
  };
}

/// One of the creator's own videos in the profile grid (`GET /me/posts`).
class ProfileGridPost {
  const ProfileGridPost({
    required this.id,
    required this.views,
    this.thumbnailUrl,
    this.isChallengeEntry = false,
  });

  factory ProfileGridPost.fromJson(Json json) => ProfileGridPost(
    id: json['id'] as String,
    views: readInt(json['views']),
    thumbnailUrl: json['thumbnailUrl'] as String?,
    isChallengeEntry: json['isChallengeEntry'] as bool? ?? false,
  );

  final String id;
  final int views;
  final String? thumbnailUrl;

  /// Entered into a challenge; shows the gold "Entry" pill.
  final bool isChallengeEntry;

  Json toJson() => {
    'id': id,
    'views': views,
    'thumbnailUrl': thumbnailUrl,
    'isChallengeEntry': isChallengeEntry,
  };
}

/// What a "Stats" tab card measures; each kind fixes its label and how its
/// [ProfileStat.value] reads.
enum ProfileStatKind {
  /// Views over the last 30 days.
  views,

  /// The average share of each video watched, as a percentage.
  watchTime,

  /// Stars earned this month.
  starsThisMonth,

  /// The category most Stars come from; [ProfileStat.value] is its share.
  topCategory,
}

/// A card in the "Stats" tab, e.g. views 11800 with a +24% change.
class ProfileStat {
  const ProfileStat({
    required this.kind,
    required this.value,
    this.changePercent,
    this.category,
    this.isRecord = false,
  });

  /// Null for a kind this app version doesn't know, so lists can skip it.
  static ProfileStat? maybeFromJson(Json json) {
    final kind = readEnumOrNull(ProfileStatKind.values, json['kind']);
    if (kind == null) return null;
    return ProfileStat(
      kind: kind,
      value: readInt(json['value']),
      changePercent: json['changePercent'] == null
          ? null
          : readInt(json['changePercent']),
      category: json['category'] as String?,
      isRecord: json['isRecord'] as bool? ?? false,
    );
  }

  final ProfileStatKind kind;
  final int value;

  /// Against the previous period, in percent (points for [ProfileStatKind.watchTime]).
  final int? changePercent;

  /// The category's name for [ProfileStatKind.topCategory], e.g. "Music".
  final String? category;

  /// The best value yet ("Best month yet").
  final bool isRecord;

  Json toJson() => {
    'kind': kind.name,
    'value': value,
    'changePercent': changePercent,
    'category': category,
    'isRecord': isRecord,
  };
}

/// The live figures on the Shortcuts page (`GET /me/shortcuts`).
class ShortcutsSummary {
  const ShortcutsSummary({
    required this.walletBalance,
    required this.savedCount,
    required this.verificationStepsDone,
    required this.verificationSteps,
  });

  factory ShortcutsSummary.fromJson(Json json) => ShortcutsSummary(
    walletBalance: Money.fromJson(json['walletBalance'] as Json),
    savedCount: readInt(json['savedCount']),
    verificationStepsDone: readInt(json['verificationStepsDone']),
    verificationSteps: readInt(json['verificationSteps']),
  );

  /// Available to withdraw.
  final Money walletBalance;
  final int savedCount;

  /// "3 of 5 steps complete".
  final int verificationStepsDone;
  final int verificationSteps;

  Json toJson() => {
    'walletBalance': walletBalance.toJson(),
    'savedCount': savedCount,
    'verificationStepsDone': verificationStepsDone,
    'verificationSteps': verificationSteps,
  };
}
