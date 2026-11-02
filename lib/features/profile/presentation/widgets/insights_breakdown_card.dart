import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// Series colour of each Star source (fixed per source, never by rank).
Color starSourceColor(StarSourceKind kind) => switch (kind) {
  StarSourceKind.views => AppColors.brandBlue,
  StarSourceKind.comments => InsightsColors.violet,
  StarSourceKind.watchTime => InsightsColors.sky,
  StarSourceKind.shares => AppColors.gold,
  StarSourceKind.challenges => AppColors.success,
};

/// "Where your Stars come from": a donut with the total in the middle and a
/// legend with each source's share.
class InsightsBreakdownCard extends StatelessWidget {
  const InsightsBreakdownCard({
    super.key,
    required this.total,
    required this.sources,
  });

  final int total;
  final List<StarSource> sources;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: StarDividedCard.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          const Text(
            'Where your Stars come from',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: insightsLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
          Row(
            spacing: 16,
            children: [
              _Donut(total: total, sources: sources),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 9,
                  children: [for (final s in sources) _LegendRow(source: s)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Donut extends StatelessWidget {
  const _Donut({required this.total, required this.sources});

  final int total;
  final List<StarSource> sources;

  @override
  Widget build(BuildContext context) {
    final summary = [
      for (final s in sources) '${s.kind.label} ${s.percent}%',
    ].join(', ');

    return Semantics(
      label: '${formatGrouped(total)} Stars: $summary',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 120,
        child: TweenAnimationBuilder<double>(
          key: ValueKey(
            Object.hashAll([total, for (final s in sources) s.percent]),
          ),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => CustomPaint(
            painter: _DonutPainter(sources: sources, progress: t),
            child: child,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatGrouped(total),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 18,
                        height: insightsLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const Text(
                      'Stars',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        height: insightsLeading,
                        letterSpacing: 0,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ring segments clockwise from 12 o'clock with a 2px white gap between
/// them; [progress] sweeps them in.
class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.sources, required this.progress});

  final List<StarSource> sources;
  final double progress;

  static const _thickness = 20.4;
  static const _gap = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final sum = sources.fold<int>(0, (s, e) => s + e.percent);
    if (sum == 0) return;
    final radius = size.shortestSide / 2 - _thickness / 2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final gapAngle = _gap / radius;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _thickness;

    var start = -math.pi / 2;
    final total = 2 * math.pi * progress;
    var drawn = 0.0;
    for (final s in sources) {
      final sweep = 2 * math.pi * s.percent / sum;
      final visible = math.min(sweep, total - drawn);
      if (visible <= gapAngle) break;
      paint.color = starSourceColor(s.kind);
      canvas.drawArc(
        rect,
        start + gapAngle / 2,
        visible - gapAngle,
        false,
        paint,
      );
      start += sweep;
      drawn += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.sources != sources;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.source});

  final StarSource source;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 7,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: starSourceColor(source.kind),
            shape: BoxShape.circle,
          ),
          child: const SizedBox.square(dimension: 9),
        ),
        Expanded(
          child: Text(
            source.kind.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: insightsLeading,
              letterSpacing: 0,
              color: AppColors.textBody,
            ),
          ),
        ),
        Text(
          '${source.percent}%',
          maxLines: 1,
          style: const TextStyle(
            fontSize: 12,
            height: insightsLeading,
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
