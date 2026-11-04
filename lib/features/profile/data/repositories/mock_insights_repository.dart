import 'dart:math' as math;

import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/data/models/talent_passport.dart';
import 'package:starapp/features/profile/data/repositories/insights_repository.dart';

/// Serves the fixtures below, shaped like the `GET /me/insights`,
/// `GET /me/posts/top` and `GET /me/passport` responses, through the real
/// `fromJson`. Dates are relative to now.
class MockInsightsRepository implements InsightsRepository {
  const MockInsightsRepository();

  @override
  Future<Insights> fetchInsights(InsightsPeriod period) async =>
      Insights.fromJson(_insights(period, DateTime.now()));

  @override
  Future<Paged<TopPost>> fetchTopPosts({String? cursor}) async =>
      Paged.fromJson(_topPosts, TopPost.fromJson);

  @override
  Future<TalentPassport> fetchTalentPassport() async =>
      TalentPassport.fromJson(_passport(DateTime.now()));
}

const _thumbCurly = 'assets/images/shared/entry_video_frame.jpg';
const _thumbStudio = 'assets/images/shared/arena_studio.jpg';
const _thumbGlasses = 'assets/images/shared/avatar_you.jpg';
const _thumbChoir = 'assets/images/shared/post_adeboye_portrait.jpg';
const _thumbDancer = 'assets/images/stories/story_freestyle.jpg';
const _thumbCity = 'assets/images/shared/hub_banner_concept_art.jpg';

String _iso(DateTime time) => time.toUtc().toIso8601String();

Json _post(
  String id,
  String title,
  String thumbnail,
  int views,
  int stars,
  int growth,
) => {
  'id': id,
  'title': title,
  'thumbnailUrl': thumbnail,
  'views': views,
  'stars': stars,
  'growthPercent': growth,
};

Json _insights(InsightsPeriod period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);

  /// One bar per month, the last one this month.
  List<Json> months(List<int> values) => [
    for (var i = 0; i < values.length; i++)
      {
        'periodStart': _iso(
          DateTime(today.year, today.month - values.length + 1 + i),
        ),
        'value': values[i],
      },
  ];

  const growth = [48, 161, 62, 95, 140, 180, 210, 384];
  const breakdown = [
    {'kind': 'views', 'percent': 30},
    {'kind': 'comments', 'percent': 25},
    {'kind': 'watchTime', 'percent': 20},
    {'kind': 'shares', 'percent': 15},
    {'kind': 'challenges', 'percent': 10},
  ];
  final lateNightRun = _post(
    'late-night-vocal-run',
    'Late-night vocal run',
    _thumbCurly,
    4200,
    312,
    38,
  );
  final gbeduCover = _post(
    'gbedu-dance-cover',
    'Gbedu dance cover',
    _thumbStudio,
    2800,
    204,
    21,
  );

  final Json shared = {
    'boost': {'multiplier': 1.2, 'followerGrowthPercent': 24},
    'since': _iso(DateTime(today.year, today.month - 7, 14)),
  };

  return switch (period.range) {
    InsightsRange.week => {
      ...shared,
      'growthPercent': 12,
      'starsEarned': 96,
      'barPeriod': 'day',
      'bars': [
        for (final (i, value) in [8, 12, 10, 15, 11, 17, 23].indexed)
          {
            'periodStart': _iso(
              DateTime(today.year, today.month, today.day - 6 + i),
            ),
            'value': value,
          },
      ],
      'breakdownTotal': 96,
      'breakdown': [
        {'kind': 'views', 'percent': 34},
        {'kind': 'comments', 'percent': 22},
        {'kind': 'watchTime', 'percent': 21},
        {'kind': 'shares', 'percent': 13},
        {'kind': 'challenges', 'percent': 10},
      ],
      'topPerforming': [
        _post(
          'studio-session-freestyle',
          'Studio session freestyle',
          _thumbGlasses,
          1100,
          86,
          17,
        ),
        _post(
          'sunday-choir-rehearsal',
          'Sunday choir rehearsal',
          _thumbChoir,
          760,
          52,
          9,
        ),
      ],
    },
    InsightsRange.month || InsightsRange.sixMonths => {
      ...shared,
      'growthPercent': period.range == InsightsRange.month ? 43 : 186,
      'starsEarned': period.range == InsightsRange.month ? 384 : 1071,
      'barPeriod': 'month',
      'bars': months(growth.sublist(growth.length - 6)),
      'breakdownTotal': period.range == InsightsRange.month ? 1280 : 1071,
      'breakdown': breakdown,
      'topPerforming': [lateNightRun, gbeduCover],
    },
    InsightsRange.year => {
      ...shared,
      'growthPercent': 64,
      'starsEarned': 1280,
      'barPeriod': 'month',
      'bars': months(
        growth.sublist(growth.length - math.min(growth.length, today.month)),
      ),
      'breakdownTotal': 1280,
      'breakdown': breakdown,
      'topPerforming': [lateNightRun, gbeduCover],
    },
    InsightsRange.custom => {
      ...shared,
      'growthPercent': 18,
      'starsEarned': 214,
      'barPeriod': 'week',
      'bars': [
        for (
          var start = period.from, i = 0;
          !start.isAfter(period.to);
          start = DateTime(start.year, start.month, start.day + 7), i++
        )
          {
            'periodStart': _iso(start),
            'value': const [41, 55, 48, 70][i % 4],
          },
      ],
      'breakdownTotal': 214,
      'breakdown': breakdown,
      'topPerforming': [gbeduCover, lateNightRun],
    },
  };
}

