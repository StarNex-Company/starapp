import 'package:flutter/material.dart';
import 'package:starapp/features/profile/data/models/saved_item.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// "All · Videos · Challenges · Audio" filter row; `null` is All. Scrolls
/// sideways when the labels don't fit.
class SavedFilterChips extends StatelessWidget {
  const SavedFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.padding = EdgeInsets.zero,
  });

  final SavedKind? selected;
  final ValueChanged<SavedKind?> onChanged;
  final EdgeInsets padding;

  static const _filters = <(SavedKind?, String)>[
    (null, 'All'),
    (SavedKind.video, 'Videos'),
    (SavedKind.challenge, 'Challenges'),
    (SavedKind.audio, 'Audio'),
  ];

  @override
  Widget build(BuildContext context) {
    return StarChoiceChips<SavedKind?>(
      chips: [
        for (final (kind, label) in _filters)
          StarChip(value: kind, label: label),
      ],
      selected: selected,
      onSelected: onChanged,
      padding: padding,
    );
  }
}
