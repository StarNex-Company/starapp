import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/connections.dart';
import 'package:starapp/features/profile/data/provider/connections_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/connections_person_row.dart';
import 'package:starapp/features/profile/presentation/widgets/connections_search_field.dart';
import 'package:starapp/features/profile/presentation/widgets/connections_segmented.dart';
import 'package:starapp/features/profile/presentation/widgets/connections_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// Followers / Following lists (Figma "Profile — My Followers", "My
/// Following", "Followers", "Following (Chidi)"). [creatorId] null shows the
/// signed-in user's lists; the segmented control switches lists in place and
/// typing in the field searches the current one. More people load as the
/// end of the list scrolls into view.
class ConnectionsPage extends ConsumerStatefulWidget {
  const ConnectionsPage({
    super.key,
    this.creatorId,
    this.showFollowing = false,
  });

  final String? creatorId;

  /// Opens on "Following" instead of "Followers".
  final bool showFollowing;

  @override
  ConsumerState<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends ConsumerState<ConnectionsPage> {
  late ConnectionsTab _tab = widget.showFollowing
      ? ConnectionsTab.following
      : ConnectionsTab.followers;
  final _query = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
  }

  @override
  void didUpdateWidget(ConnectionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showFollowing != widget.showFollowing) {
      _tab = widget.showFollowing
          ? ConnectionsTab.following
          : ConnectionsTab.followers;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  /// Searches once typing pauses.
  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _search);
  }

  void _search() {
    if (!mounted) return;
    ref.read(connectionsProvider(_key(_tab)).notifier).search(_query.text);
  }

  void _select(ConnectionsTab tab) {
    setState(() => _tab = tab);
    // The query carries over to the other list.
    _search();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  ConnectionsKey _key(ConnectionsTab tab) =>
      (creatorId: widget.creatorId, tab: tab);

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(connectionsOwnerProvider(widget.creatorId));
    final list = connectionsProvider(_key(_tab));
    final people = ref.watch(list);
    // Load the other list too, so switching doesn't flash a spinner.
    ref.watch(connectionsProvider(_key(_tab.other)));
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: owner.value?.name ?? '',
        leading: StarIconButton.back(onPressed: _back),
      ),
      body: StarAsyncView(
        value: owner,
        onRetry: () =>
            ref.invalidate(connectionsOwnerProvider(widget.creatorId)),
        builder: (owner) {
          final isFollowers = _tab == ConnectionsTab.followers;
          return NotificationListener<ScrollUpdateNotification>(
            // Fetch the next page as the end comes into view.
            onNotification: (scroll) {
              if (scroll.metrics.extentAfter < 400) {
                ref.read(list.notifier).loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                // The design's 20px top gap is measured from a 5px taller
                // header than StarScreenHeader.
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 25, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 14,
                      children: [
                        ConnectionsSegmented(
                          selected: _tab,
                          followers: owner.followers,
                          following: owner.following,
                          onChanged: _select,
                        ),
                        ConnectionsSearchField(
                          controller: _query,
                          hint: isFollowers
                              ? 'Search followers'
                              : 'Search following',
                          onSearchTap: () => context.push(AppRoutes.search),
                        ),
                        ConnectionsSectionHeader(
                          title: isFollowers ? 'Followers' : 'Following',
                          count: formatGrouped(owner.count(_tab)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(24, 14, 24, bottom),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.topCenter,
                        children: [...previous, ?current],
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_tab),
                        child: StarAsyncView(
                          value: people,
                          onRetry: () => ref.invalidate(list),
                          builder: (people) => _PeopleList(
                            people: people,
                            query: _query.text.trim(),
                            tab: _tab,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PeopleList extends ConsumerWidget {
  const _PeopleList({
    required this.people,
    required this.query,
    required this.tab,
  });

  /// Already matching [query]; the server does the search.
  final List<Connection> people;
  final String query;
  final ConnectionsTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followed = ref.watch(followingProvider);

    if (people.isEmpty) {
      return _EmptyState(
        text: query.isNotEmpty
            ? 'No one matches “$query”.'
            : tab == ConnectionsTab.followers
            ? 'No followers yet.'
            : 'Not following anyone yet.',
      );
    }

    // Rows are 14px apart in the design, on top of their own 10px padding.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        for (final p in people)
          ConnectionsPersonRow(
            key: ValueKey(p.id),
            person: p,
            following: followed.contains(p.id),
            onTap: () => context.pushCreator(p.id),
            onFollowTap: () =>
                ref.read(followingProvider.notifier).toggle(p.id),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          height: connectionsLeading,
          letterSpacing: 0,
          color: AppColors.textSubtle,
        ),
      ),
    );
  }
}
