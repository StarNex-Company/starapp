import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// "Stars earned" card: one bar per bucket of the period, the current one in
/// gold. Bars grow into place and animate between periods.
class InsightsChartCard extends StatelessWidget {
  const InsightsChartCard({
    super.key,
    required this.caption,
    required this.bars,
    required this.barPeriod,
  });

  /// "Last 6 months".
  final String caption;
  final List<InsightsBar> bars;
  final InsightsBarPeriod barPeriod;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: StarDividedCard.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            spacing: 8,
            children: [
              const Expanded(
                child: Text(
                  'Stars earned',
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
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: insightsLeading,
                    letterSpacing: 0,
                    color: AppColors.textSubtle,
                  ),
                ),
              ),
            ],
          ),
          InsightsBarChart(bars: bars, barPeriod: barPeriod),
        ],
      ),
    );
  }
}

/// Vertical bars on a 4-line grid with the value above each bar and the
/// bucket label below; the last bar is the current period.
class InsightsBarChart extends StatelessWidget {
  const InsightsBarChart({
    super.key,
    required this.bars,
    required this.barPeriod,
  });

  final List<InsightsBar> bars;

  /// Labels the bars: "Sat", "Sep 8" or "May".
  final InsightsBarPeriod barPeriod;

  static const _height = 172.0;
  static const _baseline = 150.0;
  static const _labelTop = 156.0;

  /// The tallest bar leaves room for its value above it.
  static const _maxBar = 126.0;
  static const _gridSpacing = 50.0;

  @override
  Widget build(BuildContext context) {
    final peak = bars.fold<int>(0, (m, b) => math.max(m, b.value));
    final format = switch (barPeriod) {
      InsightsBarPeriod.day => DateFormat('EEE'),
      InsightsBarPeriod.week => DateFormat('MMM d'),
      InsightsBarPeriod.month => DateFormat('MMM'),
    };
    final labels = [for (final bar in bars) format.format(bar.periodStart)];

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slot = constraints.maxWidth / math.max(bars.length, 1);
          final barWidth = math.min(28.0, slot * 0.62);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var y = 0.0; y <= _baseline; y += _gridSpacing)
                Positioned(
                  left: 0,
                  right: 0,
                  top: y,
                  height: 1,
                  child: const ColoredBox(color: AppColors.borderField),
                ),
              for (var i = 0; i < bars.length; i++) ...[
                Positioned(
                  left: i * slot,
                  width: slot,
                  top: 0,
                  height: _baseline,
                  child: _Bar(
                    bar: bars[i],
                    label: labels[i],
                    height: peak == 0 ? 0 : bars[i].value / peak * _maxBar,
                    width: barWidth,
                    current: i == bars.length - 1,
                  ),
                ),
                Positioned(
                  left: i * slot,
                  width: slot,
                  top: _labelTop,
                  child: ExcludeSemantics(
                    child: Text(
                      labels[i],
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 11,
                        height: insightsLeading,
                        letterSpacing: 0,
                        fontWeight: i == bars.length - 1
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: i == bars.length - 1
                            ? AppColors.ink
                            : AppColors.textSubtle,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.bar,
    required this.label,
    required this.height,
    required this.width,
    required this.current,
  });

  final InsightsBar bar;
  final String label;
  final double height;
  final double width;
  final bool current;

  static const _radius = BorderRadius.vertical(
    top: Radius.circular(8),
    bottom: Radius.circular(3),
  );

  // Navy bars: from #0A2E8F to #032886 at 85% opacity.
  static const _navy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xD90A2E8F), Color(0xD9032886)],
  );

  // CSS linear-gradient(102.5deg, gold) on a 28px-wide bar: nearly horizontal.
  static const _gold = LinearGradient(
    begin: Alignment(-1.907, -0.094),
    end: Alignment(1.907, 0.094),
    colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDeep],
    stops: [0, 0.45, 1],
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: ${formatGrouped(bar.value)} Stars',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: height),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 3,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatGrouped(bar.value),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  height: insightsLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: current ? AppColors.goldDeep : AppColors.textBody,
                ),
              ),
            ),
            Container(
              width: width,
              height: value,
              decoration: BoxDecoration(
                gradient: current ? _gold : _navy,
                borderRadius: _radius,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
