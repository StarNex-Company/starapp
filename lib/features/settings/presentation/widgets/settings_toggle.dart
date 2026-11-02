import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// surface/strong/c2c2c2: the off knob of the design's toggle component.
const settingsKnobStrong = Color(0xFFC2C2C2);

/// 48×22 navy switch (Figma "Toggle - Switch"): outlined with a grey knob on
/// the left when off, filled navy with a white knob on the right when on.
class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.offKnobColor = settingsKnobStrong,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Some design instances use the lighter #eeeeee knob.
  final Color offKnobColor;
  final String? semanticLabel;

  static const _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: semanticLabel,
      enabled: onChanged != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOut,
          width: 48,
          height: 22,
          decoration: BoxDecoration(
            color: value ? AppColors.brandNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.brandNavy,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: _duration,
                curve: Curves.easeOut,
                // 4px from the outer edge on either side (inside the border).
                left: value ? 17.5 : 2.5,
                top: 1.5,
                child: AnimatedContainer(
                  duration: _duration,
                  width: 25,
                  height: 16,
                  decoration: BoxDecoration(
                    color: value ? Colors.white : offKnobColor,
                    borderRadius: BorderRadius.circular(100),
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
