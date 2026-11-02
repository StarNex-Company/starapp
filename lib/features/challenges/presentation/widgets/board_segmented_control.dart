import 'package:flutter/material.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

class BoardSegment {
  const BoardSegment({required this.label, required this.icon});

  final String label;

  /// SVG asset path; tinted to match the label.
  final String icon;
}

/// The board's view switcher (This Challenge / All-Time).
class BoardSegmentedControl extends StatelessWidget {
  const BoardSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<BoardSegment> segments;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return StarTabBar(
      tabs: [
        for (final s in segments) StarTab(label: s.label, icon: s.icon),
      ],
      selected: selected,
      onSelected: onChanged,
    );
  }
}
