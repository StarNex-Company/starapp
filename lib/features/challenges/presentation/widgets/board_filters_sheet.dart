import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// The sheet's categories and the arena each one filters to; the first shows
/// every arena.
const _categoryArenas = <String, ChallengeArena?>{
  'All categories': null,
  'Music & Audio': ChallengeArena.music,
  'Dance & Choreography': ChallengeArena.dance,
  'Comedy': ChallengeArena.comedy,
  'Visual Arts': ChallengeArena.visualArts,
};

final challengeFilterCategories = [..._categoryArenas.keys];

/// The arena a sheet category filters to; null for "All categories".
ChallengeArena? challengeFilterArena(String category) =>
    _categoryArenas[category];

/// The sheet category for [arena]; "All categories" for null or an arena
/// the sheet doesn't list.
String challengeFilterLabel(ChallengeArena? arena) =>
    _categoryArenas.entries.where((e) => e.value == arena).firstOrNull?.key ??
    challengeFilterCategories.first;

/// Opens the "Challenge filters" sheet. Resolves to the applied category, or
/// null when the sheet is dismissed.
Future<String?> showChallengeFiltersSheet(
  BuildContext context, {
  String selected = 'All categories',
}) {
  return showStarSheet<String>(
    context: context,
    builder: (_) => _ChallengeFiltersSheet(initial: selected),
  );
}

class _ChallengeFiltersSheet extends StatefulWidget {
  const _ChallengeFiltersSheet({required this.initial});

  final String initial;

  @override
  State<_ChallengeFiltersSheet> createState() => _ChallengeFiltersSheetState();
}

class _ChallengeFiltersSheetState extends State<_ChallengeFiltersSheet> {
  late String _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return StarSheet(
      title: 'Challenge filters',
      children: [
        for (final category in challengeFilterCategories)
          _CategoryOption(
            label: category,
            selected: category == _selected,
            onTap: () => setState(() => _selected = category),
          ),
        StarPrimaryButton(
          label: 'Apply',
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      // The sheet's white surface would hide ink drawn on the route's Material.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              spacing: 12,
              children: [
                StarRadioDot(selected: selected),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1.21,
                      letterSpacing: 0,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
