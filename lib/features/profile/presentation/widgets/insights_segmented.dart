import 'package:flutter/material.dart';
import 'package:starapp/features/profile/data/models/insights.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// Week / Month / Year. [selected] is null for a period chosen in the date
/// range sheet that has no tab (Last 6 months, Custom); no tab is
/// highlighted then.
class InsightsSegmentedControl extends StatelessWidget {
  const InsightsSegmentedControl({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const segments = [
    (InsightsRange.week, 'Week'),
    (InsightsRange.month, 'Month'),
    (InsightsRange.year, 'Year'),
  ];

  final InsightsRange? selected;
  final ValueChanged<InsightsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final index = segments.indexWhere((s) => s.$1 == selected);
    return StarTabBar(
      tabs: [for (final (_, label) in segments) StarTab(label: label)],
      selected: index < 0 ? null : index,
      onSelected: (i) => onChanged(segments[i].$1),
    );
  }
}
