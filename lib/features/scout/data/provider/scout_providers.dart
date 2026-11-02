import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/models/company.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';
import 'package:starapp/features/scout/data/models/open_call_filters.dart';
import 'package:starapp/features/scout/data/models/scout_request.dart';
import 'package:starapp/features/scout/data/repositories/api_scout_repository.dart';
import 'package:starapp/features/scout/data/repositories/mock_scout_repository.dart';
import 'package:starapp/features/scout/data/repositories/scout_repository.dart';

final scoutRepositoryProvider = Provider<ScoutRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockScoutRepository.new,
    api: ApiScoutRepository.new,
  ),
);

// ---------------------------------------------------------------------------
// Marketplace

/// The marketplace's search, category chips and filter-sheet choices.
final openCallFiltersProvider =
    NotifierProvider<OpenCallFiltersNotifier, OpenCallFilters>(
      OpenCallFiltersNotifier.new,
    );

class OpenCallFiltersNotifier extends Notifier<OpenCallFilters> {
  @override
  OpenCallFilters build() => const OpenCallFilters();

  void set(OpenCallFilters filters) {
    if (filters != state) state = filters;
  }
}

/// Open calls for the current filters, featured first. Changing a filter
/// reloads it; [OpenCallsNotifier.loadMore] appends the next page.
final openCallsProvider =
    AsyncNotifierProvider<OpenCallsNotifier, List<OpenCallSummary>>(
      OpenCallsNotifier.new,
    );

class OpenCallsNotifier extends AsyncNotifier<List<OpenCallSummary>> {
  String? _nextCursor;
  bool _loadingMore = false;

  @override
  Future<List<OpenCallSummary>> build() async {
    final filters = ref.watch(openCallFiltersProvider);
    final page = await ref
        .watch(scoutRepositoryProvider)
        .listOpenCalls(filters);
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
          .read(scoutRepositoryProvider)
          .listOpenCalls(ref.read(openCallFiltersProvider), cursor: cursor);
      _nextCursor = page.nextCursor;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }
}

/// How many calls [OpenCallFilters] would show: the sheet's "Show N roles".
final openCallCountProvider = FutureProvider.autoDispose
    .family<int, OpenCallFilters>(
      (ref, filters) =>
          ref.watch(scoutRepositoryProvider).countOpenCalls(filters),
    );

final openCallProvider = FutureProvider.autoDispose.family<OpenCall, String>(
  (ref, id) => ref.watch(scoutRepositoryProvider).getOpenCall(id),
);

// ---------------------------------------------------------------------------
// Applying

/// Applications in flight and those made this session, keyed by call id.
class ScoutApplyState {
  const ScoutApplyState({this.applying = const {}, this.applied = const {}});

  final Set<String> applying;
  final Map<String, ApplicationStatus> applied;

  bool isApplying(String callId) => applying.contains(callId);

  /// The user's status on [call], counting applications made since it
  /// loaded.
  ApplicationStatus? statusOf(OpenCallSummary call) =>
      applied[call.id] ?? call.myStatus;
}

/// One-tap applying, shared by the marketplace, the call page and company
/// pages so a call shows the same state everywhere.
final scoutApplyProvider =
    NotifierProvider<ScoutApplyNotifier, ScoutApplyState>(
      ScoutApplyNotifier.new,
    );

class ScoutApplyNotifier extends Notifier<ScoutApplyState> {
  @override
  ScoutApplyState build() => const ScoutApplyState();

  /// Marks the call applied and counts it at once, then sends it. The
  /// button spins until the server confirms; on failure everything rolls
  /// back and the error is rethrown for the screen to show.
  Future<void> apply(String callId) async {
    if (state.isApplying(callId) || state.applied.containsKey(callId)) return;
    _set(callId, applying: true, status: ApplicationStatus.sent);
    ref.read(applicationsSummaryProvider.notifier).adjustSent(1);
    try {
      final application = await ref
          .read(scoutRepositoryProvider)
          .applyToOpenCall(callId);
      _set(callId, applying: false, status: application.status);
    } catch (_) {
      _set(callId, applying: false, status: null);
      ref.read(applicationsSummaryProvider.notifier).adjustSent(-1);
      rethrow;
    }
    ref.invalidate(myApplicationsProvider);
  }

  void _set(
    String callId, {
    required bool applying,
    required ApplicationStatus? status,
  }) {
    state = ScoutApplyState(
      applying: applying
          ? {...state.applying, callId}
          : ({...state.applying}..remove(callId)),
      applied: status == null
          ? ({...state.applied}..remove(callId))
          : {...state.applied, callId: status},
    );
  }
}

// ---------------------------------------------------------------------------
// Applications

/// "Your applications" counts; applying bumps them at once.
final applicationsSummaryProvider =
    AsyncNotifierProvider<ApplicationsSummaryNotifier, ApplicationsSummary>(
      ApplicationsSummaryNotifier.new,
    );

class ApplicationsSummaryNotifier extends AsyncNotifier<ApplicationsSummary> {
  @override
  Future<ApplicationsSummary> build() =>
      ref.watch(scoutRepositoryProvider).getApplicationsSummary();

  void adjustSent(int delta) {
    final summary = state.value;
    if (summary != null) state = AsyncData(summary.withSent(delta));
  }
}

