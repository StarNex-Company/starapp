import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

const _modeInactive = Color(0x99FFFFFF); // rgba(255,255,255,0.6), no token

enum CameraMode {
  photo('Photo'),
  video('Video'),
  text('Text');

  const CameraMode(this.label);
  final String label;
}

/// Maximum clip lengths offered above the shutter.
const cameraDurations = [
  Duration(seconds: 15),
  Duration(seconds: 60),
  Duration(minutes: 3),
];

String _durationLabel(Duration d) => d.inSeconds <= 60 || d.inSeconds % 60 != 0
    ? '${d.inSeconds}s'
    : '${d.inMinutes}m';

/// "15s / 60s / 3m" chips choosing the maximum recording length.
class CameraDurationChips extends StatelessWidget {
  const CameraDurationChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.options = cameraDurations,
  });

  final Duration selected;
  final ValueChanged<Duration> onSelected;
  final List<Duration> options;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          _DurationChip(
            label: _durationLabel(options[i]),
            selected: options[i] == selected,
            onTap: () => onSelected(options[i]),
          ),
        ],
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
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
      selected: selected,
      child: Material(
        color: selected ? AppColors.brandBlue : AppColors.closeButtonBg,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textBody,
                fontSize: 13,
                height: 1.2,
                letterSpacing: 0,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Photo / Video / Text mode switcher under the shutter.
class CameraModeTabs extends StatelessWidget {
  const CameraModeTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// Half of the 26px gap between labels; padding on both sides of each
  /// label widens the tap target without moving the text.
  static const _hPad = 13.0;
  static const vPad = 8.0;

  final CameraMode selected;
  final ValueChanged<CameraMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final mode in CameraMode.values)
          Semantics(
            button: true,
            selected: mode == selected,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(mode),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _hPad,
                  vertical: vPad,
                ),
                child: Text(
                  mode.label,
                  style: TextStyle(
                    color: mode == selected ? Colors.white : _modeInactive,
                    fontSize: 14,
                    height: 1.2,
                    letterSpacing: 0,
                    fontWeight: mode == selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
