import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/shared_icons.dart';

/// 37px grey circular icon button used in headers and on result screens.
class StarIconButton extends StatelessWidget {
  const StarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 18,
    this.background = AppColors.iconButtonBg,
    this.tooltip,
  });

  const StarIconButton.back({super.key, required this.onPressed})
      : icon = SharedIcons.arrowLeft,
        iconSize = 25,
        background = AppColors.iconButtonBg,
        tooltip = 'Back';

  const StarIconButton.close({super.key, required this.onPressed})
      : icon = SharedIcons.close,
        iconSize = 18,
        background = AppColors.closeButtonBg,
        tooltip = 'Close';

  const StarIconButton.info({super.key, required this.onPressed})
      : icon = SharedIcons.info,
        iconSize = 18,
        background = AppColors.iconButtonBg,
        tooltip = 'More info';

  static const size = 37.0;

  /// SVG asset path.
  final String icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final Color background;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: SvgPicture.asset(icon, height: iconSize),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
