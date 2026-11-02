import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/data/provider/insights_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_breakdown_card.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_chart_card.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_date_range_sheet.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_post_row.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_segmented.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_stars_card.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// "Profile — Star Insights": total Stars and tier progress, then the
/// period's chart, where Stars come from and the top performing posts. The
/// segmented control and the calendar's date range sheet switch the period.
class StarInsightsPage extends ConsumerStatefulWidget {
  const StarInsightsPage({super.key});

  @override
  ConsumerState<StarInsightsPage> createState() => _StarInsightsPageState();
}

class _StarInsightsPageState extends ConsumerState<StarInsightsPage> {
  /// The last period shown, kept on screen while the next one loads.
  (InsightsPeriod, Insights)? _last;

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  void _openPost(TopPost post) =>
      context.push('${AppRoutes.post}?id=${post.id}');

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(insightsRangeProvider);
    final insights = ref.watch(insightsProvider(period));
    if (insights.value case final data? when !insights.isLoading) {
      _last = (period, data);
    }
    final last = _last;
    final shown = insights.isLoading && last != null
        ? AsyncData(last)
        : insights.whenData((data) => (period, data));
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Star Insights',
        leading: StarIconButton.back(onPressed: _back),
        trailing: StarIconButton(
          icon: InsightsIcons.calendar,
          tooltip: 'Date range',
          onPressed: () => showInsightsDateRangeSheet(context),
        ),
      ),
      body: StarAsyncView(
        value: shown,
        onRetry: () => ref.invalidate(insightsProvider(period)),
        builder: (shown) {
          final (shownPeriod, data) = shown;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                _StarsCard(insights: data, period: shownPeriod),
                InsightsSegmentedControl(
                  selected: switch (period.range) {
                    InsightsRange.week ||
                    InsightsRange.month ||
                    InsightsRange.year => period.range,
                    InsightsRange.sixMonths || InsightsRange.custom => null,
                  },
                  onChanged: ref.read(insightsRangeProvider.notifier).select,
                ),
                InsightsChartCard(
                  caption: _chartCaption(shownPeriod, data),
                  bars: data.bars,
                  barPeriod: data.barPeriod,
                ),
                InsightsBreakdownCard(
                  total: data.breakdownTotal,
                  sources: data.breakdown,
                ),
                if (data.boost case final boost?)
                  InsightsBoostNotice(boost: boost),
                if (data.topPerforming.isNotEmpty) ...[
                  InsightsSectionHeader(
                    title: 'Top performing',
                    onSeeAll: () => context.push(AppRoutes.profileTopPosts),
                  ),
                  for (final post in data.topPerforming)
                    InsightsPostRow(
                      key: ValueKey(post.id),
                      post: post,
                      onTap: () => _openPost(post),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Beside the chart title: "Last 7 days", "Last 6 months", "This year" or
/// the custom dates.
String _chartCaption(InsightsPeriod period, Insights insights) {
  final count = insights.bars.length;
  return switch (period.range) {
    InsightsRange.year => 'This year',
    InsightsRange.custom =>
      '${DateFormat('MMM d').format(period.from)} – '
          '${DateFormat('MMM d').format(period.to)}',
    _ => switch (insights.barPeriod) {
      InsightsBarPeriod.day => 'Last $count days',
      InsightsBarPeriod.week => 'Last $count weeks',
      InsightsBarPeriod.month => 'Last $count months',
    },
  };
}

/// After the Stars earned: "+384 this month".
String _periodPhrase(InsightsRange range) => switch (range) {
  InsightsRange.week => 'this week',
  InsightsRange.month => 'this month',
  InsightsRange.sixMonths => 'in 6 months',
  InsightsRange.year => 'this year',
  InsightsRange.custom => 'in this range',
};

/// The Total Stars card with the signed-in user's total and tier.
class _StarsCard extends ConsumerWidget {
  const _StarsCard({required this.insights, required this.period});

  final Insights insights;
  final InsightsPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final progress = ref.watch(tierProgressProvider).value;

    return InsightsStarsCard(
      totalStars: user?.stars ?? 0,
      tier: user?.tier.label ?? '',
      growthPercent: insights.growthPercent,
      growthLabel:
          '+${formatGrouped(insights.starsEarned)} '
          '${_periodPhrase(period.range)}',
      nextTier: progress?.nextTier?.label,
      starsToNext: progress?.starsToNext,
      progress: progress?.progress ?? 0,
      onTap: () => context.push(AppRoutes.profilePassport),
      onNextTierTap: () => context.push(AppRoutes.tierLevelUp),
    );
  }
}
