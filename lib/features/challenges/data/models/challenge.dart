import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';

/// Where a challenge is in its life.
enum ChallengeStatus { upcoming, live, ended }

/// The talent group a challenge belongs to. The hub's arena pills, the
/// filters sheet and the list icons group challenges by it.
enum ChallengeArena {
  music('Music & Audio'),
  dance('Dance & Choreo'),
  acting('Acting & Monologue'),
  comedy('Comedy'),
  visualArts('Visual Arts'),
  photography('Photography'),
  other('Other');

  const ChallengeArena(this.label);

  final String label;
}

/// How a challenge bills its cash prize, e.g. "$5,000 USD · Bounty Pool".
enum PrizeKind {
  grandPrize('Grand Prize'),
  prizePool('Prize Pool'),
  bountyPool('Bounty Pool');

  const PrizeKind(this.label);

  final String label;
}

/// What a challenge pays: the cash, plus extras such as a scout review and
/// bonus Stars.
class ChallengePrize {
  const ChallengePrize({
    required this.amount,
    this.kind = PrizeKind.grandPrize,
    this.perks = const [],
    this.bonusStars = 0,
  });

  factory ChallengePrize.fromJson(Json json) => ChallengePrize(
    amount: Money.fromJson(json['amount'] as Json),
    kind: readEnum(PrizeKind.values, json['kind'], PrizeKind.grandPrize),
    perks: readStrings(json['perks']),
    bonusStars: readInt(json['bonusStars']),
  );

  final Money amount;
  final PrizeKind kind;

  /// Non-cash extras, e.g. "Sony Music scout review".
  final List<String> perks;
  final int bonusStars;

  Json toJson() => {
    'amount': amount.toJson(),
    'kind': kind.name,
    'perks': perks,
    'bonusStars': bonusStars,
  };
}

/// A challenge arena (`GET /challenges/{id}` and every challenge list).
class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.category,
    required this.arena,
    required this.status,
    required this.endsAt,
    this.opensAt,
    this.coverUrl,
    this.prize,
    this.entryCount = 0,
    this.capacity = 0,
    this.countryCount = 0,
    this.topStars = 0,
    this.isSaved = false,
    this.isReminderSet = false,
  });

  factory Challenge.fromJson(Json json) => Challenge(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? '',
    arena: readEnum(ChallengeArena.values, json['arena'], ChallengeArena.other),
    status: readEnum(
      ChallengeStatus.values,
      json['status'],
      ChallengeStatus.live,
    ),
    endsAt: readDate(json['endsAt']) ?? DateTime.now(),
    opensAt: readDate(json['opensAt']),
    coverUrl: json['coverUrl'] as String?,
    prize: json['prize'] == null
        ? null
        : ChallengePrize.fromJson(json['prize'] as Json),
    entryCount: readInt(json['entryCount']),
    capacity: readInt(json['capacity']),
    countryCount: readInt(json['countryCount']),
    topStars: readInt(json['topStars']),
    isSaved: json['isSaved'] as bool? ?? false,
    isReminderSet: json['isReminderSet'] as bool? ?? false,
  );

  final String id;
  final String title;

  /// The challenge's own tag, e.g. "Music & Production".
  final String category;
  final ChallengeArena arena;
  final ChallengeStatus status;

  /// When entries close (live) or closed (ended).
  final DateTime endsAt;

  /// When entries open; set while the challenge is upcoming.
  final DateTime? opensAt;
  final String? coverUrl;
  final ChallengePrize? prize;
  final int entryCount;

  /// Most entries accepted; 0 when uncapped.
  final int capacity;
  final int countryCount;

  /// Stars of the entry in first place.
  final int topStars;

  /// Bookmarked from the detail screen.
  final bool isSaved;

  /// The user asked to be told when it opens.
  final bool isReminderSet;

  Json toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'arena': arena.name,
    'status': status.name,
    'endsAt': endsAt.toUtc().toIso8601String(),
    'opensAt': opensAt?.toUtc().toIso8601String(),
    'coverUrl': coverUrl,
    'prize': prize?.toJson(),
    'entryCount': entryCount,
    'capacity': capacity,
    'countryCount': countryCount,
    'topStars': topStars,
    'isSaved': isSaved,
    'isReminderSet': isReminderSet,
  };

  Challenge copyWith({bool? isSaved, bool? isReminderSet}) => Challenge(
    id: id,
    title: title,
    category: category,
    arena: arena,
    status: status,
    endsAt: endsAt,
    opensAt: opensAt,
    coverUrl: coverUrl,
    prize: prize,
    entryCount: entryCount,
    capacity: capacity,
    countryCount: countryCount,
    topStars: topStars,
    isSaved: isSaved ?? this.isSaved,
    isReminderSet: isReminderSet ?? this.isReminderSet,
  );
}

