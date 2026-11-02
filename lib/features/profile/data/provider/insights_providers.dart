import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/data/models/talent_passport.dart';
import 'package:starapp/features/profile/data/provider/my_profile_providers.dart';
import 'package:starapp/features/profile/data/repositories/api_insights_repository.dart';
import 'package:starapp/features/profile/data/repositories/insights_repository.dart';
import 'package:starapp/features/profile/data/repositories/mock_insights_repository.dart';

final insightsRepositoryProvider = Provider<InsightsRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockInsightsRepository.new,
    api: ApiInsightsRepository.new,
  ),
);

/// The period Star Insights shows, set by the segmented control and the date
/// range sheet. Starts on Month (the last 30 days).
final insightsRangeProvider =
    NotifierProvider<InsightsRangeNotifier, InsightsPeriod>(
      InsightsRangeNotifier.new,
    );

class InsightsRangeNotifier extends Notifier<InsightsPeriod> {
  @override
  InsightsPeriod build() => InsightsPeriod.preset(InsightsRange.month);

  /// A preset ending today; use [selectCustom] for [InsightsRange.custom].
  void select(InsightsRange range) {
    if (range == InsightsRange.custom) return;
    state = InsightsPeriod.preset(range);
  }

  void selectCustom(DateTime from, DateTime to) {
    state = InsightsPeriod.custom(from: from, to: to);
  }
}

/// Star Insights for one period.
final insightsProvider = FutureProvider.family<Insights, InsightsPeriod>(
  (ref, period) => ref.watch(insightsRepositoryProvider).fetchInsights(period),
);

/// How far the user is from their next tier; the same figure as the tier
/// card on My Profile.
final tierProgressProvider = FutureProvider<TierProgress>(
  (ref) async => (await ref.watch(myProfileProvider.future)).tierProgress,
);

/// All the user's posts, best performing first. [TopPostsNotifier.loadMore]
/// appends the next page.
final topPostsProvider = AsyncNotifierProvider<TopPostsNotifier, List<TopPost>>(
  TopPostsNotifier.new,
);

class TopPostsNotifier extends AsyncNotifier<List<TopPost>> {
  String? _nextCursor;
  bool _loadingMore = false;

  @override
  Future<List<TopPost>> build() async {
    final page = await ref.watch(insightsRepositoryProvider).fetchTopPosts();
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
          .read(insightsRepositoryProvider)
          .fetchTopPosts(cursor: cursor);
      _nextCursor = page.nextCursor;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }
}

final talentPassportProvider = FutureProvider<TalentPassport>(
  (ref) => ref.watch(insightsRepositoryProvider).fetchTalentPassport(),
);
