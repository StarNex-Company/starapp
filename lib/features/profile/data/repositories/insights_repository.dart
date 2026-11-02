import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/data/models/talent_passport.dart';

/// The signed-in creator's analytics: Star Insights per period, their top
/// posts and their Talent Passport. Screens read the providers in
/// `insights_providers.dart`; `insightsRepositoryProvider` picks the mock or
/// API implementation.
abstract interface class InsightsRepository {
  Future<Insights> fetchInsights(InsightsPeriod period);

  /// Every post, best performing first; pass the previous page's
  /// `nextCursor` for the next one.
  Future<Paged<TopPost>> fetchTopPosts({String? cursor});

  Future<TalentPassport> fetchTalentPassport();
}
