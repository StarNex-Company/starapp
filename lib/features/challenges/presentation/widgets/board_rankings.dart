import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_rank_row.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

const _cardPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 6);
const _reorder = Duration(milliseconds: 700);

/// Height of one ranking row: 42px avatar or the two text lines, plus 20px
/// of vertical padding.
double _rowExtent(BuildContext context) {
  final scaler = MediaQuery.textScalerOf(context);
  final text = (scaler.scale(14) + scaler.scale(12)) * 1.21 + 3;
  return 20 + math.max(42.0, text.ceilToDouble());
}

/// Live standings of one challenge. When [entries] arrive in a new order the
/// rows slide to their new places, risers tint green and star totals count
/// up to their new values.
class BoardLiveRankings extends StatelessWidget {
  const BoardLiveRankings({
    super.key,
    required this.entries,
    required this.onTap,
  });

  final List<LeaderboardEntry> entries;
  final ValueChanged<LeaderboardEntry> onTap;

  @override
  Widget build(BuildContext context) {
    final extent = _rowExtent(context);
    final placed = [
      for (var i = 0; i < entries.length; i++) (place: i, entry: entries[i]),
    ];
    // Risers paint last so they slide over the rows they pass.
    final order = [
      ...placed.where((row) => row.entry.movement <= 0),
      ...placed.where((row) => row.entry.movement > 0),
    ];

    return DecoratedBox(
      decoration: StarDividedCard.decoration,
      child: Padding(
        padding: _cardPadding,
        child: SizedBox(
          height: extent * entries.length,
          child: Stack(
            children: [
              for (final (:place, :entry) in order)
                AnimatedPositioned(
                  key: ValueKey(entry.creator.id),
                  duration: _reorder,
                  curve: Curves.easeInOutCubic,
                  top: place * extent,
                  left: 0,
                  right: 0,
                  height: extent,
                  child: _LiveRow(entry: entry, onTap: () => onTap(entry)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveRow extends StatelessWidget {
  const _LiveRow({required this.entry, required this.onTap});

  final LeaderboardEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rank = entry.rank;
    return BoardRankRow(
      highlighted: entry.movement > 0,
      onTap: onTap,
      badge: AnimatedSwitcher(
        duration: _reorder,
        child: BoardRankBadge(key: ValueKey(rank), rank: rank),
      ),
      avatar: BoardAvatar(
        photo: entry.creator.avatarUrl,
        ring: boardMedalColor(rank),
      ),
      name: entry.creator.name,
      subtitle: joinDetails([entry.location, entry.entryTitle]),
      score: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 2,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: entry.stars.toDouble()),
            duration: _reorder,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) =>
                BoardStars(label: formatGrouped(value.round())),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: BoardDelta(
              key: ValueKey(entry.movement),
              movement: entry.movement,
            ),
          ),
        ],
      ),
    );
  }
}

/// All-time standings below the podium, with hairlines between rows.
class BoardHallRankings extends StatelessWidget {
  const BoardHallRankings({
    super.key,
    required this.entries,
    required this.onTap,
  });

  /// The places after the podium.
  final List<LeaderboardEntry> entries;
  final ValueChanged<LeaderboardEntry> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: StarDividedCard.decoration,
      child: Padding(
        padding: _cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0)
                const ColoredBox(
                  color: AppColors.borderField,
                  child: SizedBox(height: 1),
                ),
              _HallRow(entry: entries[i], onTap: () => onTap(entries[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _HallRow extends StatelessWidget {
  const _HallRow({required this.entry, required this.onTap});

  final LeaderboardEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rank = entry.rank;
    final tier = entry.creator.tier;
    return BoardRankRow(
      padding: const EdgeInsets.symmetric(vertical: 10),
      onTap: onTap,
      badge: BoardRankBadge(rank: rank),
      avatar: BoardAvatar(
        photo: entry.creator.avatarUrl,
        ring: tier?.color ?? boardMedalColor(rank),
      ),
      name: entry.creator.name,
      subtitle: joinDetails([entry.location, entry.talent]),
      score: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 4,
        children: [
          BoardStars(label: formatCompact(entry.stars)),
          if (tier != null) BoardTierPill(tier: tier),
        ],
      ),
    );
  }
}
