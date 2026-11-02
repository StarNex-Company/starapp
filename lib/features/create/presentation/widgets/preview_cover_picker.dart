import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/preview_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _tileWidth = 61.0;
const _tileAspect = 61 / 80;
const _radius = BorderRadius.all(Radius.circular(10));

/// Row of candidate cover frames plus a "Custom" tile.
class PreviewCoverPicker extends StatelessWidget {
  const PreviewCoverPicker({
    super.key,
    required this.covers,
    required this.selected,
    required this.onSelected,
    required this.onCustom,
  });

  /// Cover images.
  final List<String> covers;
  final int selected;
  final ValueChanged<int> onSelected;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 9,
      children: [
        for (var i = 0; i < covers.length; i++)
          Flexible(
            child: _Tile(
              child: _CoverTile(
                image: covers[i],
                selected: i == selected,
                onTap: () => onSelected(i),
              ),
            ),
          ),
        Flexible(
          child: _Tile(child: _CustomCoverTile(onTap: onCustom)),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _tileWidth,
      child: AspectRatio(aspectRatio: _tileAspect, child: child),
    );
  }
}

class _CoverTile extends StatelessWidget {
  const _CoverTile({
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Cover',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(borderRadius: _radius, child: StarImage(image)),
            if (selected) ...[
              const DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: _radius,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.brandBlue, width: 3),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlue,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    PreviewIcons.check,
                    width: 11.7,
                    height: 11.7,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomCoverTile extends StatelessWidget {
  const _CustomCoverTile({required this.onTap});

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              SvgPicture.asset(PreviewIcons.plus, width: 18, height: 18),
              const Text(
                'Custom',
                maxLines: 1,
                style: TextStyle(
                  height: 1.2,
                  letterSpacing: 0,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.brandBlue,
                ),
              ),
            ],
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
    const radius = Radius.circular(10 - _stroke / 2);
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
