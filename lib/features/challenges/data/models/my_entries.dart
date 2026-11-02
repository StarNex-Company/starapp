import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';

/// One of the signed-in user's challenge entries (`GET /me/entries`).
class MyEntry {
  const MyEntry({
    required this.id,
    required this.title,
    required this.challenge,
    this.rank,
    this.stars = 0,
    this.prize,
    this.bonusStars = 0,
  });

  factory MyEntry.fromJson(Json json) => MyEntry(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    challenge: Challenge.fromJson(json['challenge'] as Json),
    rank: (json['rank'] as num?)?.toInt(),
    stars: readInt(json['stars']),
    prize: json['prize'] == null ? null : Money.fromJson(json['prize'] as Json),
    bonusStars: readInt(json['bonusStars']),
  );

  final String id;

  /// The entry's own title, e.g. "Late-night vocal run".
  final String title;
  final Challenge challenge;

  /// Place on the board; null for challenges without one.
  final int? rank;
  final int stars;

  /// Cash won, if any.
  final Money? prize;

  /// Stars awarded for taking part.
  final int bonusStars;

  Json toJson() => {
    'id': id,
    'title': title,
    'challenge': challenge.toJson(),
    'rank': rank,
    'stars': stars,
    'prize': prize?.toJson(),
    'bonusStars': bonusStars,
  };
}
