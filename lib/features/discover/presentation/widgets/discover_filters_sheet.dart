import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// Opens the Discover "Filters" sheet (country and sort order), starting from
/// [initial]. Resolves to the chosen filters on "Show results", or null when
/// dismissed.
Future<DiscoverFilters?> showDiscoverFiltersSheet(
  BuildContext context, {
  DiscoverFilters initial = const DiscoverFilters(),
}) {
  return showStarSheet<DiscoverFilters>(
    context: context,
    builder: (_) => DiscoverFiltersSheet(initial: initial),
  );
}

class DiscoverFiltersSheet extends StatefulWidget {
  const DiscoverFiltersSheet({
    super.key,
    this.initial = const DiscoverFilters(),
  });

  final DiscoverFilters initial;

  @override
  State<DiscoverFiltersSheet> createState() => _DiscoverFiltersSheetState();
}

class _DiscoverFiltersSheetState extends State<DiscoverFiltersSheet> {
  late DiscoverFilters _filters = widget.initial;

  @override
  Widget build(BuildContext context) {
    return StarSheet(
      title: 'Filters',
      subtitle: 'Narrow down creators and challenges',
      children: [
        const _GroupLabel('Country'),
        for (final country in FilterCountry.values)
          _OptionRow(
            label: country.label,
            selected: _filters.country == country,
            onTap: () =>
                setState(() => _filters = _filters.copyWith(country: country)),
          ),
        const _GroupLabel('Sort by'),
        for (final sort in FilterSort.values)
          _OptionRow(
            label: sort.label,
            selected: _filters.sort == sort,
            onTap: () =>
                setState(() => _filters = _filters.copyWith(sort: sort)),
          ),
        StarPrimaryButton(
          label: 'Show results',
          onPressed: () => Navigator.of(context).pop(_filters),
        ),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: discoverText(18, FontWeight.w600, AppColors.brandBlue),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
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
      // Own Material so the ripple shows above the sheet's white surface.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
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
                    style: discoverText(14, FontWeight.w600, AppColors.ink),
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
