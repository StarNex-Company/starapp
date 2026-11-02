import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/challenges_hub.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/data/models/my_entries.dart';
import 'package:starapp/features/challenges/data/models/tier.dart';
import 'package:starapp/features/challenges/data/models/winners.dart';

/// Challenge content and the user's challenge actions. Screens read the
/// providers in `challenges_providers.dart`; `challengesRepositoryProvider`
/// picks the mock or API implementation.
abstract interface class ChallengesRepository {
  /// Tab counts, the featured arena and the other active arenas.
  Future<ChallengesHub> fetchHub();

  Future<ChallengeDetail> fetchChallenge(String challengeId);

  /// The full rules, for the rules sheet.
  Future<List<ChallengeRule>> fetchRules(String challengeId);

  /// Bookmarks the challenge, or removes the bookmark.
  Future<void> setSaved(String challengeId, {required bool saved});

  /// The challenges the leaderboard can switch between, live ones first.
  Future<List<Challenge>> fetchBoardChallenges();

  /// One page of a board, highest first. [region] and [arena] narrow it;
  /// pass the previous page's `nextCursor` for the next one.
  Future<Leaderboard> fetchLeaderboard(
    String challengeId, {
    required BoardView view,
    String? region,
    ChallengeArena? arena,
    String? cursor,
  });

  /// Arenas that haven't opened yet, soonest first.
  Future<List<Challenge>> fetchUpcoming();

  /// Asks to be told when the arena opens, or stops asking.
  Future<void> setReminder(String challengeId, {required bool remind});

  /// The user's entries, live ones first, then newest.
  Future<Paged<MyEntry>> fetchMyEntries({String? cursor});

  /// Results of a finished challenge.
  Future<ChallengeWinners> fetchWinners(String challengeId);

  /// The tier the user just reached.
  Future<TierLevelUp> fetchTierLevelUp();
}
