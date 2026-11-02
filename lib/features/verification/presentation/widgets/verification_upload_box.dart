import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/verification/data/models/verification.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_style.dart';

const _stroke = 1.5;

/// 2516582 → "2.4 MB", 84000 → "82 KB".
String _size(int bytes) => bytes >= 1024 * 1024
    ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
    : '${(bytes / 1024).ceil()} KB';
const _radius = 14.0;

/// Dashed drop zone for the ID photo. Before an upload it shows the ID card
/// icon, [prompt] and the accepted formats; once [document] is attached it
/// shows a green check and the file name; tapping again replaces it.
class VerificationUploadBox extends StatelessWidget {
  const VerificationUploadBox({
    super.key,
    required this.prompt,
    required this.document,
    required this.uploading,
    required this.onTap,
  });

  final String prompt;
  final VerificationDocument? document;
  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final document = this.document;
    final Widget icon;
    if (uploading) {
      icon = const SizedBox.square(
        dimension: 28,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.brandBlue,
          ),
        ),
      );
    } else if (document != null) {
      icon = Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(VerificationIcons.check, width: 15, height: 15),
      );
    } else {
      icon = SvgPicture.asset(VerificationIcons.idCard, width: 28, height: 28);
    }

    return Semantics(
      button: true,
      label: document == null ? prompt : 'Replace ID photo',
      excludeSemantics: true,
      onTap: uploading ? null : onTap,
      child: CustomPaint(
        foregroundPainter: const _DashedBorderPainter(),
        child: Material(
          color: AppColors.brandTintSoft,
          borderRadius: BorderRadius.circular(_radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: uploading ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(16 + _stroke),
              child: Column(
                spacing: 6,
                children: [
                  icon,
                  Text(
                    document == null ? prompt : 'ID photo added',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: verificationLeading,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandBlue,
                    ),
                  ),
                  Text(
                    document == null
                        ? 'JPG, PNG or PDF · max 10 MB'
                        : '${document.fileName} · ${_size(document.sizeBytes)}',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: verificationLeading,
                      letterSpacing: 0,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  static const _dash = 5.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    const radius = Radius.circular(_radius - _stroke / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, radius));
    final paint = Paint()
      ..color = VerificationColors.uploadOutline
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
