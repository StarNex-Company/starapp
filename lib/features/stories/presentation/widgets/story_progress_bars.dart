import 'package:flutter/material.dart';

/// Segmented progress at the top of a story: one 3px bar per story, filled
/// for those already seen and partially for the current one.
class StoryProgressBars extends StatelessWidget {
  const StoryProgressBars({
    super.key,
    required this.count,
    required this.current,
    required this.progress,
    this.gap = 4,
  });

  final int count;
  final int current;

  /// 0–1 progress of the current story.
  final Animation<double> progress;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: Row(
        spacing: gap,
        children: [
          for (var i = 0; i < count; i++)
            Expanded(
              child: _Segment(
                fill: i < current
                    ? const AlwaysStoppedAnimation(1)
                    : i == current
                    ? progress
                    : const AlwaysStoppedAnimation(0),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.fill});

  final Animation<double> fill;

  static const _radius = BorderRadius.all(Radius.circular(2));

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0x66FFFFFF),
        borderRadius: _radius,
      ),
      child: AnimatedBuilder(
        animation: fill,
        builder: (context, _) => Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fill.value.clamp(0, 1),
            heightFactor: 1,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _radius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
