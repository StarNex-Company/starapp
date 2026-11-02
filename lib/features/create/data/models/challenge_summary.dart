import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';

/// A challenge an entry can be submitted to (Submit Entry's radio list and
/// the challenge toggle on Preview & Edit).
class ChallengeSummary {
  const ChallengeSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.endsAt,
    this.rules = const [],
    this.isEligible = true,
    this.ineligibleReason,
  });

  factory ChallengeSummary.fromJson(Json json) => ChallengeSummary(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? '',
    endsAt: readDate(json['endsAt']) ?? DateTime.now(),
    rules: readStrings(json['rules']),
    isEligible: json['isEligible'] as bool? ?? true,
    ineligibleReason: json['ineligibleReason'] as String?,
  );

  final String id;
  final String title;
  final String category;

  /// When entries close.
  final DateTime endsAt;

  /// What every entry has to follow; the creator confirms them on submit.
  final List<String> rules;
  final bool isEligible;

  /// Why this entry can't go in, e.g. "doesn't match this entry".
  final String? ineligibleReason;

  Json toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'endsAt': endsAt.toUtc().toIso8601String(),
    'rules': rules,
    'isEligible': isEligible,
    'ineligibleReason': ineligibleReason,
  };

  @override
  bool operator ==(Object other) => other is ChallengeSummary && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The challenge promoted across the create flow: the Create sheet banner
/// and the Submit Entry hero (`GET /challenges/featured`).
class FeaturedChallenge {
  const FeaturedChallenge({
    required this.challenge,
    required this.prize,
    this.coverUrl,
    this.entryCount = 0,
    this.capacity = 0,
  });

  factory FeaturedChallenge.fromJson(Json json) => FeaturedChallenge(
    challenge: ChallengeSummary.fromJson(json['challenge'] as Json),
    prize: Money.fromJson(json['prize'] as Json),
    coverUrl: json['coverUrl'] as String?,
    entryCount: readInt(json['entryCount']),
    capacity: readInt(json['capacity']),
  );

  final ChallengeSummary challenge;

  /// The grand prize.
  final Money prize;
  final String? coverUrl;
  final int entryCount;

  /// Most entries accepted; 0 when uncapped.
  final int capacity;

  Json toJson() => {
    'challenge': challenge.toJson(),
    'prize': prize.toJson(),
    'coverUrl': coverUrl,
    'entryCount': entryCount,
    'capacity': capacity,
  };
}