final _topPosts = {
  'items': [
    _post(
      'late-night-vocal-run',
      'Late-night vocal run',
      _thumbStudio,
      4200,
      312,
      38,
    ),
    _post(
      'studio-session-freestyle',
      'Studio session freestyle',
      _thumbGlasses,
      2800,
      204,
      21,
    ),
    _post(
      'sunday-choir-rehearsal',
      'Sunday choir rehearsal',
      _thumbChoir,
      1900,
      141,
      12,
    ),
    _post(
      'afro-beats-cover-burna-boy',
      'Afro-beats cover · Burna Boy',
      _thumbDancer,
      1400,
      96,
      8,
    ),
    _post('behind-the-beat', 'Behind the beat', _thumbCity, 940, 61, 5),
  ],
  'nextCursor': null,
};

Json _passport(DateTime now) {
  String ago(int days) => _iso(now.subtract(Duration(days: days)));

  return {
    'passportId': 'SA-NG-2026-0418',
    'aiScore': 94,
    'linkUrl': 'https://starapp.io/p/emmanuel',
    'metrics': [
      {'kind': 'consistency', 'percent': 96},
      {'kind': 'engagement', 'percent': 93},
      {'kind': 'improvement', 'percent': 88},
      {'kind': 'challenge', 'percent': 90},
    ],
    'bestWork': [
      {
        'postId': 'late-night-vocal-run',
        'thumbnailUrl': _thumbCurly,
        'views': 48000,
      },
      {
        'postId': 'studio-session-freestyle',
        'thumbnailUrl': _thumbStudio,
        'views': 31000,
      },
      {
        'postId': 'gbedu-dance-cover',
        'thumbnailUrl': _thumbCurly,
        'views': 12000,
      },
    ],
    'challenges': [
      {
        'challengeId': 'afro-dance-takeover',
        'title': 'Afro-Dance Takeover',
        'result': 'placed',
        'date': ago(45),
        'rank': 7,
        'entrants': 1248,
        'prize': {'amountMinor': 60000, 'currency': 'USD'},
      },
      {
        'challengeId': 'afro-beats-clash',
        'title': 'Afro-Beats Producer & Vocal Clash',
        'result': 'entered',
        'date': ago(12),
        'rank': 14,
        'isLive': true,
      },
    ],
    'journey': [
      {'tier': 'shootingStar', 'state': 'reached', 'reachedAt': ago(230)},
      {'tier': 'risingNova', 'state': 'current', 'reachedAt': ago(110)},
      {'tier': 'stellar', 'state': 'next', 'starsAway': 721},
    ],
    'reviews': [
      {
        'company': {
          'id': 'kora-studios',
          'name': 'Kora Studios',
          'type': 'Film studio',
          'city': 'Lagos',
          'country': 'Nigeria',
          'isVerified': true,
        },
        'role': 'Featured dancer',
        'date': ago(80),
        'rating': 5,
        'quote':
            'Exceptional stage presence and incredibly professional on set. '
            "We'd book Emmanuel again in a heartbeat.",
      },
    ],
  };
}
