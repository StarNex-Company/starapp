import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/challenges_hub.dart';
import 'package:starapp/features/challenges/data/provider/challenges_providers.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_filters_sheet.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/features/challenges/presentation/widgets/hub_challenge_card.dart';
import 'package:starapp/features/challenges/presentation/widgets/hub_featured_card.dart';
import 'package:starapp/features/challenges/presentation/widgets/hub_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

const _body = Color(0xFF444652); // text/body/444652
const _ink = Color(0xFF191C1E); // text/body/191c1e
const _brand = Color(0xFF042987);
const _emptyBg = Color(0xFFF2F4F6); // surface/muted/f2f4f6

const _intro =
    'Compete in high-stakes global showcases, claim verified cash prizes, '
    'and secure executive scout spotlights.';

List<StarTab> _tabs(ChallengesHub hub) => [
  StarTab(label: 'Active Now', count: hub.activeCount),
  StarTab(label: 'Upcoming', count: hub.upcomingCount),
  const StarTab(label: 'Past Arenas', icon: HubIcons.history),
  StarTab(
    label: 'My Entries',
    icon: HubIcons.myEntries,
    count: hub.myEntryCount,
    countTone: StarTabCountTone.highlight,
  ),
  const StarTab(label: 'Hall of Fame', icon: HubIcons.hallOfFame),
];

const _allArenas = 'All Arenas';
final _arenas = [
  _allArenas,
  for (final arena in [
    ChallengeArena.music,
    ChallengeArena.dance,
    ChallengeArena.acting,
    ChallengeArena.visualArts,
  ])
    arena.label,
];

/// Challenges tab root: intro, shortcuts to the other challenge screens,
/// arena filters, the featured arena with its live podium and the other
/// active arenas.
class ChallengesHubPage extends ConsumerStatefulWidget {
  const ChallengesHubPage({super.key});

  @override
  ConsumerState<ChallengesHubPage> createState() => _ChallengesHubPageState();
}

class _ChallengesHubPageState extends ConsumerState<ChallengesHubPage> {
  final _scroll = ScrollController();

  /// How long ago the featured standings changed; ticks while open.
  final _refreshed = ValueNotifier(_ageLabel(0));
  late final Timer _clock;

