import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/moderation/presentation/widgets/appeal_icons.dart';

const _radius = BorderRadius.all(Radius.circular(14));

/// Attached proof file with a remove button.
class AppealProofFile extends StatelessWidget {
  const AppealProofFile({
    super.key,
    required this.name,
    required this.detail,
    required this.onRemove,
  });

  final String name;

  /// e.g. "24.8 MB · uploaded".
  final String detail;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _radius,
        border: Border.all(color: AppColors.borderField),
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.dangerTint,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset(AppealIcons.file, width: 18, height: 18),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.2,
                    letterSpacing: 0,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.2,
                    letterSpacing: 0,
                    fontSize: 12,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Remove file',
            child: Material(
              color: AppColors.closeButtonBg,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onRemove,
                child: SizedBox.square(
                  dimension: 30,
                  child: Center(
                    child: SvgPicture.asset(
                      AppealIcons.close,
                      width: 14,
                      height: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed drop-zone style button for attaching proof files.
class AppealAddFilesButton extends StatelessWidget {
  const AppealAddFilesButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: const _DashedBorderPainter(),
      child: Material(
        color: AppColors.brandTintSoft,
        borderRadius: _radius,
        child: InkWell(
          borderRadius: _radius,
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                SvgPicture.asset(AppealIcons.paperclip, width: 18, height: 18),
                Text(
                  label,
                  style: const TextStyle(
                    height: 1.2,
                    letterSpacing: 0,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  static const _stroke = 1.5;
  static const _dash = 4.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    const radius = Radius.circular(14 - _stroke / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, radius));
    final paint = Paint()
      ..color = AppColors.brandOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    for (final PathMetric metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
