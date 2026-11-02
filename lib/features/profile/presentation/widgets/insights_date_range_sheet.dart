import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/features/profile/data/provider/insights_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// Opens the "Date range" sheet for Star Insights. Picking a preset switches
/// [insightsRangeProvider] and closes the sheet; "Custom range" closes it and
/// asks for start and end dates.
Future<void> showInsightsDateRangeSheet(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final current = container.read(insightsRangeProvider);
  final insights = container.read(insightsProvider(current)).value;
  final last = DateUtils.dateOnly(DateTime.now());
  final since = insights?.since;
  final first = since == null || since.isAfter(last)
      ? DateTime(last.year - 1, last.month, last.day)
      : DateUtils.dateOnly(since);

  final picked = await showStarSheet<InsightsRange>(
    context: context,
    builder: (_) => const _DateRangeSheet(),
  );
  if (picked != InsightsRange.custom || !context.mounted) return;

  final period = container.read(insightsRangeProvider);
  final initial = period.range == InsightsRange.custom
      ? DateTimeRange(start: period.from, end: period.to)
      : DateTimeRange(
          start: DateTime(last.year, last.month, last.day - 29),
          end: last,
        );
  final range = await showDateRangePicker(
    context: context,
    firstDate: first,
    lastDate: last,
    initialDateRange: DateTimeRange(
      start: initial.start.isBefore(first) ? first : initial.start,
      end: initial.end.isAfter(last) ? last : initial.end,
    ),
  );
  if (range == null) return;
  container
      .read(insightsRangeProvider.notifier)
      .selectCustom(range.start, range.end);
}

/// Option title for each period.
String _title(InsightsRange range) => switch (range) {
  InsightsRange.week => 'Last 7 days',
  InsightsRange.month => 'Last 30 days',
  InsightsRange.sixMonths => 'Last 6 months',
  InsightsRange.year => 'This year',
  InsightsRange.custom => 'Custom range',
};

/// The dates a period covers: "Oct 3 – Oct 9", "May – Oct 2026".
String _span(InsightsPeriod period) {
  final day = DateFormat('MMM d');
  final month = DateFormat('MMM');
  return switch (period.range) {
    InsightsRange.sixMonths || InsightsRange.year =>
      '${month.format(period.from)} – ${month.format(period.to)} '
          '${period.to.year}',
    _ => '${day.format(period.from)} – ${day.format(period.to)}',
  };
}

class _DateRangeSheet extends ConsumerWidget {
  const _DateRangeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(insightsRangeProvider);

    void choose(InsightsRange range) {
      if (range == InsightsRange.custom) {
        Navigator.of(context).pop(range);
        return;
      }
      ref.read(insightsRangeProvider.notifier).select(range);
      // Let the radio fill before the sheet slides away.
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 180), () {
          if (context.mounted) Navigator.of(context).pop(range);
        }),
      );
    }

    return StarSheet(
      title: 'Date range',
      subtitle: 'Show Stars and views for',
      children: [
        for (final range in InsightsRange.values)
          _Option(
            title: _title(range),
            subtitle: switch (range) {
              InsightsRange.custom when period.range == range => _span(period),
              InsightsRange.custom => 'Pick start and end dates',
              _ => _span(InsightsPeriod.preset(range)),
            },
            selected: period.range == range,
            onTap: () => choose(range),
          ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            spacing: 12,
            children: [
              StarRadioDot(selected: selected),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: insightsLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: insightsLeading,
                        letterSpacing: 0,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
