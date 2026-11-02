import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 40px round translucent icon button used on the creation screens.
class StoryCircleButton extends StatelessWidget {
  const StoryCircleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0x59000000),
    this.iconSize = 20,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 40,
            child: Center(
              child: SvgPicture.asset(icon, width: iconSize, height: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}
