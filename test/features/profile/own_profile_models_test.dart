import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/data/models/talent_passport.dart';
import 'package:starapp/features/profile/data/repositories/mock_insights_repository.dart';
import 'package:starapp/features/profile/data/repositories/mock_my_profile_repository.dart';

void main() {
  const profiles = MockMyProfileRepository();
  const insights = MockInsightsRepository();

  group('My Profile', () {
    test('the fixture parses and covers every designed state', () async {
      final profile = await profiles.fetchMyProfile();

      expect(profile.tierProgress.nextTier, CreatorTier.stellar);
      expect(profile.tierProgress.topPercent, isNotNull, reason: 'rank pill');
      expect(profile.passport.metrics, hasLength(3));
      expect(
        {for (final c in profile.challenges) c.standing},
        ChallengeStanding.values.toSet(),
        reason: 'Live, Top 10 and Done pills',
      );
      expect({
        for (final s in profile.stats) s.kind,
      }, ProfileStatKind.values.toSet());
      expect(profile.stats.any((s) => s.isRecord), isTrue);
    });

    test('toJson round-trips', () async {
      final profile = await profiles.fetchMyProfile();
      expect(MyProfile.fromJson(profile.toJson()).toJson(), profile.toJson());

      final posts = await profiles.fetchPosts();
      expect(posts.items, isNotEmpty);
      expect(posts.items.any((p) => p.isChallengeEntry), isTrue);
      for (final post in posts.items) {
        expect(ProfileGridPost.fromJson(post.toJson()).toJson(), post.toJson());
      }

      final shortcuts = await profiles.fetchShortcuts();
      expect(shortcuts.walletBalance.format(), '₦1,240,500');
      expect(
        ShortcutsSummary.fromJson(shortcuts.toJson()).toJson(),
        shortcuts.toJson(),
      );
    });

    test('unknown stat and metric kinds are skipped, not misread', () {
      final profile = MyProfile.fromJson({
        'tierProgress': {'nextTier': 'somethingNew', 'progress': 3},
        'passport': {
          'score': 90,
          'metrics': [
            {'kind': 'consistency', 'percent': 96},
            {'kind': 'charisma', 'percent': 99},
          ],
        },
        'stats': [
          {'kind': 'views', 'value': 10},
          {'kind': 'revenue', 'value': 5},
        ],
      });

      expect(profile.tierProgress.nextTier, isNull);
      expect(profile.tierProgress.progress, 1);
      expect(
        profile.passport.metrics.single.kind,
        PassportMetricKind.consistency,
      );
      expect(profile.stats.single.kind, ProfileStatKind.views);
      expect(profile.challenges, isEmpty);
    });
  });

  group('Star Insights', () {
    final today = DateTime(2026, 11, 1);

    test('presets resolve to inclusive date ranges ending today', () {
      final week = InsightsPeriod.preset(InsightsRange.week, today: today);
      expect(week.from, DateTime(2026, 10, 26));
      expect(week.to, today);
      expect(
        InsightsPeriod.preset(InsightsRange.month, today: today).from,
        DateTime(2026, 10, 3),
      );
      expect(
        InsightsPeriod.preset(InsightsRange.sixMonths, today: today).from,
        DateTime(2026, 6),
      );
      expect(
        InsightsPeriod.preset(InsightsRange.year, today: today).from,
        DateTime(2026),
      );
      expect(
        InsightsPeriod.custom(
          from: DateTime(2026, 9, 1, 13),
          to: DateTime(2026, 9, 30, 8),
        ),
        InsightsPeriod.custom(
          from: DateTime(2026, 9, 1),
          to: DateTime(2026, 9, 30),
        ),
      );
    });

    test('every period parses, with dated bars, and round-trips', () async {
      final periods = [
        for (final range in InsightsRange.values)
          if (range != InsightsRange.custom) InsightsPeriod.preset(range),
        InsightsPeriod.custom(
          from: DateTime(2026, 9, 1),
          to: DateTime(2026, 9, 28),
        ),
      ];
      for (final period in periods) {
        final data = await insights.fetchInsights(period);
        expect(data.bars, isNotEmpty, reason: '${period.range}');
        expect(data.breakdown.fold<int>(0, (s, e) => s + e.percent), 100);
        expect(data.topPerforming, isNotEmpty);
        expect(data.boost, isNotNull);
        for (var i = 1; i < data.bars.length; i++) {
          expect(
            data.bars[i].periodStart.isAfter(data.bars[i - 1].periodStart),
            isTrue,
            reason: 'bars run oldest first',
          );
        }
        expect(Insights.fromJson(data.toJson()).toJson(), data.toJson());
      }

      final week = await insights.fetchInsights(
        InsightsPeriod.preset(InsightsRange.week),
      );
      expect(week.barPeriod, InsightsBarPeriod.day);
      expect(week.bars, hasLength(7));
    });

    test('top posts parse and round-trip', () async {
      final page = await insights.fetchTopPosts();
      expect(page.items, isNotEmpty);
      for (final post in page.items) {
        expect(TopPost.fromJson(post.toJson()).toJson(), post.toJson());
      }
    });
  });

  group('Talent Passport', () {
    test('the fixture parses and covers every designed state', () async {
      final passport = await insights.fetchTalentPassport();

      expect(Uri.parse(passport.linkUrl).isAbsolute, isTrue);
      expect(passport.metrics, hasLength(4));
      expect(passport.bestWork, hasLength(3));
      expect({
        for (final c in passport.challenges) c.result,
      }, PassportChallengeResult.values.toSet());
      expect(passport.challenges.first.prize?.format(), r'$600');
      expect({
        for (final s in passport.journey) s.state,
      }, PassportTierState.values.toSet());
      expect(passport.reviews.single.company.name, 'Kora Studios');
    });

    test('toJson round-trips', () async {
      final passport = await insights.fetchTalentPassport();
      expect(
        TalentPassport.fromJson(passport.toJson()).toJson(),
        passport.toJson(),
      );
    });
  });
}
