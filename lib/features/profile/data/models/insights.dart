import 'package:starapp/core/utils/json.dart';

/// The periods Star Insights can show. Week, Month and Year are also the
/// page's segmented control; the date range sheet lists them all.
enum InsightsRange { week, month, sixMonths, year, custom }

/// The days Star Insights covers, both inclusive, and the preset they came
/// from. Sent as `from=` / `to=` on `GET /me/insights`.
class InsightsPeriod {
  const InsightsPeriod._(this.range, this.from, this.to);

  /// A preset ending [today] (now by default): the last 7 or 30 days, the
  /// last six calendar months, or the year so far.
  factory InsightsPeriod.preset(InsightsRange range, {DateTime? today}) {
    assert(range != InsightsRange.custom, 'Use InsightsPeriod.custom');
    final now = today ?? DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = switch (range) {
      InsightsRange.week => DateTime(end.year, end.month, end.day - 6),
      InsightsRange.sixMonths => DateTime(end.year, end.month - 5),
      InsightsRange.year => DateTime(end.year),
      InsightsRange.month ||
      InsightsRange.custom => DateTime(end.year, end.month, end.day - 29),
    };
    return InsightsPeriod._(range, start, end);
  }

  InsightsPeriod.custom({required DateTime from, required DateTime to})
    : this._(
        InsightsRange.custom,
        DateTime(from.year, from.month, from.day),
        DateTime(to.year, to.month, to.day),
      );

  final InsightsRange range;

  /// Local dates at midnight.
  final DateTime from;
  final DateTime to;

  @override
  bool operator ==(Object other) =>
      other is InsightsPeriod &&
      other.range == range &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(range, from, to);
}

/// What one chart bar covers.
enum InsightsBarPeriod { day, week, month }

/// Star Insights for one [InsightsPeriod] (`GET /me/insights?from=&to=`).
/// The user's all-time total and tier come from the session;
/// `tierProgressProvider` says how far the next tier is.
class Insights {
  const Insights({
    required this.growthPercent,
    required this.starsEarned,
    required this.barPeriod,
    required this.bars,
    required this.breakdownTotal,
    required this.breakdown,
    this.topPerforming = const [],
    this.boost,
    this.since,
  });

  factory Insights.fromJson(Json json) => Insights(
    growthPercent: readInt(json['growthPercent']),
    starsEarned: readInt(json['starsEarned']),
    barPeriod: readEnum(
      InsightsBarPeriod.values,
      json['barPeriod'],
      InsightsBarPeriod.month,
    ),
    bars: readList(json['bars'], InsightsBar.fromJson),
    breakdownTotal: readInt(json['breakdownTotal']),
    breakdown: readList(
      json['breakdown'],
      StarSource.maybeFromJson,
    ).nonNulls.toList(),
    topPerforming: readList(json['topPerforming'], TopPost.fromJson),
    boost: json['boost'] == null
        ? null
        : InsightsBoost.fromJson(json['boost'] as Json),
    since: readDate(json['since']),
  );

  /// Growth against the previous period, e.g. 43.
  final int growthPercent;

  /// Stars earned in the period.
  final int starsEarned;

  /// What each of [bars] covers; the widgets label bars by it.
  final InsightsBarPeriod barPeriod;

  /// Oldest first; the last bar is the current one and is highlighted.
  final List<InsightsBar> bars;

  /// The figure in the middle of the donut.
  final int breakdownTotal;

  /// Largest first; percents add up to 100.
  final List<StarSource> breakdown;
  final List<TopPost> topPerforming;

  /// Active multiplier notice, if any.
  final InsightsBoost? boost;

  /// The first day with data, the earliest a custom range can start.
  final DateTime? since;

  Json toJson() => {
    'growthPercent': growthPercent,
    'starsEarned': starsEarned,
    'barPeriod': barPeriod.name,
    'bars': [for (final b in bars) b.toJson()],
    'breakdownTotal': breakdownTotal,
    'breakdown': [for (final s in breakdown) s.toJson()],
    'topPerforming': [for (final p in topPerforming) p.toJson()],
    'boost': boost?.toJson(),
    'since': since?.toUtc().toIso8601String(),
  };
}

/// Stars earned in the [InsightsBarPeriod] starting at [periodStart].
class InsightsBar {
  const InsightsBar({required this.periodStart, required this.value});

  factory InsightsBar.fromJson(Json json) => InsightsBar(
    periodStart: readDate(json['periodStart']) ?? DateTime.now(),
    value: readInt(json['value']),
  );

  final DateTime periodStart;
  final int value;

  Json toJson() => {
    'periodStart': periodStart.toUtc().toIso8601String(),
    'value': value,
  };
}

/// Where Stars come from. Serialized by name.
enum StarSourceKind {
  views('Views'),
  comments('Comments'),
  watchTime('Watch time'),
  shares('Shares'),
  challenges('Challenges');

  const StarSourceKind(this.label);

  final String label;
}

class StarSource {
  const StarSource(this.kind, this.percent);

  /// Null for a kind this app version doesn't know, so lists can skip it.
  static StarSource? maybeFromJson(Json json) {
    final kind = readEnumOrNull(StarSourceKind.values, json['kind']);
    return kind == null ? null : StarSource(kind, readInt(json['percent']));
  }

  final StarSourceKind kind;
  final int percent;

  Json toJson() => {'kind': kind.name, 'percent': percent};
}

/// A Stars multiplier earned by follower growth.
class InsightsBoost {
  const InsightsBoost({
    required this.multiplier,
    required this.followerGrowthPercent,
  });

  factory InsightsBoost.fromJson(Json json) => InsightsBoost(
    multiplier: readDouble(json['multiplier'], 1),
    followerGrowthPercent: readInt(json['followerGrowthPercent']),
  );

  /// e.g. 1.2 for "×1.2".
  final double multiplier;

  /// This week's follower growth that earned it.
  final int followerGrowthPercent;

  Json toJson() => {
    'multiplier': multiplier,
    'followerGrowthPercent': followerGrowthPercent,
  };
}

/// One of the user's posts with how it performed (Top performing,
/// `GET /me/posts/top`).
class TopPost {
  const TopPost({
    required this.id,
    required this.title,
    required this.views,
    required this.stars,
    required this.growthPercent,
    this.thumbnailUrl,
  });

  factory TopPost.fromJson(Json json) => TopPost(
    id: json['id'] as String,
    title: json['title'] as String,
    views: readInt(json['views']),
    stars: readInt(json['stars']),
    growthPercent: readInt(json['growthPercent']),
    thumbnailUrl: json['thumbnailUrl'] as String?,
  );

  /// Post id for `AppRoutes.post?id=`.
  final String id;
  final String title;
  final int views;
  final int stars;
  final int growthPercent;
  final String? thumbnailUrl;

  Json toJson() => {
    'id': id,
    'title': title,
    'views': views,
    'stars': stars,
    'growthPercent': growthPercent,
    'thumbnailUrl': thumbnailUrl,
  };
}
