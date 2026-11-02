import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/camera_icons.dart';

const _progressTrack = Color(0x40FFFFFF); // rgba(255,255,255,0.25), no token

const _radius = BorderRadius.all(Radius.circular(2));

/// Thin bar along the top of the viewfinder filling toward the max duration.
class CameraRecProgress extends StatelessWidget {
  const CameraRecProgress({super.key, required this.progress});

  /// 0..1 share of the maximum duration recorded so far.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _radius,
      child: Container(
        height: 4,
        color: _progressTrack,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          heightFactor: 1,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: _radius,
            ),
          ),
        ),
      ),
    );
  }
}

/// Red "● 00:47 / 03:00" pill shown while recording.
class CameraRecTimerPill extends StatelessWidget {
  const CameraRecTimerPill({
    super.key,
    required this.elapsed,
    required this.max,
  });

  final Duration elapsed;
  final Duration max;

  static String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const ShapeDecoration(
        color: AppColors.danger,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(CameraIcons.recDot),
          const SizedBox(width: 4),
          Text(
            '${_format(elapsed)} / ${_format(max)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.2,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
