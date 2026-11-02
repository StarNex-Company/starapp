import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _warningTint = Color(0xFFFFF3DB); // surface/tint/fff3db

const _alertIcon = 'assets/vectors/moderation/paused_ic_alert.svg';

/// 76px amber circle with a warning triangle.
class PausedEmblem extends StatelessWidget {
  const PausedEmblem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _warningTint,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(_alertIcon, width: 36, height: 36),
    );
  }
}
