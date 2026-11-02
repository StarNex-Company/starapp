import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/models/company.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';
import 'package:starapp/features/scout/data/models/open_call_filters.dart';
import 'package:starapp/features/scout/data/models/scout_request.dart';
import 'package:starapp/features/scout/data/repositories/scout_repository.dart';

class ApiScoutRepository implements ScoutRepository {
  const ApiScoutRepository(this._client);

  final ApiClient _client;

  @override
  Future<Paged<OpenCallSummary>> listOpenCalls(
    OpenCallFilters filters, {
    String? cursor,
  }) => _client.get(
    '/scout/calls',
    query: {...filters.toQuery(), 'cursor': cursor},
    decode: (json) => Paged.fromJson(json as Json, OpenCallSummary.fromJson),
  );

  @override
  Future<int> countOpenCalls(OpenCallFilters filters) => _client.get(
    '/scout/calls/count',
    query: filters.toQuery(),
    decode: (json) => readInt((json as Json)['count']),
  );

  @override
  Future<OpenCall> getOpenCall(String id) => _client.get(
    '/scout/calls/$id',
    decode: (json) => OpenCall.fromJson(json as Json),
  );

  @override
  Future<Application> applyToOpenCall(String id) => _client.post(
    '/scout/calls/$id/apply',
    decode: (json) => Application.fromJson(json as Json),
  );

  @override
  Future<ApplicationsSummary> getApplicationsSummary() => _client.get(
    '/scout/applications/summary',
    decode: (json) => ApplicationsSummary.fromJson(json as Json),
  );

  @override
  Future<Paged<Application>> listMyApplications({
    required bool active,
    String? cursor,
  }) => _client.get(
    '/scout/applications',
    query: {'status': active ? 'active' : 'closed', 'cursor': cursor},
    decode: (json) => Paged.fromJson(json as Json, Application.fromJson),
  );

  @override
  Future<Company> getCompany(String id) => _client.get(
    '/companies/$id',
    decode: (json) => Company.fromJson(json as Json),
  );

  @override
  Future<void> followCompany(String id) =>
      _client.put<void>('/companies/$id/follow');

  @override
  Future<void> unfollowCompany(String id) =>
      _client.delete<void>('/companies/$id/follow');

  @override
  Future<List<ScoutRequest>> listScoutRequests() => _client.get(
    '/scout/requests',
    decode: (json) => readList(json, ScoutRequest.fromJson),
  );

  @override
  Future<ScoutRequest> getScoutRequest(String id) => _client.get(
    '/scout/requests/$id',
    decode: (json) => ScoutRequest.fromJson(json as Json),
  );

  @override
  Future<String> acceptScoutRequest(String id) =>
      _client.post('/scout/requests/$id/accept', decode: _conversationId);

  @override
  Future<String> askAboutScoutRequest(String id) =>
      _client.post('/scout/requests/$id/ask', decode: _conversationId);

  @override
  Future<void> declineScoutRequest(String id) =>
      _client.post<void>('/scout/requests/$id/decline');

  @override
  Future<void> reportScoutRequest(String id, {String? reason}) => _client
      .post<void>('/scout/requests/$id/report', data: {'reason': reason});

  /// `{"conversationId": "c_123"}`.
  static String _conversationId(Object? json) =>
      (json as Json)['conversationId'] as String;
}
