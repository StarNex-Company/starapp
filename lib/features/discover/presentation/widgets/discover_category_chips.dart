import 'package:flutter/material.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// Full-bleed, horizontally scrolling row of talent category pills, led by
/// "All"; one is selected at a time. Category icons keep their colours
/// until selected; "All"'s takes the label colour.
class DiscoverCategoryChips extends StatelessWidget {
  const DiscoverCategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<DiscoverCategory> categories;

  /// The selected category's id; null is "All".
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return StarChoiceChips<String?>(
      chips: [
        const StarChip(value: null, label: 'All', icon: DiscoverIcons.chipAll),
        for (final category in categories)
          StarChip(
            value: category.id,
            label: category.name,
            icon: DiscoverIcons.category(category.id),
            keepIconColors: true,
          ),
      ],
      selected: selected,
      onSelected: onSelected,
      padding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
