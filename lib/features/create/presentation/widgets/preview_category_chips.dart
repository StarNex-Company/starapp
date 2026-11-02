import 'package:flutter/material.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// Single-choice wrap of talent category chips.
class PreviewCategoryChips extends StatelessWidget {
  const PreviewCategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return StarChoiceChips<String>(
      chips: [
        for (final category in categories)
          StarChip(value: category, label: category),
      ],
      selected: selected,
      onSelected: onSelected,
      wrap: true,
    );
  }
}
