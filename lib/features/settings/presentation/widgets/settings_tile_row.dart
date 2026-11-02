import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';

const _leading = 1.21;

/// Row with a rounded 40px icon tile, a title and optional caption, and a
/// trailing value + chevron (Privacy & Security rows, photo sheet actions).
/// [danger] turns it red (Delete account, Remove current photo).
class SettingsTileRow extends StatelessWidget {
  const SettingsTileRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.value,
    this.trailing,
    this.danger = false,
  });

  /// SVG asset, drawn at its own size (about 20px).
  final String icon;
  final String title;
  final String? subtitle;

  /// Grey text before the chevron, e.g. "Everyone", "2 devices".
  final String? value;

  /// Replaces the value and chevron, e.g. a [SettingsToggle].
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: danger ? AppColors.dangerTint : AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(icon),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        height: _leading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: danger ? AppColors.danger : AppColors.ink,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: _leading,
                          letterSpacing: 0,
                          color: AppColors.textSubtle,
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      // Long values ("Verified companies only") give way
                      // to the title.
                      if (value != null)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            value!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              height: _leading,
                              letterSpacing: 0,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ),
                      SvgPicture.asset(
                        danger
                            ? SettingsIcons.tileChevronDanger
                            : SettingsIcons.tileChevron,
                        width: 18,
                        height: 18,
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hairline between [SettingsTileRow]s.
class SettingsTileDivider extends StatelessWidget {
  const SettingsTileDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.borderField, // surface/muted/e6e8ef
      child: SizedBox(height: 1, width: double.infinity),
    );
  }
}
