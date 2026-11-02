import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/create/presentation/widgets/create_sheet.dart';
import 'package:starapp/features/messages/data/provider/messages_providers.dart';
import 'package:starapp/shared/widgets/star_bottom_nav.dart';

const _icons = 'assets/vectors/home';

/// Signed-in app frame: the current tab's navigator with the floating bottom
/// navigation. Hosted by the router's `StatefulShellRoute`, so each built tab
/// keeps its own stack and the nav stays visible on pages pushed within it.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static List<StarBottomNavItem> _items({
    required String? avatarUrl,
    required bool unreadMessages,
  }) => [
    const StarBottomNavItem.icon(
      label: 'Home',
      icon: '$_icons/nav_ic_home_outline.svg',
      selectedIcon: '$_icons/nav_ic_home.svg',
    ),
    const StarBottomNavItem.icon(
      label: 'Discover',
      icon: '$_icons/nav_ic_discover.svg',
      selectedIcon: '$_icons/nav_ic_discover_filled.svg',
    ),
    const StarBottomNavItem.icon(
      label: 'Challenges',
      icon: '$_icons/nav_ic_challenges.svg',
    ),
    const StarBottomNavItem.icon(
      label: 'Videos',
      icon: '$_icons/nav_ic_videos.svg',
    ),
    StarBottomNavItem.icon(
      label: 'Messages',
      icon: '$_icons/nav_ic_messages.svg',
      showDot: unreadMessages,
    ),
    StarBottomNavItem.avatar(label: 'Profile', avatarUrl: avatarUrl),
  ];

  /// Nav item → shell branch, in the router's branch order: Home,
  /// Discover, Challenges, Profile, Messages. Videos has no branch.
  static const _branchOfItem = {0: 0, 1: 1, 2: 2, 5: 3, 4: 4};
  static const _videosItem = 3;

  int get _selectedItem => _branchOfItem.entries
      .firstWhere((e) => e.value == navigationShell.currentIndex)
      .key;

  void _onTab(BuildContext context, int item) {
    // The video feed is full screen, so it opens over the shell.
    if (item == _videosItem) {
      context.push(AppRoutes.videos);
      return;
    }
    final branch = _branchOfItem[item]!;
    // Re-tapping the current tab returns it to its first page.
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = ref.watch(
      currentUserProvider.select((user) => user.value?.avatarUrl),
    );
    final unread = ref.watch(
      inboxSummaryProvider.select((s) => (s.value?.totalUnread ?? 0) > 0),
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: navigationShell,
      bottomNavigationBar: StarBottomNav(
        items: _items(avatarUrl: avatar, unreadMessages: unread),
        selectedIndex: _selectedItem,
        onTap: (item) => _onTab(context, item),
        createIcon: '$_icons/nav_ic_create.svg',
        onCreate: () => showCreateSheet(context),
      ),
    );
  }
}