/// A video entered into a challenge: a leading entry on a hub card, an
/// inspiration clip or the winning entry.
class ChallengeEntry {
  const ChallengeEntry({
    required this.id,
    this.creator,
    this.title,
    this.thumbnailUrl,
    this.stars = 0,
    this.viewCount = 0,
  });

  factory ChallengeEntry.fromJson(Json json) => ChallengeEntry(
    id: json['id'] as String,
    creator: json['creator'] == null
        ? null
        : CreatorSummary.fromJson(json['creator'] as Json),
    title: json['title'] as String?,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    stars: readInt(json['stars']),
    viewCount: readInt(json['viewCount']),
  );

  final String id;
  final CreatorSummary? creator;
  final String? title;
  final String? thumbnailUrl;
  final int stars;
  final int viewCount;

  Json toJson() => {
    'id': id,
    'creator': creator?.toJson(),
    'title': title,
    'thumbnailUrl': thumbnailUrl,
    'stars': stars,
    'viewCount': viewCount,
  };
}

/// The glyph on a challenge list row (rules, upcoming arenas, entries).
enum ChallengeIcon {
  music,
  clock,
  calendar,
  shieldCheck,
  trophy,
  zap,
  smile,
  image,
  star,
}

/// One rule in the rules sheet (`GET /challenges/{id}/rules`).
class ChallengeRule {
  const ChallengeRule({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  factory ChallengeRule.fromJson(Json json) => ChallengeRule(
    icon: readEnum(ChallengeIcon.values, json['icon'], ChallengeIcon.star),
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
  );

  final ChallengeIcon icon;
  final String title;
  final String subtitle;

  Json toJson() => {'icon': icon.name, 'title': title, 'subtitle': subtitle};
}

/// Everything the detail screen shows about one challenge
/// (`GET /challenges/{id}`).
class ChallengeDetail {
  const ChallengeDetail({
    required this.challenge,
    required this.about,
    this.rules = const [],
    this.inspiration = const [],
    this.topThree = const [],
  });

  factory ChallengeDetail.fromJson(Json json) => ChallengeDetail(
    challenge: Challenge.fromJson(json['challenge'] as Json),
    about: json['about'] as String? ?? '',
    rules: readStrings(json['rules']),
    inspiration: readList(json['inspiration'], ChallengeEntry.fromJson),
    topThree: readList(json['topThree'], LeaderboardEntry.fromJson),
  );

  final Challenge challenge;
  final String about;

  /// One line per rule; the full rules come from `challengeRulesProvider`.
  final List<String> rules;

  /// Example videos for the "Inspiration" strip.
  final List<ChallengeEntry> inspiration;

  /// The current top three of the live board.
  final List<LeaderboardEntry> topThree;

  Json toJson() => {
    'challenge': challenge.toJson(),
    'about': about,
    'rules': rules,
    'inspiration': [for (final e in inspiration) e.toJson()],
    'topThree': [for (final e in topThree) e.toJson()],
  };

  ChallengeDetail copyWith({Challenge? challenge}) => ChallengeDetail(
    challenge: challenge ?? this.challenge,
    about: about,
    rules: rules,
    inspiration: inspiration,
    topThree: topThree,
  );
}
