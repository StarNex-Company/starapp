import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/preview_icons.dart';

const _knobOff = Color(0xFFC2C2C2); // surface/strong/c2c2c2

/// Settings row: icon tile, label, current value and chevron.
class PreviewSettingRow extends StatelessWidget {
  const PreviewSettingRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  /// SVG asset path.
  final String icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: _RowLayout(
        icon: icon,
        label: label,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.2,
                  letterSpacing: 0,
                  fontSize: 13,
                  color: AppColors.textSubtle,
                ),
              ),
            ),
            SvgPicture.asset(PreviewIcons.chevron, width: 16, height: 16),
          ],
        ),
      ),
    );
  }
}

/// Settings row with an on/off switch instead of a value.
class PreviewSwitchRow extends StatelessWidget {
  const PreviewSwitchRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: _RowLayout(
        icon: icon,
        label: label,
        trailing: PreviewToggle(value: value, onChanged: onChanged),
      ),
    );
  }
}

class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final String icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.brandTint,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset(icon),
          ),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                height: 1.2,
                letterSpacing: 0,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

/// 48×22 pill switch with a pill-shaped knob.
class PreviewToggle extends StatelessWidget {
  const PreviewToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  static const _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: SizedBox(
          width: 48,
          height: 22,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: _duration,
                decoration: BoxDecoration(
                  color: value
                      ? AppColors.brandNavy
                      : AppColors.brandNavy.withValues(alpha: 0),
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                  border: value
                      ? null
                      : Border.all(color: AppColors.brandNavy, width: 1.5),
                ),
              ),
              AnimatedPositioned(
                duration: _duration,
                curve: Curves.easeOut,
                left: value ? 19 : 4,
                top: 3,
                child: AnimatedContainer(
                  duration: _duration,
                  width: 25,
                  height: 16,
                  decoration: BoxDecoration(
                    color: value ? Colors.white : _knobOff,
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
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
