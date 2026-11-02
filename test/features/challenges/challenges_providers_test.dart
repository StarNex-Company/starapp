import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/data/provider/challenges_providers.dart';
import 'package:starapp/features/challenges/data/repositories/mock_challenges_repository.dart';

/// Serves the fixtures but refuses every change.
class _OfflineRepository extends MockChallengesRepository {
  @override
  Future<void> setSaved(String challengeId, {required bool saved}) async =>
      throw const NetworkException();

  @override
  Future<void> setReminder(String challengeId, {required bool remind}) async =>
      throw const NetworkException();
}

ProviderContainer _container(MockChallengesRepository repository) {
  final container = ProviderContainer(
    overrides: [challengesRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('a reminder sets at once and rolls back when refused', () async {
    final container = _container(_OfflineRepository());
    final upcoming = await container.read(upcomingChallengesProvider.future);
    final id = upcoming.first.id;
    final notifier = container.read(upcomingChallengesProvider.notifier);

    final request = notifier.toggleReminder(id);
    expect(
      container.read(upcomingChallengesProvider).value!.first.isReminderSet,
      isTrue,
    );
    await expectLater(request, throwsA(isA<NetworkException>()));
    expect(
      container.read(upcomingChallengesProvider).value!.first.isReminderSet,
      isFalse,
    );
  });

  test('a bookmark sets at once and rolls back when refused', () async {
    final container = _container(_OfflineRepository());
    final provider = challengeDetailProvider(defaultChallengeId);
    container.listen(provider, (_, _) {});
    await container.read(provider.future);

    final request = container.read(provider.notifier).toggleSaved();
    expect(container.read(provider).value!.challenge.isSaved, isTrue);
    await expectLater(request, throwsA(isA<NetworkException>()));
    expect(container.read(provider).value!.challenge.isSaved, isFalse);
  });

  test('refreshing the live board brings in the latest standings', () async {
    final container = _container(MockChallengesRepository());
    final provider = leaderboardProvider((
      challengeId: defaultChallengeId,
      view: BoardView.live,
      region: null,
      arena: null,
    ));
    container.listen(provider, (_, _) {});
    final before = await container.read(provider.future);

    await container.read(provider.notifier).refresh();
    final after = container.read(provider).value!;

    expect(before.me!.entry.rank, 16);
    expect(after.me!.entry.rank, 14);
    expect(after.entries.any((e) => e.movement != 0), isTrue);
  });
}
