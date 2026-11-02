import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/data/provider/challenges_providers.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_challenge_picker.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_filter_chips.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_filters_sheet.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_icons.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_live_status.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_my_rank_card.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_podium.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_rankings.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_segmented_control.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _regions = ['All regions', 'Nigeria', 'Ghana', 'South Africa', 'UK'];
const _scopes = ['Global', 'All talents', 'All ages', '2026'];

enum LeaderboardView { thisChallenge, allTime }

/// Challenges tab page: the live board of one challenge and the all-time
/// Hall of Fame, switched with a segmented control. Each view keeps its own
/// scroll position. The live board refreshes every [refreshInterval], on
/// pull and from its "updated" label.
class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({
    super.key,
    this.initialView = LeaderboardView.thisChallenge,
    this.challengeId = defaultChallengeId,
    this.refreshInterval = const Duration(seconds: 30),
    this.podiumDuration = const Duration(milliseconds: 1100),
  });

  final LeaderboardView initialView;

  /// The challenge whose board opens first.
  final String challengeId;

  /// How often the live board pulls in the latest standings.
  final Duration refreshInterval;

  /// Length of the podium's entrance animation.
  final Duration podiumDuration;

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  final _liveScroll = ScrollController();
  final _allTimeScroll = ScrollController();

  /// The clock the "updated" label reads; ticks once a second.
  final _now = ValueNotifier(DateTime.now());
  late final Timer _clock;
  late final Timer _refresher;

  late LeaderboardView _view = widget.initialView;
  late String _challengeId = widget.challengeId;
  String _region = _regions.first;
  String _scope = _scopes.first;
  String _category = challengeFilterCategories.first;

  /// The boards last shown, kept on screen while a new filter loads.
  Leaderboard? _shownLive;
  Leaderboard? _shownAllTime;

  /// Bumped each time All-Time opens so the podium rises again.
  int _podiumRun = 0;

  LeaderboardQuery get _liveQuery => (
    challengeId: _challengeId,
    view: BoardView.live,
    region: _region == _regions.first ? null : _region,
    arena: null,
  );

  // The Hall of Fame isn't tied to the picked challenge.
  LeaderboardQuery get _allTimeQuery => (
    challengeId: widget.challengeId,
    view: BoardView.allTime,
    region: null,
    arena: challengeFilterArena(_category),
  );

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _now.value = DateTime.now(),
    );
    _refresher = Timer.periodic(
      widget.refreshInterval,
      (_) => _refreshLive(quiet: true),
    );
  }

  @override
  void dispose() {
    _clock.cancel();
    _refresher.cancel();
    _now.dispose();
    _liveScroll.dispose();
    _allTimeScroll.dispose();
    super.dispose();
  }

  /// Whether the picked challenge is still taking Stars; boards of finished
  /// ones don't change.
  bool get _isLive {
    final challenges = ref.read(boardChallengesProvider).value;
    final picked = challenges?.where((c) => c.id == _challengeId).firstOrNull;
    return picked == null || picked.status == ChallengeStatus.live;
  }

  Future<void> _refreshLive({bool quiet = false}) async {
    if (quiet && (!_isLive || _view != LeaderboardView.thisChallenge)) return;
    await _refresh(_liveQuery, quiet: quiet);
  }

  Future<void> _refresh(LeaderboardQuery query, {bool quiet = false}) async {
    try {
      await ref.read(leaderboardProvider(query).notifier).refresh();
    } catch (e) {
      if (!quiet && mounted) showStarToast(context, describeError(e));
    }
  }

  void _switchView(int index) {
    final view = LeaderboardView.values[index];
    if (view == _view) return;
    setState(() {
      _view = view;
      if (view == LeaderboardView.allTime) _podiumRun++;
    });
  }

  Future<void> _openFilters() async {
    final category = await showChallengeFiltersSheet(
      context,
      selected: _category,
    );
    if (category != null && mounted) setState(() => _category = category);
  }

  void _comingSoon() {
    showStarToast(context, 'Coming soon');
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  /// [value], or the board shown before while a new filter's board loads.
  AsyncValue<Leaderboard> _steady(
    AsyncValue<Leaderboard> value,
    Leaderboard? shown,
  ) => value.isLoading && !value.hasValue && shown != null
      ? AsyncData(shown)
      : value;

  @override
  Widget build(BuildContext context) {
    final allTime = _view == LeaderboardView.allTime;
    final liveQuery = _liveQuery;
    final allTimeQuery = _allTimeQuery;
    final live = ref.watch(leaderboardProvider(liveQuery));
    final hallOfFame = ref.watch(leaderboardProvider(allTimeQuery));
    if (live.hasValue) _shownLive = live.value;
    if (hallOfFame.hasValue) _shownAllTime = hallOfFame.value;

    return Scaffold(
      appBar: StarScreenHeader(
        title: 'Leaderboard',
        leading: StarIconButton.back(onPressed: _back),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: allTime
              ? StarIconButton(
                  key: const ValueKey('filters'),
                  icon: BoardIcons.sliders,
                  tooltip: 'Filters',
                  onPressed: _openFilters,
                )
              : StarIconButton(
                  key: const ValueKey('share'),
                  icon: BoardIcons.share,
                  tooltip: 'Share',
                  onPressed: _comingSoon,
                ),
        ),
      ),
      body: IndexedStack(
        index: _view.index,
        children: [
          StarAsyncView(
            value: _steady(live, _shownLive),
            onRetry: () => ref.invalidate(leaderboardProvider(liveQuery)),
            builder: (board) => _ViewScroll(
              controller: _liveScroll,
              onRefresh: _refreshLive,
              onEnd: () =>
                  ref.read(leaderboardProvider(liveQuery).notifier).loadMore(),
              children: _liveBoard(board),
            ),
          ),
          StarAsyncView(
            value: _steady(hallOfFame, _shownAllTime),
            onRetry: () => ref.invalidate(leaderboardProvider(allTimeQuery)),
            builder: (board) => _ViewScroll(
              controller: _allTimeScroll,
              onRefresh: () => _refresh(allTimeQuery),
              onEnd: () => ref
                  .read(leaderboardProvider(allTimeQuery).notifier)
                  .loadMore(),
              children: _allTimeBoard(board),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segments() {
    return BoardSegmentedControl(
      segments: const [
        BoardSegment(label: 'This Challenge', icon: BoardIcons.trophy),
        BoardSegment(label: 'All-Time', icon: BoardIcons.globe),
      ],
      selected: _view.index,
      onChanged: _switchView,
    );
  }

  Widget? _picker() {
    final challenges = ref.watch(boardChallengesProvider).value ?? const [];
    final selected = challenges.indexWhere((c) => c.id == _challengeId);
    if (selected < 0) return null;
    return BoardChallengePicker(
      challenges: challenges,
      selected: selected,
      onSelected: (index) =>
          setState(() => _challengeId = challenges[index].id),
    );
  }

  List<Widget> _liveBoard(Leaderboard board) {
    final me = board.me;
    return [
      _segments(),
      ?_picker(),
      BoardFilterChips(
        labels: _regions,
        selected: _region,
        onSelected: (region) => setState(() => _region = region),
      ),
      if (_isLive)
        ValueListenableBuilder(
          valueListenable: _now,
          builder: (context, now, _) => BoardLiveStatus(
            updatedLabel: _ageLabel(now.difference(board.updatedAt).inSeconds),
            onRefresh: _refreshLive,
          ),
        ),
      if (me != null)
        BoardLiveRankCard(
          photo: me.entry.creator.avatarUrl,
          title: joinDetails(['You', me.entry.entryTitle]),
          rank: me.entry.rank,
          stars: me.entry.stars,
          note: _liveNote(me),
        ),
      BoardLiveRankings(
        entries: board.entries,
        onTap: (e) => context.pushCreator(e.creator.id),
      ),
    ];
  }

  List<Widget> _allTimeBoard(Leaderboard board) {
    final me = board.me;
    final season = board.season;
    return [
      _segments(),
      BoardFilterChips(
        labels: _scopes,
        selected: _scope,
        onSelected: (scope) => setState(() => _scope = scope),
      ),
      BoardPodium(
        key: ValueKey(_podiumRun),
        title: season == null ? 'HALL OF FAME' : 'HALL OF FAME · $season',
        winners: board.entries.take(3).toList(),
        duration: widget.podiumDuration,
        onTap: (e) => context.pushCreator(e.creator.id),
      ),
      if (me != null)
        BoardAllTimeRankCard(
          rank: '#${formatGrouped(me.entry.rank)}',
          photo: me.entry.creator.avatarUrl,
          note: _allTimeNote(me),
          stars: formatGrouped(me.entry.stars),
        ),
      BoardHallRankings(
        entries: board.entries.skip(3).toList(),
        onTap: (e) => context.pushCreator(e.creator.id),
      ),
    ];
  }
}

String _ageLabel(int seconds) {
  if (seconds < 5) return 'Just now';
  if (seconds < 60) return '${seconds}s ago';
  if (seconds < 3600) return '${seconds ~/ 60}m ago';
  return '${seconds ~/ 3600}h ago';
}

/// "Up 2 places · 58 to Top 10", or "93 Stars to Top 10" when you haven't
/// moved.
String _liveNote(MyLeaderboardRank me) {
  final moved = me.entry.movement;
  final gap = me.starsToTopTen;
  final places = moved.abs() == 1 ? 'place' : 'places';
  return joinDetails([
    if (moved > 0) 'Up $moved $places',
    if (moved < 0) 'Down ${-moved} $places',
    if (gap != null)
      moved == 0
          ? '${formatGrouped(gap)} Stars to Top 10'
          : '${formatGrouped(gap)} to Top 10',
  ]);
}

/// "Top 4% in Nigeria · Rising Nova".
String _allTimeNote(MyLeaderboardRank me) {
  final percent = me.topPercent;
  final region = me.region;
  return joinDetails([
    if (percent != null)
      region == null ? 'Top $percent%' : 'Top $percent% in $region',
    me.entry.creator.tier?.label,
  ]);
}

/// One view's scrolling column, clear of the header and the floating nav.
/// Pull to refresh; [onEnd] fires as the end comes into view.
class _ViewScroll extends StatelessWidget {
  const _ViewScroll({
    required this.controller,
    required this.onRefresh,
    required this.onEnd,
    required this.children,
  });

  final ScrollController controller;
  final Future<void> Function() onRefresh;
  final VoidCallback onEnd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 40;
    return RefreshIndicator(
      color: AppColors.brandBlue,
      onRefresh: onRefresh,
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.extentAfter < 400) onEnd();
          return false;
        },
        child: SingleChildScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: children,
          ),
        ),
      ),
    );
  }
}
