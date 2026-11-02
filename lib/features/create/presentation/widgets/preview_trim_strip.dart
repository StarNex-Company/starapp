import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Filmstrip with the trimmed range outlined in gold and a white playhead.
/// [start], [end] and [playhead] are fractions (0–1) of the clip length.
class PreviewTrimStrip extends StatelessWidget {
  const PreviewTrimStrip({
    super.key,
    required this.frames,
    required this.start,
    required this.end,
    required this.playhead,
  });

  /// Frame images, laid out edge to edge.
  final List<String> frames;
  final double start;
  final double end;
  final double playhead;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LayoutBuilder(
          builder: (context, box) {
            final width = box.maxWidth;
            final left = width * start;
            final right = width * (1 - end);
            return Stack(
              children: [
                Row(
                  children: [
                    for (final frame in frames)
                      Expanded(child: StarImage(frame, height: 56)),
                  ],
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: left,
                  child: const ColoredBox(color: AppColors.scrim),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: right,
                  child: const ColoredBox(color: AppColors.scrim),
                ),
                Positioned(
                  left: left,
                  right: right,
                  top: 0,
                  bottom: 0,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.fromBorderSide(
                        BorderSide(color: AppColors.gold, width: 3),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                Positioned(
                  left: left,
                  top: 0,
                  bottom: 0,
                  width: 10,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: right,
                  top: 0,
                  bottom: 0,
                  width: 10,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: width * playhead,
                  top: 0,
                  bottom: 0,
                  width: 3,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
