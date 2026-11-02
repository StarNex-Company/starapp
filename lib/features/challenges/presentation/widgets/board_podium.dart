import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_icons.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_rank_row.dart';

const _height = 330.0;
const _blockWidth = 98.0;
const _sideInset = 13.0;
const _ringGap = Color(0xFF111827); // surface/dark/111827
const _rise = 50.0;

/// Block height, top tint and entrance timing (as fractions of the whole
/// animation) for places 1–3.
const _places = {
  1: (
    height: 132.0,
    tint: 0.22,
    block: Interval(0, 0.55),
    winner: Interval(0.35, 0.8),
  ),
  2: (
    height: 92.0,
    tint: 0.14,
    block: Interval(0.15, 0.7),
    winner: Interval(0.5, 0.9),
  ),
  3: (
    height: 72.0,
    tint: 0.14,
    block: Interval(0.3, 0.85),
    winner: Interval(0.6, 1),
  ),
};

/// Dark "Hall of Fame" card with the top three on 2-1-3 blocks. On first
/// build the blocks rise from the floor and the winners fade up onto them;
/// give it a new key to replay.
class BoardPodium extends StatefulWidget {
  const BoardPodium({
    super.key,
    required this.title,
    required this.winners,
    required this.onTap,
    this.duration = const Duration(milliseconds: 1100),
  });

  /// e.g. "HALL OF FAME · 2026".
  final String title;

  /// First, second and third place, in that order.
  final List<LeaderboardEntry> winners;
  final ValueChanged<LeaderboardEntry> onTap;
  final Duration duration;

  @override
  State<BoardPodium> createState() => _BoardPodiumState();
}

class _BoardPodiumState extends State<BoardPodium>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: _height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.inkDeep, _ringGap, Color(0xFF1A2233)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gap =
                (constraints.maxWidth - 2 * _sideInset - 3 * _blockWidth) / 2;
            double left(int column) =>
                _sideInset + column * (_blockWidth + gap);
            // Columns left to right: 2nd, 1st, 3rd.
            final slots = [
              (place: 2, column: 0),
              (place: 1, column: 1),
              (place: 3, column: 2),
            ];

            return AnimatedBuilder(
              animation: _entrance,
              builder: (context, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Center(child: _Glow()),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1.21,
                        letterSpacing: 1.54,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  for (final (:place, :column) in slots) ...[
                    _block(place, left(column)),
                    _winner(place, left(column), gap),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _block(int place, double left) {
    final spec = _places[place]!;
    final t = Curves.easeOutCubic.transform(
      spec.block.transform(_entrance.value),
    );
    return Positioned(
      left: left,
      width: _blockWidth,
      bottom: 0,
      height: spec.height * t,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: spec.tint),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
          ),
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: spec.height,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  '$place',
                  style: const TextStyle(
                    height: 1.21,
                    letterSpacing: 0,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xD9FFFFFF), // white @ 85%
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _winner(int place, double left, double gap) {
    final spec = _places[place]!;
    final entry = widget.winners[place - 1];
    final t = Curves.easeOutCubic.transform(
      spec.winner.transform(_entrance.value),
    );
    final first = place == 1;
    // Names may run a little wider than their block.
    final overhang = gap / 2;

    return Positioned(
      left: left - overhang,
      width: _blockWidth + 2 * overhang,
      bottom: spec.height + 8,
      child: Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, _rise * (1 - t)),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: t < 1 ? null : () => widget.onTap(entry),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                if (first)
                  SvgPicture.asset(BoardIcons.crown, width: 26, height: 26),
                BoardAvatar(
                  photo: entry.creator.avatarUrl,
                  size: first ? 72 : 62,
                  ring: boardMedalColor(place),
                  ringWidth: 3,
                  gapWidth: first ? 3 : 2,
                  gapColor: _ringGap,
                ),
                Text(
                  entry.creator.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.21,
                    letterSpacing: 0,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                BoardStars(
                  label: formatCompact(entry.stars),
                  color: AppColors.gold,
                  small: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 300,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0xE6032886), Color(0x00032886)], // brand @ 90% → 0%
          ),
        ),
      ),
    );
  }
}
