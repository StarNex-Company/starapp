import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';

// Inter's "normal" line height, so text boxes match the design.
const _leading = 1.21;

const _tileTint = Color(0xFFE7EEFF); // surface/brand-tint/e7eeff
const _rowDivider = Color(0xFFE2E2E2); // border/default/e2e2e2

/// Navy group heading on the Settings screen ("Account", "Preferences").
class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.centerLeft,
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            height: _leading,
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
            color: AppColors.brandNavy,
          ),
        ),
      ),
    );
  }
}

/// Settings list row: a tinted icon tile, title and caption, and a [trailing]
/// control (defaults to a chevron), over a hairline divider.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  /// SVG asset, drawn at its own size in the 38px tile.
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  /// Replaces the chevron, e.g. a [SettingsToggle].
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _rowDivider)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _tileTint,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: SvgPicture.asset(icon),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: _leading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.voidBlack,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        height: _leading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? const SettingsChevron(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 15px navy chevron pointing right.
class SettingsChevron extends StatelessWidget {
  const SettingsChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Transform.flip(
        flipX: true,
        child: SvgPicture.asset(SettingsIcons.chevron, width: 15, height: 15),
      ),
    );
  }
}
