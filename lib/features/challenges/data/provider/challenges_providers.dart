import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/challenges_hub.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/data/models/my_entries.dart';
import 'package:starapp/features/challenges/data/models/tier.dart';
import 'package:starapp/features/challenges/data/models/winners.dart';
import 'package:starapp/features/challenges/data/repositories/api_challenges_repository.dart';
import 'package:starapp/features/challenges/data/repositories/challenges_repository.dart';
import 'package:starapp/features/challenges/data/repositories/mock_challenges_repository.dart';

final challengesRepositoryProvider = Provider<ChallengesRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockChallengesRepository.new,
    api: ApiChallengesRepository.new,
  ),
);

/// The challenge the detail screen and leaderboard show when their route
/// carries no id: the featured arena.
const defaultChallengeId = 'afro-beats-clash';

/// The finished challenge the winners screen shows when its route carries no
/// id: the latest one.
const defaultWinnersChallengeId = 'afro-dance-takeover';

/// The challenges tab: tab counts, the featured arena and the other active
/// arenas.
final challengesHubProvider = FutureProvider<ChallengesHub>(
  (ref) => ref.watch(challengesRepositoryProvider).fetchHub(),
);

/// One challenge in full, by id, with its bookmark.
final challengeDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ChallengeDetailNotifier, ChallengeDetail, String>(
      ChallengeDetailNotifier.new,
    );

class ChallengeDetailNotifier extends AsyncNotifier<ChallengeDetail> {
  ChallengeDetailNotifier(this.challengeId);

  final String challengeId;

  @override
  Future<ChallengeDetail> build() =>
      ref.watch(challengesRepositoryProvider).fetchChallenge(challengeId);

  /// Bookmarks the challenge or removes the bookmark at once; rolls back and
  /// rethrows if the server refuses.
  Future<void> toggleSaved() async {
    final detail = state.value;
    if (detail == null) return;
    final saved = !detail.challenge.isSaved;
    state = AsyncData(
      detail.copyWith(challenge: detail.challenge.copyWith(isSaved: saved)),
    );
    try {
      await ref
          .read(challengesRepositoryProvider)
          .setSaved(challengeId, saved: saved);
    } catch (_) {
      if (ref.mounted) state = AsyncData(detail);
      rethrow;
    }
  }
}

/// A challenge's full rules, for the rules sheet.
final challengeRulesProvider = FutureProvider.autoDispose
    .family<List<ChallengeRule>, String>(
      (ref, challengeId) =>
          ref.watch(challengesRepositoryProvider).fetchRules(challengeId),
    );

/// The challenges the leaderboard's picker switches between.
final boardChallengesProvider = FutureProvider.autoDispose<List<Challenge>>(
  (ref) => ref.watch(challengesRepositoryProvider).fetchBoardChallenges(),
);

/// Which board to load and how it's narrowed.
typedef LeaderboardQuery = ({
  String challengeId,
  BoardView view,
  String? region,
  ChallengeArena? arena,
});

/// One board, page by page. [LeaderboardNotifier.refresh] pulls in the latest
/// standings in place; [LeaderboardNotifier.loadMore] appends the next page.
final leaderboardProvider = AsyncNotifierProvider.autoDispose
    .family<LeaderboardNotifier, Leaderboard, LeaderboardQuery>(
      LeaderboardNotifier.new,
    );

class LeaderboardNotifier extends AsyncNotifier<Leaderboard> {
  LeaderboardNotifier(this.query);

  final LeaderboardQuery query;
  bool _loadingMore = false;

  Future<Leaderboard> _fetch(
    ChallengesRepository repository, {
    String? cursor,
  }) => repository.fetchLeaderboard(
    query.challengeId,
    view: query.view,
    region: query.region,
    arena: query.arena,
    cursor: cursor,
  );

  @override
  Future<Leaderboard> build() =>
      _fetch(ref.watch(challengesRepositoryProvider));

  bool get hasMore => state.value?.hasMore ?? false;

  /// Replaces the board with its latest first page, keeping the current one
  /// on screen while it loads. Rethrows if the request fails.
  Future<void> refresh() async {
    if (!state.hasValue) return;
    final fresh = await _fetch(ref.read(challengesRepositoryProvider));
    if (ref.mounted) state = AsyncData(fresh);
  }

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final board = state.value;
    final cursor = board?.nextCursor;
    if (board == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final next = await _fetch(
        ref.read(challengesRepositoryProvider),
        cursor: cursor,
      );
      if (ref.mounted) state = AsyncData(board.appending(next));
    } finally {
      _loadingMore = false;
    }
  }
}

/// Arenas that haven't opened yet, with the user's reminders.
final upcomingChallengesProvider =
    AsyncNotifierProvider<UpcomingChallengesNotifier, List<Challenge>>(
      UpcomingChallengesNotifier.new,
    );

class UpcomingChallengesNotifier extends AsyncNotifier<List<Challenge>> {
  @override
  Future<List<Challenge>> build() =>
      ref.watch(challengesRepositoryProvider).fetchUpcoming();

  /// Sets or clears the reminder for [challengeId] at once; rolls back and
  /// rethrows if the server refuses. Returns whether it is now set.
  Future<bool> toggleReminder(String challengeId) async {
    final challenges = state.value;
    final challenge = challenges?.where((c) => c.id == challengeId).firstOrNull;
    if (challenges == null || challenge == null) return false;
    final remind = !challenge.isReminderSet;
    state = AsyncData([
      for (final c in challenges)
        c.id == challengeId ? c.copyWith(isReminderSet: remind) : c,
    ]);
    try {
      await ref
          .read(challengesRepositoryProvider)
          .setReminder(challengeId, remind: remind);
    } catch (_) {
      if (ref.mounted) state = AsyncData(challenges);
      rethrow;
    }
    return remind;
  }
}

/// The signed-in user's entries, live ones first. [MyEntriesNotifier.loadMore]
/// appends the next page.
final myEntriesProvider =
    AsyncNotifierProvider<MyEntriesNotifier, List<MyEntry>>(
      MyEntriesNotifier.new,
    );

class MyEntriesNotifier extends AsyncNotifier<List<MyEntry>> {
  String? _nextCursor;
  bool _loadingMore = false;

  @override
  Future<List<MyEntry>> build() async {
    final page = await ref.watch(challengesRepositoryProvider).fetchMyEntries();
    _nextCursor = page.nextCursor;
    return page.items;
  }

  bool get hasMore => _nextCursor != null;

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final items = state.value;
    final cursor = _nextCursor;
    if (items == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await ref
          .read(challengesRepositoryProvider)
          .fetchMyEntries(cursor: cursor);
      _nextCursor = page.nextCursor;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }
}

/// Results of a finished challenge, by id.
final challengeWinnersProvider = FutureProvider.autoDispose
    .family<ChallengeWinners, String>(
      (ref, challengeId) =>
          ref.watch(challengesRepositoryProvider).fetchWinners(challengeId),
    );

/// The tier the user just reached.
final tierLevelUpProvider = FutureProvider.autoDispose<TierLevelUp>(
  (ref) => ref.watch(challengesRepositoryProvider).fetchTierLevelUp(),
);
