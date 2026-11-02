import 'package:flutter/material.dart';
import 'package:starapp/features/home/data/models/feed_category.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// Following / Discover / Featured Creators: which feed the home tab shows.
class FeedCategoryChips extends StatelessWidget {
  const FeedCategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final FeedCategory selected;
  final ValueChanged<FeedCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: StarChoiceChips<FeedCategory>(
        chips: [
          for (final category in FeedCategory.values)
            StarChip(value: category, label: category.label),
        ],
        selected: selected,
        onSelected: onSelected,
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }
}
