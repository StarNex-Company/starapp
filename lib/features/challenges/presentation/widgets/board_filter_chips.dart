import 'package:flutter/material.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// Single-choice, horizontally scrolling row of filter chips
/// (regions on the live board, scopes on the all-time board).
class BoardFilterChips extends StatelessWidget {
  const BoardFilterChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return StarChoiceChips<String>(
      chips: [for (final label in labels) StarChip(value: label, label: label)],
      selected: selected,
      onSelected: onSelected,
    );
  }
}
