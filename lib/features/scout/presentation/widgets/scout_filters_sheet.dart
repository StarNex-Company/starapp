import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/scout/data/models/open_call_filters.dart';
import 'package:starapp/features/scout/data/models/talent_category.dart';
import 'package:starapp/features/scout/data/provider/scout_providers.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_widgets.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// Opens "Filter open calls" over [initial]; resolves to the filters to
/// apply, or null when dismissed.
Future<OpenCallFilters?> showScoutFiltersSheet(
  BuildContext context,
  OpenCallFilters initial,
) => showStarSheet<OpenCallFilters>(
  context: context,
  builder: (_) => ScoutFiltersSheet(initial: initial),
);

/// The design's location choices. The API takes any city name.
const scoutFilterCities = ['Lagos', 'Abuja', 'Accra'];

/// Sheet — Scout Filters: category, status window, location and "Match my
/// talents". Changes stay in a draft until "Show N roles".
class ScoutFiltersSheet extends ConsumerStatefulWidget {
  const ScoutFiltersSheet({super.key, required this.initial});

  final OpenCallFilters initial;

  @override
  ConsumerState<ScoutFiltersSheet> createState() => _ScoutFiltersSheetState();
}

class _ScoutFiltersSheetState extends ConsumerState<ScoutFiltersSheet> {
  late OpenCallFilters _draft = widget.initial;

  /// Keeps the button's number steady while a new count loads.
  int? _lastCount;

  void _update(OpenCallFilters draft) => setState(() => _draft = draft);

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(openCallCountProvider(_draft)).value ?? _lastCount;
    _lastCount = count;
    final openNow = ref
        .watch(
          openCallCountProvider(
            const OpenCallFilters(window: OpenCallWindow.openNow),
          ),
        )
        .value;
    final talents = ref.watch(
      currentUserProvider.select((u) => u.value?.talents ?? const <String>[]),
    );
    final window = _draft.window ?? OpenCallWindow.openNow;
    final cities = {...scoutFilterCities, ?_draft.city};
    final maxHeight = MediaQuery.sizeOf(context).height - 72;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: StarSheet(
        title: 'Filter open calls',
        subtitle: 'Find roles that fit your talent',
        children: [
          const ScoutSectionTitle('Category'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ScoutChip(
                label: 'All',
                selected: _draft.category == null,
                onTap: () => _update(_draft.copyWith(category: null)),
              ),
              for (final category in TalentCategory.values)
                ScoutChip(
                  label: category.label,
                  selected: _draft.category == category,
                  onTap: () => _update(_draft.copyWith(category: category)),
                ),
            ],
          ),
          const ScoutSectionTitle('Status'),
          _Option(
            title: 'Open now',
            subtitle: openNow == null
                ? null
                : '$openNow ${openNow == 1 ? 'role' : 'roles'} accepting '
                      'applications',
            selected: window == OpenCallWindow.openNow,
            onTap: () => _update(_draft.copyWith(window: null)),
          ),
          _Option(
            title: 'Closing this week',
            subtitle: 'Apply before the deadline',
            selected: window == OpenCallWindow.closingThisWeek,
            onTap: () => _update(
              _draft.copyWith(window: OpenCallWindow.closingThisWeek),
            ),
          ),
          _Option(
            title: 'Newly posted',
            subtitle: 'Added in the last 48 hours',
            selected: window == OpenCallWindow.newlyPosted,
            onTap: () =>
                _update(_draft.copyWith(window: OpenCallWindow.newlyPosted)),
          ),
          const ScoutSectionTitle('Location'),
          _Option(
            title: 'Anywhere',
            selected: _draft.city == null && !_draft.remoteOnly,
            onTap: () =>
                _update(_draft.copyWith(city: null, remoteOnly: false)),
          ),
          for (final city in cities)
            _Option(
              title: city,
              selected: _draft.city == city && !_draft.remoteOnly,
              onTap: () =>
                  _update(_draft.copyWith(city: city, remoteOnly: false)),
            ),
          _Option(
            title: 'Remote',
            selected: _draft.remoteOnly,
            onTap: () => _update(_draft.copyWith(city: null, remoteOnly: true)),
          ),
          _MatchTalentsRow(
            talents: talents,
            value: _draft.matchMyTalents,
            onChanged: (on) => _update(_draft.copyWith(matchMyTalents: on)),
          ),
          StarPrimaryButton(
            label: count == null
                ? 'Show roles'
                : 'Show $count ${count == 1 ? 'role' : 'roles'}',
            onPressed: () => Navigator.of(context).pop(_draft),
          ),
          StarOutlinedButton(
            label: 'Reset filters',
            onPressed: () => _update(_draft.resetSheet()),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
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
        borderRadius: BorderRadius.circular(8),
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
                      style: scoutText(14, weight: FontWeight.w600),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: scoutText(12, color: AppColors.textSubtle),
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

class _MatchTalentsRow extends StatelessWidget {
  const _MatchTalentsRow({
    required this.talents,
    required this.value,
    required this.onChanged,
  });

  final List<String> talents;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// "Singing, production, songwriting".
  String get _talentsLine {
    final line = talents.join(', ').toLowerCase();
    return line.isEmpty
        ? 'Based on your profile'
        : '${line[0].toUpperCase()}${line.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          const ScoutIconTile(icon: ScoutIcons.lock),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  'Match my talents',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: scoutText(15, weight: FontWeight.w500),
                ),
                Text(
                  _talentsLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: scoutText(12, color: AppColors.textSubtle),
                ),
              ],
            ),
          ),
          ScoutToggle(
            value: value,
            onChanged: onChanged,
            label: 'Match my talents',
          ),
        ],
      ),
    );
  }
}
