import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_style.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_toggle.dart';

/// "Open to opportunities" switch card at the end of the form.
class EditProfileOpportunitiesCard extends StatelessWidget {
  const EditProfileOpportunitiesCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: EditProfileColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: EditProfileColors.tint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    SettingsIcons.mail,
                    width: 20,
                    height: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        'Open to opportunities',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 18.75 / 15,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          color: EditProfileColors.text,
                        ),
                      ),
                      Text(
                        'Companies can contact you',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          letterSpacing: 0,
                          color: EditProfileColors.label,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SettingsToggle(
                  value: value,
                  offKnobColor: AppColors.iconButtonBg,
                  semanticLabel: 'Open to opportunities',
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
