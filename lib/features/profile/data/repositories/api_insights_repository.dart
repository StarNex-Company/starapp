import 'package:intl/intl.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/data/models/talent_passport.dart';
import 'package:starapp/features/profile/data/repositories/insights_repository.dart';

/// Calendar dates as the API takes them: `2026-10-09`.
final _day = DateFormat('yyyy-MM-dd');

class ApiInsightsRepository implements InsightsRepository {
  const ApiInsightsRepository(this._client);

  final ApiClient _client;

  @override
  Future<Insights> fetchInsights(InsightsPeriod period) => _client.get(
    '/me/insights',
    query: {'from': _day.format(period.from), 'to': _day.format(period.to)},
    decode: (json) => Insights.fromJson(json as Json),
  );

  @override
  Future<Paged<TopPost>> fetchTopPosts({String? cursor}) => _client.get(
    '/me/posts/top',
    query: {'cursor': cursor},
    decode: (json) => Paged.fromJson(json as Json, TopPost.fromJson),
  );

  @override
  Future<TalentPassport> fetchTalentPassport() => _client.get(
    '/me/passport',
    decode: (json) => TalentPassport.fromJson(json as Json),
  );
}
