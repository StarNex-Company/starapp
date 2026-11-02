import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_style.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';

const _pillText = TextStyle(
  fontSize: 12,
  height: 20 / 12,
  letterSpacing: 0,
  fontWeight: FontWeight.w500,
);

/// "TALENTS" field: removable talent pills and a navy "Add" pill.
class EditProfileTalents extends StatelessWidget {
  const EditProfileTalents({
    super.key,
    required this.talents,
    required this.onRemove,
    required this.onAdd,
  });

  final List<String> talents;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        const EditProfileLabel('Talents'),
        Container(
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.all(11),
          decoration: editProfileFieldDecoration.copyWith(
            border: Border.all(color: EditProfileColors.border),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final talent in talents)
                _TalentPill(
                  key: ValueKey(talent),
                  label: talent,
                  onRemove: () => onRemove(talent),
                ),
              _AddPill(onTap: onAdd),
            ],
          ),
        ),
      ],
    );
  }
}

class _TalentPill extends StatelessWidget {
  const _TalentPill({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.only(left: 13, right: 7),
      decoration: BoxDecoration(
        color: EditProfileColors.tint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EditProfileColors.pillBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _pillText.copyWith(color: EditProfileColors.brand),
            ),
          ),
          // 6px gap + a padded hit area around the 14px cross.
          Semantics(
            button: true,
            label: 'Remove $label',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: SvgPicture.asset(
                  SettingsIcons.remove,
                  width: 14,
                  height: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPill extends StatelessWidget {
  const _AddPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add talent',
      child: Material(
        color: AppColors.brandNavy,
        shape: const StadiumBorder(
          side: BorderSide(color: EditProfileColors.addPillBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                SvgPicture.asset(SettingsIcons.add, width: 14, height: 14),
                ExcludeSemantics(
                  child: Text(
                    'Add',
                    style: _pillText.copyWith(color: AppColors.lunarWhite),
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
