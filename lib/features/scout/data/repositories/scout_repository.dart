import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/models/company.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';
import 'package:starapp/features/scout/data/models/open_call_filters.dart';
import 'package:starapp/features/scout/data/models/scout_request.dart';

/// Scout: the open-call marketplace, the user's applications, company pages
/// and incoming Scout requests. Screens read the providers in
/// `scout_providers.dart`; `scoutRepositoryProvider` picks the mock or API
/// implementation.
abstract interface class ScoutRepository {
  /// Open calls matching [filters], featured first; pass the previous page's
  /// `nextCursor` for the next one.
  Future<Paged<OpenCallSummary>> listOpenCalls(
    OpenCallFilters filters, {
    String? cursor,
  });

  /// How many open calls match [filters]: the filter sheet's "Show N roles".
  Future<int> countOpenCalls(OpenCallFilters filters);

  Future<OpenCall> getOpenCall(String id);

  /// Applies in one tap and returns the new application.
  Future<Application> applyToOpenCall(String id);

  Future<ApplicationsSummary> getApplicationsSummary();

  /// The "Active" or "Closed" applications, newest first.
  Future<Paged<Application>> listMyApplications({
    required bool active,
    String? cursor,
  });

  Future<Company> getCompany(String id);

  Future<void> followCompany(String id);

  Future<void> unfollowCompany(String id);

  /// Pending Scout requests, newest first.
  Future<List<ScoutRequest>> listScoutRequests();

  Future<ScoutRequest> getScoutRequest(String id);

  /// Accepts and returns the conversation the company and user continue in.
  Future<String> acceptScoutRequest(String id);

  /// Opens (or reuses) a conversation about the request without accepting
  /// it, and returns its id.
  Future<String> askAboutScoutRequest(String id);

  Future<void> declineScoutRequest(String id);

  Future<void> reportScoutRequest(String id, {String? reason});
}
