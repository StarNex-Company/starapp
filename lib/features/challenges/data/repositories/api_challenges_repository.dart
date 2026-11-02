import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/challenges_hub.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/data/models/my_entries.dart';
import 'package:starapp/features/challenges/data/models/tier.dart';
import 'package:starapp/features/challenges/data/models/winners.dart';
import 'package:starapp/features/challenges/data/repositories/challenges_repository.dart';

/// Collections come back as `{"items": [...], "nextCursor": …}`.
class ApiChallengesRepository implements ChallengesRepository {
  const ApiChallengesRepository(this._client);

  final ApiClient _client;

  @override
  Future<ChallengesHub> fetchHub() => _client.get(
    '/challenges/hub',
    decode: (json) => ChallengesHub.fromJson(json as Json),
  );

  @override
  Future<ChallengeDetail> fetchChallenge(String challengeId) => _client.get(
    '/challenges/$challengeId',
    decode: (json) => ChallengeDetail.fromJson(json as Json),
  );

  @override
  Future<List<ChallengeRule>> fetchRules(String challengeId) => _client.get(
    '/challenges/$challengeId/rules',
    decode: (json) => _items(json, ChallengeRule.fromJson),
  );

  @override
  Future<void> setSaved(String challengeId, {required bool saved}) => saved
      ? _client.put<void>('/challenges/$challengeId/save')
      : _client.delete<void>('/challenges/$challengeId/save');

  @override
  Future<List<Challenge>> fetchBoardChallenges() => _client.get(
    '/me/challenges',
    decode: (json) => _items(json, Challenge.fromJson),
  );

  @override
  Future<Leaderboard> fetchLeaderboard(
    String challengeId, {
    required BoardView view,
    String? region,
    ChallengeArena? arena,
    String? cursor,
  }) => _client.get(
    '/challenges/$challengeId/leaderboard',
    query: {
      'view': view.name,
      'region': region,
      'arena': arena?.name,
      'cursor': cursor,
    },
    decode: (json) => Leaderboard.fromJson(json as Json),
  );

  @override
  Future<List<Challenge>> fetchUpcoming() => _client.get(
    '/challenges',
    query: {'status': ChallengeStatus.upcoming.name},
    decode: (json) => _items(json, Challenge.fromJson),
  );

  @override
  Future<void> setReminder(String challengeId, {required bool remind}) => remind
      ? _client.put<void>('/challenges/$challengeId/reminder')
      : _client.delete<void>('/challenges/$challengeId/reminder');

  @override
  Future<Paged<MyEntry>> fetchMyEntries({String? cursor}) => _client.get(
    '/me/entries',
    query: {'cursor': cursor},
    decode: (json) => Paged.fromJson(json as Json, MyEntry.fromJson),
  );

  @override
  Future<ChallengeWinners> fetchWinners(String challengeId) => _client.get(
    '/challenges/$challengeId/winners',
    decode: (json) => ChallengeWinners.fromJson(json as Json),
  );

  @override
  Future<TierLevelUp> fetchTierLevelUp() => _client.get(
    '/me/tier',
    decode: (json) => TierLevelUp.fromJson(json as Json),
  );

  static List<T> _items<T>(Object? json, T Function(Json json) item) =>
      readList((json as Json)['items'], item);
}
