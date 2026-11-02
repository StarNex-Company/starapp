import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class _Assets {
  static const _dir = 'assets/vectors/challenges';

  static const halo = '$_dir/tier_halo.svg';
  static const star = '$_dir/tier_star.svg';

  /// Each sparkle keeps its own file: its 1px outline and design opacity
  /// are baked in.
  static String sparkle(int index) =>
      '$_dir/tier_sparkle_${index.toString().padLeft(2, '0')}.svg';
}

class _Sparkle {
  const _Sparkle(this.left, this.top, this.size);

  /// Position inside the 345×200 hero box.
  final double left;
  final double top;
  final double size;
}

// The design's sparkle field, relative to the hero box (index = asset).
const _sparkles = [
  _Sparkle(118.96, 36.51, 11.365),
  _Sparkle(25.80, 229.32, 18.013),
  _Sparkle(271.70, 95.15, 9.451),
  _Sparkle(177.42, 206.54, 13.030),
  _Sparkle(229.96, 133.78, 13.494),
  _Sparkle(266.51, 24.79, 9.775),
  _Sparkle(197.65, 29.02, 12.253),
  _Sparkle(278.36, 232.55, 13.061),
  _Sparkle(122.81, 246.66, 21.542),
  _Sparkle(296.83, 66.97, 8.446),
  _Sparkle(258.78, 295.39, 11.958),
  _Sparkle(157.73, 192.01, 18.157),
  _Sparkle(84.84, 199.24, 15.991),
  _Sparkle(261.63, 55.21, 14.376),
];

/// Width of the hero box the emblem and sparkles are laid out in.
const tierEmblemBoxWidth = 345.0;

/// Glowing star emblem with the tier number, surrounded by twinkling
/// sparkles.
///
/// [reveal] runs 0 → 1 once: the star spins and grows out of the halo and
/// the sparkles pop in. [twinkle] loops 0 → 1; at 0 every sparkle shows its
/// design opacity. Sparkles overflow the box downward, behind whatever is
/// laid out below it.
class TierEmblem extends StatelessWidget {
  const TierEmblem({
    super.key,
    required this.tier,
    required this.reveal,
    required this.twinkle,
  });

  final int tier;
  final Animation<double> reveal;
  final Animation<double> twinkle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tierEmblemBoxWidth,
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final (i, sparkle) in _sparkles.indexed)
            Positioned(
              left: sparkle.left,
              top: sparkle.top,
              child: _TwinklingSparkle(
                sparkle: sparkle,
                index: i,
                reveal: reveal,
                twinkle: twinkle,
              ),
            ),
          Positioned(
            left: (tierEmblemBoxWidth - 200) / 2,
            top: 0,
            child: _Emblem(tier: tier, reveal: reveal),
          ),
        ],
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({required this.tier, required this.reveal});

  final int tier;
  final Animation<double> reveal;

  // Centre of the star's 150px box inside the 200px emblem.
  static const _starCenter = Offset(100, 106);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(_Assets.halo, width: 200, height: 200),
          AnimatedBuilder(
            animation: reveal,
            builder: (context, child) {
              final t = Curves.easeOutBack.transform(
                _interval(reveal.value, 0, 0.55),
              );
              final fade = Curves.easeOut.transform(
                _interval(reveal.value, 0, 0.4),
              );
              // Reveal frame: a small star at 20% opacity, turned 60°, just
              // left of centre (the design's 40px star has rounder corners,
              // so it reads smaller than a scaled 40px copy).
              final scale = _lerp(0.22, 1, t);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The SVG's canvas includes room for its drop shadow.
                  Positioned(
                    left: 0.15,
                    top: 3.6,
                    child: Opacity(
                      opacity: _lerp(0.2, 1, fade),
                      child: Transform(
                        alignment: Alignment.topLeft,
                        transform: Matrix4.identity()
                          ..translateByDouble(
                            _starCenter.dx - 0.15 + _lerp(-27.3, 0, t),
                            _starCenter.dy - 3.6 + _lerp(7.3, 0, t),
                            0,
                            1,
                          )
                          ..rotateZ(_lerp(math.pi / 3, 0, t))
                          ..scaleByDouble(scale, scale, 1, 1)
                          ..translateByDouble(
                            -(_starCenter.dx - 0.15),
                            -(_starCenter.dy - 3.6),
                            0,
                            1,
                          ),
                        child: child,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 85.5,
                    child: Transform.scale(
                      scale: _lerp(12 / 44, 1, t),
                      child: Text(
                        '$tier',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 44,
                          height: 1.21,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: const _Star(),
          ),
        ],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star();

  static const _glow = Color(0x298B5CF6); // 8b5cf6 @ 16%

  @override
  Widget build(BuildContext context) {
    final star = SvgPicture.asset(
      _Assets.star,
      width: 199.701,
      height: 194.823,
    );
    // flutter_svg skips the SVG's <filter>, so its soft violet drop shadow
    // is drawn here.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(_glow, BlendMode.srcIn),
            child: star,
          ),
        ),
        star,
      ],
    );
  }
}

class _TwinklingSparkle extends StatelessWidget {
  const _TwinklingSparkle({
    required this.sparkle,
    required this.index,
    required this.reveal,
    required this.twinkle,
  });

  final _Sparkle sparkle;
  final int index;
  final Animation<double> reveal;
  final Animation<double> twinkle;

  // Each twinkle dims a sparkle to 35% (and shrinks it a little) over 40%
  // of its cycle; between twinkles it rests at its design opacity.
  static const _depth = 0.65;
  static const _dipWidth = 0.4;

  @override
  Widget build(BuildContext context) {
    final cycles = 1 + index % 3;
    final offset = (index * 0.37) % (1 - _dipWidth);
    final start = 0.3 + index * 0.03;

    return AnimatedBuilder(
      animation: Listenable.merge([reveal, twinkle]),
      builder: (context, child) {
        final pop = _interval(reveal.value, start, start + 0.3);
        final x = (cycles * twinkle.value - offset) % 1.0;
        final dip = x < _dipWidth
            ? math.pow(math.sin(math.pi * x / _dipWidth), 2)
            : 0.0;
        return Opacity(
          opacity: (Curves.easeOut.transform(pop) * (1 - _depth * dip)).clamp(
            0.0,
            1.0,
          ),
          child: Transform.scale(
            scale: Curves.easeOutBack.transform(pop) * (1 - 0.15 * dip),
            child: child,
          ),
        );
      },
      child: SvgPicture.asset(
        _Assets.sparkle(index),
        width: sparkle.size,
        height: sparkle.size,
      ),
    );
  }
}

double _interval(double t, double begin, double end) =>
    ((t - begin) / (end - begin)).clamp(0.0, 1.0);

double _lerp(double a, double b, double t) => a + (b - a) * t;
