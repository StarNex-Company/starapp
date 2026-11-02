import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/features/search/data/models/search_models.dart';
import 'package:starapp/features/search/data/provider/search_providers.dart';
import 'package:starapp/features/search/data/repositories/mock_search_repository.dart';

const _repo = MockSearchRepository();

/// Rejects every change to the recent searches.
class _FailingRepository extends MockSearchRepository {
  const _FailingRepository();

  @override
  Future<void> removeRecentSearch(String term) async =>
      throw Exception('offline');

  @override
  Future<void> clearRecentSearches() async => throw Exception('offline');
}

void main() {
  test('the fixtures cover the empty, results and no-results states', () async {
    expect(await _repo.fetchRecentSearches(), isNotEmpty);
    expect(await _repo.fetchTrendingSearches(), isNotEmpty);

    final afro = await _repo.search('afro');
    expect(afro.creators, isNotEmpty);
    expect(afro.challenges, isNotEmpty);
    expect(afro.creators.first.tier, CreatorTier.universeIcon);

    final dance = await _repo.search('dance');
    expect(dance.challenges.map((c) => c.status).toSet(), {
      SearchChallengeStatus.live,
      SearchChallengeStatus.upcoming,
      SearchChallengeStatus.ended,
    });

    expect((await _repo.search('zzzz')).isEmpty, isTrue);
  });

  test('every trending search finds something', () async {
    for (final term in await _repo.fetchTrendingSearches()) {
      expect((await _repo.search(term)).isEmpty, isFalse, reason: term);
    }
  });

  test('toJson round-trips', () async {
    final results = await _repo.search('a');
    expect(results.isEmpty, isFalse);
    final json = results.toJson();
    expect(SearchResults.fromJson(json).toJson(), json);
  });

  test('unknown status and missing fields fall back', () {
    final c = SearchChallenge.fromJson({
      'id': 'x',
      'title': 'X',
      'status': 'paused',
    });
    expect(c.status, SearchChallengeStatus.live);
    expect(c.entries, 0);
    expect(c.endsAt, isNull);
    expect(SearchResults.fromJson({}).isEmpty, isTrue);
  });

  test('recent search edits roll back when the server fails', () async {
    final container = ProviderContainer(
      overrides: [
        searchRepositoryProvider.overrideWithValue(const _FailingRepository()),
      ],
    );
    addTearDown(container.dispose);

    final recent = await container.read(recentSearchesProvider.future);
    final notifier = container.read(recentSearchesProvider.notifier);
    await expectLater(notifier.remove(recent.first), throwsException);
    expect(container.read(recentSearchesProvider).value, recent);
    await expectLater(notifier.clear(), throwsException);
    expect(container.read(recentSearchesProvider).value, recent);
  });
}
