import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// Figma "Sheet — Add Talent": tick talents from [catalogue] and tap Done.
/// Completes with the new talent list (current order kept, new ones
/// appended), or null when dismissed.
Future<List<String>?> showAddTalentSheet(
  BuildContext context, {
  required List<Talent> catalogue,
  required List<String> selected,
}) {
  return showStarSheet<List<String>>(
    context: context,
    builder: (_) => AddTalentSheet(catalogue: catalogue, selected: selected),
  );
}

class AddTalentSheet extends StatefulWidget {
  const AddTalentSheet({
    super.key,
    required this.catalogue,
    required this.selected,
  });

  final List<Talent> catalogue;

  /// Talent names already on the profile.
  final List<String> selected;

  @override
  State<AddTalentSheet> createState() => _AddTalentSheetState();
}

class _AddTalentSheetState extends State<AddTalentSheet> {
  late final Set<String> _picked = {...widget.selected};

  void _toggle(String name) {
    setState(() {
      if (!_picked.remove(name)) _picked.add(name);
    });
  }

  void _done() {
    final result = [
      for (final name in widget.selected)
        if (_picked.contains(name)) name,
      for (final talent in widget.catalogue)
        if (_picked.contains(talent.name) &&
            !widget.selected.contains(talent.name))
          talent.name,
    ];
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return StarSheet(
      title: 'Add a talent',
      subtitle: 'Shown on your profile and used for challenges',
      children: [
        for (final talent in widget.catalogue)
          _TalentOption(
            talent: talent,
            selected: _picked.contains(talent.name),
            onTap: () => _toggle(talent.name),
          ),
        StarPrimaryButton(label: 'Done', onPressed: _done),
      ],
    );
  }
}

class _TalentOption extends StatelessWidget {
  const _TalentOption({
    required this.talent,
    required this.selected,
    required this.onTap,
  });

  final Talent talent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
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
                child: Text(
                  '${talent.emoji} ${talent.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.21,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
