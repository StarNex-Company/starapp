import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';

/// Tabs that can show a creator's profile inside their own stack, so the
/// bottom nav stays put.
const _tabRoots = {'home', 'discover', 'challenges', 'profile'};

extension CreatorNavigation on BuildContext {
  /// Opens a creator's profile within the current tab, or full screen when
  /// the current page isn't in a tab (videos, stories, search, or a
  /// full-screen page such as the passport). The user's own id opens the
  /// Profile tab instead.
  void pushCreator(String creatorId) {
    final me = ProviderScope.containerOf(
      this,
      listen: false,
    ).read(currentUserProvider).value;
    if (creatorId == me?.id) {
      go(AppRoutes.profile);
    } else {
      push('${_base()}/creator/$creatorId');
    }
  }

  /// A creator's followers or following list, in the same stack as above.
  void pushCreatorConnections(
    String creatorId, {
    required bool following,
  }) => push(
    '${_base()}/creator/$creatorId/${following ? 'following' : 'followers'}',
  );

  /// The tab root to nest under, or '' for the full-screen routes. Pages on
  /// the root navigator can't push into a tab, so they always get ''.
  String _base() {
    if (isOnRootNavigator) return '';
    final segments = GoRouterState.of(this).uri.pathSegments;
    final root = segments.isEmpty ? '' : segments.first;
    return _tabRoots.contains(root) ? '/$root' : '';
  }
}
