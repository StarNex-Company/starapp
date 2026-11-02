import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/my_entries.dart';
import 'package:starapp/features/challenges/data/provider/challenges_providers.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_list_tile.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Challenges tab page listing the user's live and past challenge entries.
class MyEntriesPage extends ConsumerWidget {
  const MyEntriesPage({super.key});

  /// A live entry opens its challenge; a placed past one, the winners.
  void _open(BuildContext context, MyEntry entry) {
    final id = entry.challenge.id;
    if (_isLive(entry)) {
      context.push('${AppRoutes.challengeDetail}?id=$id');
    } else if (entry.rank != null) {
      context.push('${AppRoutes.challengeWinners}?id=$id');
    } else {
      showStarToast(context, 'Coming soon');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The tab's bottom navigation floats over the page. The design starts the
    // list 25px below the header.
    final bottom = MediaQuery.paddingOf(context).bottom;
    final entries = ref.watch(myEntriesProvider);

    Widget tile(MyEntry entry) => ChallengeListTile(
      icon: _icon(entry),
      title: entry.challenge.title,
      subtitle: _subtitle(entry),
      value: _status(entry),
      onTap: () => _open(context, entry),
    );

    return Scaffold(
      appBar: StarScreenHeader(
        title: 'My entries',
        leading: StarIconButton.back(onPressed: () => context.pop()),
      ),
      body: StarAsyncView(
        value: entries,
        onRetry: () => ref.invalidate(myEntriesProvider),
        builder: (entries) => NotificationListener<ScrollUpdateNotification>(
          // Fetch the next page as the end comes into view.
          onNotification: (scroll) {
            if (scroll.metrics.extentAfter < 400) {
              ref.read(myEntriesProvider.notifier).loadMore();
            }
            return false;
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 25, 24, bottom + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                const ChallengeListSectionTitle('Live'),
                ...entries.where(_isLive).map(tile),
                const ChallengeListSectionTitle('Past'),
                ...entries.where((e) => !_isLive(e)).map(tile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _isLive(MyEntry entry) => entry.challenge.status == ChallengeStatus.live;

String _icon(MyEntry entry) {
  if (_isLive(entry)) return ChallengeListIcons.ofArena(entry.challenge.arena);
  return entry.rank != null
      ? ChallengeListIcons.trophy
      : ChallengeListIcons.star;
}

/// "Live", "Top 10" or "Done".
String _status(MyEntry entry) {
  if (_isLive(entry)) return 'Live';
  final rank = entry.rank;
  return rank != null && rank <= 10 ? 'Top 10' : 'Done';
}

/// "Late-night vocal run · #14 · 331 Stars" while live; afterwards
/// "Sep 2026 · finished #7 of 1,248 · $600" or "Mar 2026 · completed · +50
/// Stars".
String _subtitle(MyEntry entry) {
  final rank = entry.rank;
  if (_isLive(entry)) {
    return joinDetails([
      entry.title,
      if (rank != null) '#${formatGrouped(rank)}',
      '${formatGrouped(entry.stars)} Stars',
    ]);
  }
  final challenge = entry.challenge;
  return joinDetails([
    formatMonth(challenge.endsAt),
    rank == null
        ? 'completed'
        : 'finished #${formatGrouped(rank)} of '
              '${formatGrouped(challenge.entryCount)}',
    entry.prize?.format(),
    if (entry.bonusStars > 0) '+${formatGrouped(entry.bonusStars)} Stars',
  ]);
}
