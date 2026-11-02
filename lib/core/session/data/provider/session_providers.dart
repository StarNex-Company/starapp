import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/token_store.dart';
import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/core/session/data/repositories/api_session_repository.dart';
import 'package:starapp/core/session/data/repositories/mock_session_repository.dart';
import 'package:starapp/core/session/data/repositories/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockSessionRepository.new,
    api: ApiSessionRepository.new,
  ),
);

/// The signed-in user. Edit Profile saves through [CurrentUserNotifier.updateProfile].
final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, CurrentUser>(
      CurrentUserNotifier.new,
    );

class CurrentUserNotifier extends AsyncNotifier<CurrentUser> {
  SessionRepository get _repository => ref.read(sessionRepositoryProvider);

  @override
  Future<CurrentUser> build() =>
      ref.watch(sessionRepositoryProvider).fetchCurrentUser();

  /// Shows [user] at once and replaces it with what the server stored. On
  /// failure the previous user comes back and the error is rethrown for the
  /// screen to show.
  Future<void> updateProfile(CurrentUser user) async {
    final previous = state;
    state = AsyncData(user);
    try {
      state = AsyncData(await _repository.updateProfile(user));
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  /// Ends the session: tells the server, forgets the token and drops every
  /// user-scoped state. The caller then routes to the welcome screen.
  Future<void> signOut() async {
    try {
      await _repository.signOut();
    } finally {
      await ref.read(tokenStoreProvider).clear();
      ref.invalidate(followingProvider);
      ref.invalidateSelf();
    }
  }
}

/// Creators the user follows, shared by every screen with a Follow button so
/// a follow on one screen shows everywhere.
final followingProvider = NotifierProvider<FollowingNotifier, Set<String>>(
  FollowingNotifier.new,
);

class FollowingNotifier extends Notifier<Set<String>> {
  SessionRepository get _repository => ref.read(sessionRepositoryProvider);

  @override
  Set<String> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    try {
      final ids = await _repository.fetchFollowing();
      if (ids.isNotEmpty) state = {...state, ...ids};
    } catch (_) {
      // Follow buttons simply start as "Follow"; the next toggle syncs.
    }
  }

  bool isFollowing(String creatorId) => state.contains(creatorId);

  /// Follows or unfollows at once and returns whether the user now follows
  /// them; reverts if the server rejects it.
  bool toggle(String creatorId) {
    final follow = !state.contains(creatorId);
    _set(creatorId, follow);
    _repository.setFollowing(creatorId, following: follow).catchError((_) {
      _set(creatorId, !follow);
    });
    return follow;
  }

  void _set(String creatorId, bool follow) =>
      state = follow ? {...state, creatorId} : ({...state}..remove(creatorId));
}
