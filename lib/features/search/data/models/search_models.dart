import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

/// Where a challenge is in its run.
enum SearchChallengeStatus { upcoming, live, ended }

/// A challenge in search results.
class SearchChallenge {
  const SearchChallenge({
    required this.id,
    required this.title,
    required this.status,
    this.entries = 0,
    this.startsAt,
    this.endsAt,
  });

  factory SearchChallenge.fromJson(Json json) => SearchChallenge(
    id: json['id'] as String,
    title: json['title'] as String,
    status: readEnum(
      SearchChallengeStatus.values,
      json['status'],
      SearchChallengeStatus.live,
    ),
    entries: readInt(json['entries']),
    startsAt: readDate(json['startsAt']),
    endsAt: readDate(json['endsAt']),
  );

  final String id;
  final String title;
  final SearchChallengeStatus status;
  final int entries;

  /// When an upcoming challenge opens.
  final DateTime? startsAt;

  /// When a live challenge closes, or an ended one closed.
  final DateTime? endsAt;

  Json toJson() => {
    'id': id,
    'title': title,
    'status': status.name,
    'entries': entries,
    'startsAt': startsAt?.toUtc().toIso8601String(),
    'endsAt': endsAt?.toUtc().toIso8601String(),
  };
}

/// Creators and challenges matching one query (`GET /search?q=`).
class SearchResults {
  const SearchResults({this.creators = const [], this.challenges = const []});

  factory SearchResults.fromJson(Json json) => SearchResults(
    creators: readList(json['creators'], CreatorSummary.fromJson),
    challenges: readList(json['challenges'], SearchChallenge.fromJson),
  );

  final List<CreatorSummary> creators;
  final List<SearchChallenge> challenges;

  bool get isEmpty => creators.isEmpty && challenges.isEmpty;

  Json toJson() => {
    'creators': [for (final c in creators) c.toJson()],
    'challenges': [for (final c in challenges) c.toJson()],
  };
}