  /// The selected arena pill, or a filters-sheet category without one.
  String _arena = _allArenas;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      challengesHubProvider,
      (_, _) => _tickAge(),
      fireImmediately: true,
    );
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tickAge());
  }

  void _tickAge() {
    final updatedAt = ref
        .read(challengesHubProvider)
        .value
        ?.featured
        ?.standingsUpdatedAt;
    if (updatedAt == null) return;
    _refreshed.value = _ageLabel(
      DateTime.now().difference(updatedAt).inSeconds,
    );
  }

  @override
  void dispose() {
    _clock.cancel();
    _refreshed.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _openFilters() async {
    final current = ChallengeArena.values
        .where((a) => a.label == _arena)
        .firstOrNull;
    final picked = await showChallengeFiltersSheet(
      context,
      selected: challengeFilterLabel(current),
    );
    if (picked == null || !mounted) return;
    setState(() => _arena = challengeFilterArena(picked)?.label ?? _allArenas);
  }

  void _openTab(int index) {
    switch (index) {
      case 0:
        if (_scroll.hasClients) {
          _scroll.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      case 1:
        context.push(AppRoutes.challengesUpcoming);
      case 2:
        context.push(AppRoutes.challengeWinners);
      case 3:
        context.push(AppRoutes.challengesMyEntries);
      case 4:
        context.push('${AppRoutes.challengesLeaderboard}?view=all-time');
    }
  }

  void _openArena(Challenge challenge) =>
      context.push('${AppRoutes.challengeDetail}?id=${challenge.id}');

  void _openStandings(Challenge challenge) => context.push(
    '${AppRoutes.challengesLeaderboard}?challenge=${challenge.id}',
  );

  bool _shows(Challenge challenge) =>
      _arena == _allArenas || _arena == challenge.arena.label;

  List<Widget> _arenaCards(ChallengesHub hub) {
    final featured = hub.featured;
    return [
      if (featured != null && _shows(featured.challenge))
        _featuredCard(featured),
      for (final arena in hub.arenas)
        if (_shows(arena.challenge)) _arenaCard(arena),
    ];
  }

  Widget _featuredCard(FeaturedArena featured) {
    final challenge = featured.challenge;
    final prize = challenge.prize;
    return HubFeaturedCard(
      photo: challenge.coverUrl,
      category: challenge.category,
      title: challenge.title,
      prize: prize == null
          ? ''
          : [prizeTitle(prize), ...prize.perks].join(' + '),
      endsIn: formatTimeLeft(challenge.endsAt),
      entries: challenge.entryCount,
      capacity: challenge.capacity,
      podium: featured.podium,
      refreshedLabel: _refreshed,
      onOpen: () => _openArena(challenge),
      onStandings: () => _openStandings(challenge),
    );
  }

  Widget _arenaCard(HubArena arena) {
    final challenge = arena.challenge;
    final pool = challenge.prize;
    return HubChallengeCard(
      tag: challenge.category,
      timeLeft: formatDaysLeft(challenge.endsAt),
      poolLabel: pool?.kind.label ?? '',
      pool: pool == null
          ? ''
          : '${pool.amount.format()} ${pool.amount.currency.code}',
      title: challenge.title,
      preview: switch (arena.preview) {
        ArenaLeadersPreview(:final entries) => HubEntriesPreview(
          submitted: challenge.entryCount,
          entries: entries,
          onWatch: () => _openArena(challenge),
        ),
        ArenaBannerPreview(:final imageUrl, :final theme) => HubBannerPreview(
          image: imageUrl,
          competing: challenge.entryCount,
          theme: theme,
        ),
      },
      onParticipate: () => _openArena(challenge),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The tab's bottom navigation floats over the page. The design starts the
    // intro 21px below the header (20px plus its 1px hairline gap).
    final bottom = MediaQuery.paddingOf(context).bottom;
    final hub = ref.watch(challengesHubProvider);

    return Scaffold(
      appBar: StarScreenHeader(
        title: 'Challenges',
        leading: StarIconButton.back(onPressed: _back),
        trailing: StarIconButton(
          icon: HubIcons.filters,
          iconSize: 20,
          tooltip: 'Filters',
          onPressed: _openFilters,
        ),
      ),
      body: StarAsyncView(
        value: hub,
        onRetry: () => ref.invalidate(challengesHubProvider),
        builder: (hub) => _hubBody(hub, bottom),
      ),
    );
  }

  Widget _hubBody(ChallengesHub hub, double bottom) {
    final cards = _arenaCards(hub);
    return RefreshIndicator(
      color: _brand,
      onRefresh: () => ref.refresh(challengesHubProvider.future),
      child: SingleChildScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24, 21, 24, bottom + 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 13,
          children: [
            Text(
              _intro,
              style: hubText(12, FontWeight.w400, _body, lineHeight: 18),
            ),
            StarTabBar(
              tabs: _tabs(hub),
              selected: 0,
              expand: false,
              onSelected: _openTab,
            ),
            StarChoiceChips<String>(
              chips: [
                for (final arena in _arenas)
                  StarChip(value: arena, label: arena),
              ],
              selected: _arena,
              onSelected: (arena) => setState(() => _arena = arena),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              child: KeyedSubtree(
                key: ValueKey(_arena),
                child: cards.isEmpty
                    ? _NoArenas(
                        arena: _arena,
                        onUpcoming: () =>
                            context.push(AppRoutes.challengesUpcoming),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 13,
                        children: cards,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _ageLabel(int seconds) {
  if (seconds < 5) return 'just now';
  if (seconds < 60) return '${seconds}s ago';
  return '${seconds ~/ 60}m ago';
}

/// Shown when the selected arena has nothing live.
class _NoArenas extends StatelessWidget {
  const _NoArenas({required this.arena, required this.onUpcoming});

  final String arena;
  final VoidCallback onUpcoming;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: _emptyBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: 6,
        children: [
          Text(
            'No live arenas in $arena',
            textAlign: TextAlign.center,
            style: hubText(16, FontWeight.w700, _ink, lineHeight: 22.5),
          ),
          Text(
            'New arenas open every week. See what opens next.',
            textAlign: TextAlign.center,
            style: hubText(12, FontWeight.w400, _body, lineHeight: 18),
          ),
          const SizedBox(height: 8),
          Material(
            color: _brand,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onUpcoming,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  'See upcoming arenas',
                  style: hubText(
                    12,
                    FontWeight.w700,
                    Colors.white,
                    lineHeight: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
