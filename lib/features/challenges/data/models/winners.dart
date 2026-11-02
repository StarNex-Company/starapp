import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';

/// Results of a finished challenge (`GET /challenges/{id}/winners`).
class ChallengeWinners {
  const ChallengeWinners({
    required this.challenge,
    required this.winner,
    required this.winningEntry,
    this.runnersUp = const [],
  });

  factory ChallengeWinners.fromJson(Json json) => ChallengeWinners(
    challenge: Challenge.fromJson(json['challenge'] as Json),
    winner: Placement.fromJson(json['winner'] as Json),
    winningEntry: ChallengeEntry.fromJson(json['winningEntry'] as Json),
    runnersUp: readList(json['runnersUp'], Placement.fromJson),
  );

  /// The finished challenge; its prize is the winner's.
  final Challenge challenge;
  final Placement winner;
  final ChallengeEntry winningEntry;

  /// Second place first.
  final List<Placement> runnersUp;

  Json toJson() => {
    'challenge': challenge.toJson(),
    'winner': winner.toJson(),
    'winningEntry': winningEntry.toJson(),
    'runnersUp': [for (final p in runnersUp) p.toJson()],
  };
}

/// A creator's final place in a challenge.
class Placement {
  const Placement({
    required this.rank,
    required this.creator,
    required this.stars,
    this.location,
    this.prize,
  });

  factory Placement.fromJson(Json json) => Placement(
    rank: readInt(json['rank']),
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    stars: readInt(json['stars']),
    location: json['location'] as String?,
    prize: json['prize'] == null ? null : Money.fromJson(json['prize'] as Json),
  );

  final int rank;
  final CreatorSummary creator;
  final int stars;

  /// e.g. "Lagos, NG".
  final String? location;

  /// Cash won, if any.
  final Money? prize;

  Json toJson() => {
    'rank': rank,
    'creator': creator.toJson(),
    'stars': stars,
    'location': location,
    'prize': prize?.toJson(),
  };
}
