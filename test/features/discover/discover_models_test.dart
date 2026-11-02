import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/data/provider/discover_providers.dart';
import 'package:starapp/features/discover/data/repositories/mock_discover_repository.dart';

const _repo = MockDiscoverRepository();

/// Rejects every change, to check the optimistic updates roll back.
class _FailingRepository extends MockDiscoverRepository {
  const _FailingRepository();

  @override
  Future<void> dismissSuggestion(String creatorId) async =>
      throw Exception('offline');

  @override
  Future<void> setSaved(String videoId, {required bool saved}) async =>
      throw Exception('offline');
}

void main() {
  test('the fixtures parse and cover every state the tab shows', () async {
    final categories = await _repo.fetchCategories();
    final rising = await _repo.fetchRisingCreators();
    final suggested = await _repo.fetchSuggestedCreators();
    final challenges = await _repo.fetchFeaturedChallenges();
    final videos = await _repo.fetchVideos();

    expect(categories, isNotEmpty);
    expect(rising.any((r) => r.hasUnseenStory), isTrue, reason: 'ring');
    expect(rising.any((r) => !r.hasUnseenStory), isTrue, reason: 'watched');
    expect(rising.map((r) => r.reason).toSet(), RisingReason.values.toSet());
    expect(suggested.length, greaterThan(4), reason: 'a dismissal refills');
    expect(suggested.every((s) => s.followedBy.isNotEmpty), isTrue);
    expect(challenges.map((c) => c.tone).toSet(), ArenaTone.values.toSet());
    expect(challenges.first.prizePool, const Money(800000, Currency.usd));
    expect(challenges.every((c) => c.endsAt.isAfter(DateTime.now())), isTrue);
    expect(videos.items.any((v) => v.isSaved), isTrue);
    expect(videos.items.any((v) => !v.isSaved), isTrue);
    expect(videos.hasMore, isFalse);
  });

  test('toJson round-trips', () async {
    void roundTrip<T>(List<T> items, T Function(Map<String, dynamic>) from) {
      for (final item in items) {
        final json = (item as dynamic).toJson() as Map<String, dynamic>;
        expect((from(json) as dynamic).toJson(), json);
      }
    }

    roundTrip(await _repo.fetchCategories(), DiscoverCategory.fromJson);
    roundTrip(await _repo.fetchRisingCreators(), RisingCreator.fromJson);
    roundTrip(await _repo.fetchSuggestedCreators(), SuggestedCreator.fromJson);
    roundTrip(
      await _repo.fetchFeaturedChallenges(),
      FeaturedChallenge.fromJson,
    );
    roundTrip((await _repo.fetchVideos()).items, DiscoverVideo.fromJson);
  });

  test('unknown enum values and missing fields fall back', () {
    final rising = RisingCreator.fromJson({
      'creator': {'id': 'x', 'name': 'X', 'handle': 'x'},
      'storyKey': 'x',
      'reason': 'somethingNew',
    });
    expect(rising.reason, RisingReason.stars);
    expect(rising.hasUnseenStory, isFalse);

    final challenge = FeaturedChallenge.fromJson({
      'id': 'c',
      'arena': 'Arena',
      'title': 'T',
      'endsAt': '2026-12-01T00:00:00Z',
      'prizePool': {'amountMinor': '100', 'currency': 'NGN'},
      'tone': 'pink',
    });
    expect(challenge.tone, ArenaTone.navy);
    expect(challenge.submissions, 0);
    expect(challenge.prizePool.amountMinor, 100);
  });

  test('dismissing and bookmarking roll back when the server fails', () async {
    final container = ProviderContainer(
      overrides: [
        discoverRepositoryProvider.overrideWithValue(
          const _FailingRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final suggested = await container.read(suggestedCreatorsProvider.future);
    await expectLater(
      container
          .read(suggestedCreatorsProvider.notifier)
          .dismiss(suggested.first.id),
      throwsException,
    );
    expect(container.read(suggestedCreatorsProvider).value, suggested);

    final videos = await container.read(discoverVideosProvider.future);
    await expectLater(
      container
          .read(discoverVideosProvider.notifier)
          .toggleSaved(videos.first.id),
      throwsException,
    );
    expect(
      container.read(discoverVideosProvider).value!.first.isSaved,
      videos.first.isSaved,
    );
  });

  test('Paged reads the next cursor', () {
    final page = Paged.fromJson({
      'items': <Object>[],
      'nextCursor': 'abc',
    }, DiscoverVideo.fromJson);
    expect(page.hasMore, isTrue);
  });
}
