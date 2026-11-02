import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/challenges_hub.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/data/models/my_entries.dart';
import 'package:starapp/features/challenges/data/models/tier.dart';
import 'package:starapp/features/challenges/data/models/winners.dart';
import 'package:starapp/features/challenges/data/repositories/mock_challenges_repository.dart';

void main() {
  late MockChallengesRepository repository;

  setUp(() => repository = MockChallengesRepository());

  group('the mock fixtures parse and cover every designed state', () {
    test(
      'hub: featured arena with podium, leaders and banner arenas',
      () async {
        final hub = await repository.fetchHub();
        final featured = hub.featured!;

        expect(featured.challenge.status, ChallengeStatus.live);
        expect(featured.challenge.endsAt.isAfter(DateTime.now()), isTrue);
        expect(
          featured.challenge.prize!.amount,
          const Money(1000000, Currency.usd),
        );
        expect(featured.podium.map((e) => e.rank), [1, 2, 3]);
        expect(hub.arenas.map((a) => a.preview), [
          isA<ArenaLeadersPreview>(),
          isA<ArenaBannerPreview>(),
        ]);
      },
    );

    test('detail: rules, inspiration and the top three', () async {
      final detail = await repository.fetchChallenge('afro-beats-clash');

      expect(detail.rules, isNotEmpty);
      expect(detail.inspiration.every((e) => e.viewCount > 0), isTrue);
      expect(detail.topThree, hasLength(3));
      expect(await repository.fetchRules('afro-beats-clash'), isNotEmpty);
    });

    test('live board: the opening board, then one that has moved', () async {
      Future<Leaderboard> live() =>
          repository.fetchLeaderboard('afro-beats-clash', view: BoardView.live);
      final first = await live();
      final updated = await live();

      expect(first.entries.every((e) => e.movement == 0), isTrue);
      expect(first.me!.starsToTopTen, 93);
      expect(updated.entries.any((e) => e.movement > 0), isTrue);
      expect(updated.entries.any((e) => e.movement < 0), isTrue);
      expect(updated.me!.entry.movement, 2);
      expect(updated.updatedAt.isAfter(first.updatedAt), isTrue);
    });

    test('all-time board: podium, tiered rankings and your place', () async {
      final board = await repository.fetchLeaderboard(
        'afro-beats-clash',
        view: BoardView.allTime,
      );

      expect(board.season, 2026);
      expect(board.entries.length, greaterThan(3));
      expect(board.entries.skip(3).map((e) => e.creator.tier).toSet(), {
        CreatorTier.universeIcon,
        CreatorTier.superNova,
      });
      expect(board.me!.entry.rank, 1284);
      expect(board.me!.topPercent, 4);
    });

    test('the board picker offers a live and a finished challenge', () async {
      final challenges = await repository.fetchBoardChallenges();

      expect(challenges.map((c) => c.status), [
        ChallengeStatus.live,
        ChallengeStatus.ended,
      ]);
      final finished = await repository.fetchLeaderboard(
        challenges.last.id,
        view: BoardView.live,
      );
      expect(finished.me!.starsToTopTen, isNull);
    });

    test('upcoming arenas open in the future', () async {
      final upcoming = await repository.fetchUpcoming();

      expect(upcoming, isNotEmpty);
      for (final challenge in upcoming) {
        expect(challenge.status, ChallengeStatus.upcoming);
        expect(challenge.opensAt!.isAfter(DateTime.now()), isTrue);
        expect(challenge.isReminderSet, isFalse);
      }
    });

    test('my entries: live, placed with a prize, and completed', () async {
      final entries = (await repository.fetchMyEntries()).items;

      expect(entries.first.challenge.status, ChallengeStatus.live);
      expect(entries.any((e) => e.rank != null && e.prize != null), isTrue);
      expect(entries.any((e) => e.rank == null && e.bonusStars > 0), isTrue);
    });

    test('winners and the tier level-up', () async {
      final winners = await repository.fetchWinners('afro-dance-takeover');
      final tier = await repository.fetchTierLevelUp();

      expect(winners.challenge.status, ChallengeStatus.ended);
      expect(winners.winner.creator.tier, CreatorTier.universeIcon);
      expect(winners.runnersUp.map((p) => p.rank), [2, 3]);
      expect(winners.winningEntry.viewCount, 1200000);
      expect(tier.tier, CreatorTier.stellar);
      expect(tier.tier.next, CreatorTier.superNova);
      expect(tier.progress, inInclusiveRange(0, 1));
    });
  });

  group('toJson round-trips', () {
    test('hub, detail and rules', () async {
      final hub = await repository.fetchHub();
      expect(ChallengesHub.fromJson(hub.toJson()).toJson(), hub.toJson());

      final detail = await repository.fetchChallenge('afro-beats-clash');
      expect(
        ChallengeDetail.fromJson(detail.toJson()).toJson(),
        detail.toJson(),
      );

      for (final rule in await repository.fetchRules('afro-beats-clash')) {
        expect(ChallengeRule.fromJson(rule.toJson()).toJson(), rule.toJson());
      }
    });

    test('boards', () async {
      for (final view in BoardView.values) {
        final board = await repository.fetchLeaderboard(
          'afro-beats-clash',
          view: view,
        );
        expect(Leaderboard.fromJson(board.toJson()).toJson(), board.toJson());
      }
    });

    test('lists, winners and tier', () async {
      for (final c in await repository.fetchUpcoming()) {
        expect(Challenge.fromJson(c.toJson()).toJson(), c.toJson());
      }
      for (final e in (await repository.fetchMyEntries()).items) {
        expect(MyEntry.fromJson(e.toJson()).toJson(), e.toJson());
      }
      final winners = await repository.fetchWinners('afro-dance-takeover');
      expect(
        ChallengeWinners.fromJson(winners.toJson()).toJson(),
        winners.toJson(),
      );
      final tier = await repository.fetchTierLevelUp();
      expect(TierLevelUp.fromJson(tier.toJson()).toJson(), tier.toJson());
    });
  });

  test('unknown enums and missing fields fall back instead of throwing', () {
    final challenge = Challenge.fromJson({
      'id': 'x',
      'title': 'New',
      'arena': 'cooking',
      'status': 'paused',
      'prize': {
        'amount': {'amountMinor': 100, 'currency': 'XYZ'},
        'kind': 'jackpot',
      },
    });

    expect(challenge.arena, ChallengeArena.other);
    expect(challenge.status, ChallengeStatus.live);
    expect(challenge.prize!.kind, PrizeKind.grandPrize);
    expect(challenge.capacity, 0);
    expect(ArenaPreview.fromJson(const {}), isA<ArenaLeadersPreview>());
    expect(
      LeaderboardEntry.fromJson({
        'rank': '4',
        'stars': 12.0,
        'creator': {'id': 'a', 'name': 'A', 'handle': 'a'},
      }).stars,
      12,
    );
  });
}