/// The user's "Active" (`true`) or "Closed" (`false`) applications;
/// [MyApplicationsNotifier.loadMore] appends the next page.
final myApplicationsProvider = AsyncNotifierProvider.autoDispose
    .family<MyApplicationsNotifier, List<Application>, bool>(
      MyApplicationsNotifier.new,
    );

class MyApplicationsNotifier extends AsyncNotifier<List<Application>> {
  MyApplicationsNotifier(this.active);

  final bool active;
  String? _nextCursor;
  bool _loadingMore = false;

  @override
  Future<List<Application>> build() async {
    final page = await ref
        .watch(scoutRepositoryProvider)
        .listMyApplications(active: active);
    _nextCursor = page.nextCursor;
    return page.items;
  }

  bool get hasMore => _nextCursor != null;

  Future<void> loadMore() async {
    final items = state.value;
    final cursor = _nextCursor;
    if (items == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await ref
          .read(scoutRepositoryProvider)
          .listMyApplications(active: active, cursor: cursor);
      _nextCursor = page.nextCursor;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }
}

// ---------------------------------------------------------------------------
// Companies

final companyProvider = AsyncNotifierProvider.autoDispose
    .family<CompanyNotifier, Company, String>(CompanyNotifier.new);

class CompanyNotifier extends AsyncNotifier<Company> {
  CompanyNotifier(this.companyId);

  final String companyId;

  @override
  Future<Company> build() =>
      ref.watch(scoutRepositoryProvider).getCompany(companyId);

  /// Follows or unfollows at once and returns whether the user now follows
  /// the company; rolls back and rethrows if the server rejects it.
  Future<bool> toggleFollow() async {
    final company = state.value;
    if (company == null) return false;
    final follow = !company.isFollowing;
    state = AsyncData(
      company.copyWith(
        isFollowing: follow,
        followersCount: company.followersCount + (follow ? 1 : -1),
      ),
    );
    final repository = ref.read(scoutRepositoryProvider);
    try {
      follow
          ? await repository.followCompany(companyId)
          : await repository.unfollowCompany(companyId);
    } catch (_) {
      if (ref.mounted) state = AsyncData(company);
      rethrow;
    }
    return follow;
  }
}

// ---------------------------------------------------------------------------
// Scout requests

/// Pending Scout requests for the inbox's Requests page.
final scoutRequestsProvider =
    AsyncNotifierProvider<ScoutRequestsNotifier, List<ScoutRequest>>(
      ScoutRequestsNotifier.new,
    );

class ScoutRequestsNotifier extends AsyncNotifier<List<ScoutRequest>> {
  @override
  Future<List<ScoutRequest>> build() =>
      ref.watch(scoutRepositoryProvider).listScoutRequests();
}

/// One Scout request and the user's answer to it.
final scoutRequestProvider = AsyncNotifierProvider.autoDispose
    .family<ScoutRequestNotifier, ScoutRequest, String>(
      ScoutRequestNotifier.new,
    );

class ScoutRequestNotifier extends AsyncNotifier<ScoutRequest> {
  ScoutRequestNotifier(this.requestId);

  final String requestId;

  ScoutRepository get _repository => ref.read(scoutRepositoryProvider);

  @override
  Future<ScoutRequest> build() =>
      ref.watch(scoutRepositoryProvider).getScoutRequest(requestId);

  /// Accepts and returns the conversation to open.
  Future<String> accept() async {
    final conversationId = await _repository.acceptScoutRequest(requestId);
    _update(
      (r) => r.copyWith(
        status: ScoutRequestStatus.accepted,
        conversationId: conversationId,
      ),
    );
    if (ref.mounted) ref.invalidate(scoutRequestsProvider);
    return conversationId;
  }

  /// Returns the conversation to ask in; the request stays pending.
  Future<String> ask() async {
    final conversationId = await _repository.askAboutScoutRequest(requestId);
    _update((r) => r.copyWith(conversationId: conversationId));
    return conversationId;
  }

  /// Shows the request declined at once; rolls back and rethrows on failure.
  Future<void> decline() => _optimistic(
    (r) => r.copyWith(status: ScoutRequestStatus.declined, isNew: false),
    () => _repository.declineScoutRequest(requestId),
    refreshList: true,
  );

  /// Flags the request for review; a second report is a no-op.
  Future<void> report({String? reason}) async {
    if (state.value?.reportedByMe ?? true) return;
    await _optimistic(
      (r) => r.copyWith(reportedByMe: true),
      () => _repository.reportScoutRequest(requestId, reason: reason),
    );
  }

  void _update(ScoutRequest Function(ScoutRequest) change) {
    final request = state.value;
    if (request != null && ref.mounted) state = AsyncData(change(request));
  }

  Future<void> _optimistic(
    ScoutRequest Function(ScoutRequest) change,
    Future<void> Function() request, {
    bool refreshList = false,
  }) async {
    final previous = state.value;
    if (previous == null) return;
    state = AsyncData(change(previous));
    try {
      await request();
    } catch (_) {
      if (ref.mounted) state = AsyncData(previous);
      rethrow;
    }
    if (refreshList && ref.mounted) ref.invalidate(scoutRequestsProvider);
  }
}
