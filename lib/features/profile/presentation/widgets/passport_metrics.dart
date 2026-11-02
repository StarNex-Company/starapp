import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/data/models/talent_passport.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';

/// Two-column grid of the AI score components, each with a progress bar.
class PassportMetricsGrid extends StatelessWidget {
  const PassportMetricsGrid({super.key, required this.metrics});

  final List<PassportMetric> metrics;

  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - _gap) / 2;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final m in metrics)
              SizedBox(
                width: width,
                child: _MetricTile(metric: m),
              ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final PassportMetric metric;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${metric.kind.label} ${metric.percent}%',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.brandTintSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderField),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              spacing: 6,
              children: [
                Expanded(
                  child: Text(
                    metric.kind.label,
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
                Text(
                  '${metric.percent}%',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 13,
                    height: insightsLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlue,
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 6,
                child: ColoredBox(
                  color: AppColors.track,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: metric.percent.clamp(0, 100) / 100,
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
