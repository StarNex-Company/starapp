import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';

// Inter's "normal" line height, so text boxes match the design.
const detailLeading = 1.21;

/// Linear gradient that runs from the top-left to the bottom-right corner the
/// way Figma draws it: the colour bands stay parallel to the box's other
/// diagonal whatever its aspect ratio. (Flutter's [LinearGradient] keeps them
/// perpendicular to the begin→end line in pixels, which turns a wide card's
/// top-to-bottom sheen into a left-to-right one.)
class DiagonalGradient extends LinearGradient {
  const DiagonalGradient({required super.colors, super.stops});

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    // Lay the gradient out in a unit square, then stretch it over [rect].
    final matrix = Matrix4(
      rect.width,
      0,
      0,
      0, //
      0,
      rect.height,
      0,
      0,
      0,
      0,
      1,
      0,
      rect.left,
      rect.top,
      0,
      1,
    );
    return ui.Gradient.linear(
      Offset.zero,
      const Offset(1, 1),
      colors,
      stops,
      tileMode,
      matrix.storage,
    );
  }
}

abstract final class DetailGradients {
  static const gold = DiagonalGradient(
    colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDeep],
    stops: [0, 0.45, 1],
  );

  static const navy = DiagonalGradient(
    colors: [AppColors.navyLight, AppColors.brandGradStart, AppColors.navyDeep],
    stops: [0, 0.6, 1],
  );

  static const silver = DiagonalGradient(
    colors: [
      AppColors.silverLight,
      AppColors.silver,
    ], // gradient/light/f1f5f9, gradient/tint/cbd5e1
  );

  static const bronze = DiagonalGradient(
    colors: [AppColors.bronzeLight, AppColors.bronze],
  );
}

/// Draws an SVG at its intrinsic size inside a [size] slot, letting stroke
/// overhang spill out the way the design's icon frames do.
class DetailSlotIcon extends StatelessWidget {
  const DetailSlotIcon(this.asset, {super.key, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: SvgPicture.asset(asset),
      ),
    );
  }
}
