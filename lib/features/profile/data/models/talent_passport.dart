import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/profile_progress.dart';

export 'package:starapp/features/profile/data/models/profile_progress.dart';

/// The user's shareable Talent Passport (`GET /me/passport`). Name, handle,
/// photo and tier come from the session user; this holds the rest.
class TalentPassport {
  const TalentPassport({
    required this.passportId,
    required this.aiScore,
    required this.linkUrl,
    this.metrics = const [],
    this.bestWork = const [],
    this.challenges = const [],
    this.journey = const [],
    this.reviews = const [],
  });

  factory TalentPassport.fromJson(Json json) => TalentPassport(
    passportId: json['passportId'] as String,
    aiScore: readInt(json['aiScore']),
    linkUrl: json['linkUrl'] as String,
    metrics: PassportMetric.readAll(json['metrics']),
    bestWork: readList(json['bestWork'], PassportWork.fromJson),
    challenges: readList(json['challenges'], PassportChallenge.fromJson),
    journey: readList(json['journey'], PassportTierStep.fromJson),
    reviews: readList(json['reviews'], PassportReview.fromJson),
  );

  /// e.g. "SA-NG-2026-0418".
  final String passportId;

  /// 0–100.
  final int aiScore;

  /// The public page, e.g. "https://starapp.io/p/emmanuel".
  final String linkUrl;
  final List<PassportMetric> metrics;
  final List<PassportWork> bestWork;
  final List<PassportChallenge> challenges;

  /// Lowest tier first.
  final List<PassportTierStep> journey;
  final List<PassportReview> reviews;

  Json toJson() => {
    'passportId': passportId,
    'aiScore': aiScore,
    'linkUrl': linkUrl,
    'metrics': [for (final m in metrics) m.toJson()],
    'bestWork': [for (final w in bestWork) w.toJson()],
    'challenges': [for (final c in challenges) c.toJson()],
    'journey': [for (final s in journey) s.toJson()],
    'reviews': [for (final r in reviews) r.toJson()],
  };
}

class PassportWork {
  const PassportWork({
    required this.postId,
    required this.views,
    this.thumbnailUrl,
  });

  factory PassportWork.fromJson(Json json) => PassportWork(
    postId: json['postId'] as String,
    views: readInt(json['views']),
    thumbnailUrl: json['thumbnailUrl'] as String?,
  );

  final String postId;
  final int views;
  final String? thumbnailUrl;

  Json toJson() => {
    'postId': postId,
    'views': views,
    'thumbnailUrl': thumbnailUrl,
  };
}

enum PassportChallengeResult {
  /// Finished in the top places; opens the winners.
  placed,

  /// Taking part; opens the leaderboard.
  entered,
}

/// A line of the challenge record.
class PassportChallenge {
  const PassportChallenge({
    required this.challengeId,
    required this.title,
    required this.result,
    required this.date,
    this.rank,
    this.entrants,
    this.prize,
    this.isLive = false,
  });

  factory PassportChallenge.fromJson(Json json) => PassportChallenge(
    challengeId: json['challengeId'] as String,
    title: json['title'] as String,
    result: readEnum(
      PassportChallengeResult.values,
      json['result'],
      PassportChallengeResult.entered,
    ),
    date: readDate(json['date']) ?? DateTime.now(),
    rank: json['rank'] == null ? null : readInt(json['rank']),
    entrants: json['entrants'] == null ? null : readInt(json['entrants']),
    prize: json['prize'] == null ? null : Money.fromJson(json['prize'] as Json),
    isLive: json['isLive'] as bool? ?? false,
  );

  final String challengeId;

  /// The challenge's name, e.g. "Afro-Dance Takeover".
  final String title;
  final PassportChallengeResult result;

  /// When it finished, or when the user entered one still running.
  final DateTime date;

  /// Final or current position, 1-based.
  final int? rank;
  final int? entrants;

  /// Prize won, if any.
  final Money? prize;
  final bool isLive;

  Json toJson() => {
    'challengeId': challengeId,
    'title': title,
    'result': result.name,
    'date': date.toUtc().toIso8601String(),
    'rank': rank,
    'entrants': entrants,
    'prize': prize?.toJson(),
    'isLive': isLive,
  };
}

enum PassportTierState { reached, current, next }

/// A tier on the journey: reached ones carry the date, the next one how far
/// away it is.
class PassportTierStep {
  const PassportTierStep({
    required this.tier,
    required this.state,
    this.reachedAt,
    this.starsAway,
  });

  factory PassportTierStep.fromJson(Json json) => PassportTierStep(
    tier: readEnum(CreatorTier.values, json['tier'], CreatorTier.shootingStar),
    state: readEnum(
      PassportTierState.values,
      json['state'],
      PassportTierState.reached,
    ),
    reachedAt: readDate(json['reachedAt']),
    starsAway: json['starsAway'] == null ? null : readInt(json['starsAway']),
  );

  final CreatorTier tier;
  final PassportTierState state;

  /// When the tier was reached; for the first tier, when the user joined.
  final DateTime? reachedAt;

  /// Stars still needed, for [PassportTierState.next].
  final int? starsAway;

  Json toJson() => {
    'tier': tier.name,
    'state': state.name,
    'reachedAt': reachedAt?.toUtc().toIso8601String(),
    'starsAway': starsAway,
  };
}

/// A company's review of work the user did for them.
class PassportReview {
  const PassportReview({
    required this.company,
    required this.role,
    required this.date,
    required this.rating,
    required this.quote,
  });

  factory PassportReview.fromJson(Json json) => PassportReview(
    company: CompanySummary.fromJson(json['company'] as Json),
    role: json['role'] as String? ?? '',
    date: readDate(json['date']) ?? DateTime.now(),
    rating: readInt(json['rating']),
    quote: json['quote'] as String? ?? '',
  );

  final CompanySummary company;

  /// What the user did, e.g. "Featured dancer".
  final String role;

  /// When the work took place.
  final DateTime date;

  /// Out of 5.
  final int rating;

  /// Without surrounding quote marks.
  final String quote;

  Json toJson() => {
    'company': company.toJson(),
    'role': role,
    'date': date.toUtc().toIso8601String(),
    'rating': rating,
    'quote': quote,
  };
}
