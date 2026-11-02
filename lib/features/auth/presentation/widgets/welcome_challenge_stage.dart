import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/auth/presentation/widgets/welcome_challenge_glass_chip.dart';
import 'package:starapp/features/auth/presentation/widgets/welcome_challenge_style.dart';

/// The animated hero of the Welcome Challenge screen: glow, orbits, planets,
/// sparkles, the hero star and the three reward chips.
///
/// Laid out in the Figma frame's coordinates, cropped to the band between
/// the status bar (y 62) and the card (y 422): [designSize] is 393×360 and
/// the orbits are centred at (196.5, 188). Content (the glow, the star's
/// halo) spills outside the box and isn't clipped.
///
/// Two progress values drive every layer, matching the prototype's smart
/// animate between the frames' matching layers:
/// * [reveal] 0 → 1: "1 Intro" (everything collapsed in the centre and
///   transparent) → "2 Revealed". May overshoot 1 (spring).
/// * [idle] 0 → 1: "2 Revealed" → "3 Idle" (planets move along their orbits,
///   the chips float, the star tilts 14°, the glow swells and dims, three
///   sparkles fade).
class WelcomeChallengeStage extends StatelessWidget {
  const WelcomeChallengeStage({
    super.key,
    required this.reveal,
    required this.idle,
  });

  final Animation<double> reveal;
  final Animation<double> idle;

  static const designSize = Size(393, 360);

  /// Frame y of the stage's top edge (the status bar's height).
  static const designTop = 62.0;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: Listenable.merge([reveal, idle]),
        builder: (context, _) =>
            _StageFrame(reveal: reveal.value, idle: idle.value),
      ),
    );
  }
}

// ── Keyframes (Figma frame coordinates) ─────────────────────────────────────

const _center = Offset(196.5, 250);

double _lerp(double a, double b, double t) => lerpDouble(a, b, t)!;

/// Value at Intro (i) → Revealed (r) → Idle (d).
double _key(double i, double r, double d, double reveal, double idle) =>
    _lerp(_lerp(i, r, reveal), d, idle);

double _opacity(double i, double r, double d, double reveal, double idle) =>
    _key(i, r, d, reveal, idle).clamp(0.0, 1.0);

class _Planet {
  const _Planet(this.diameter, this.color, this.revealed, this.idle);

  final double diameter;
  final Color color;

  /// Centres. At Intro every planet sits on [_center], transparent.
  final Offset revealed;
  final Offset idle;

  /// Revealed ↔ Idle moves along the orbit (polar interpolation around
  /// [_center], shortest way round) rather than Figma's straight line, so the
  /// planets visibly circle; the end points are exact.
  Offset at(double reveal, double idleT) {
    final from = revealed - _center;
    final to = idle - _center;
    var sweep = to.direction - from.direction;
    if (sweep > math.pi) sweep -= 2 * math.pi;
    if (sweep < -math.pi) sweep += 2 * math.pi;
    final orbiting =
        _center +
        Offset.fromDirection(
          from.direction + sweep * idleT,
          _lerp(from.distance, to.distance, idleT),
        );
    return Offset.lerp(_center, orbiting, reveal)!;
  }
}

const _planets = [
  _Planet(
    8,
    AppColors.gold,
    Offset(306.5, 210),
    Offset(236.5, 146),
  ), // Planet 1
  _Planet(6, Colors.white, Offset(56.5, 290), Offset(76.5, 180)), // Planet 2
  _Planet(
    10,
    WelcomeChallengeColors.planetBlue,
    Offset(136.5, 110),
    Offset(266.5, 122),
  ), // Planet 3
  _Planet(
    5,
    AppColors.gold,
    Offset(256.5, 385),
    Offset(116.5, 370),
  ), // Planet 4
];

class _Sparkle {
  const _Sparkle(
    this.fontSize,
    this.alpha,
    this.intro,
    this.revealed,
    this.idleOpacity,
  );

  /// The "✦" text layer: font size, fill alpha, text-box top-left at Intro
  /// and Revealed (= Idle), and the layer opacity at Idle.
  final double fontSize;
  final double alpha;
  final Offset intro;
  final Offset revealed;
  final double idleOpacity;

  // Glyph box inside the text box, per px of font size (from the export).
  static const _dx = 0.051;
  static const _dy = 0.274;
  static const _glyph = 0.768;
}

const _sparkles = [
  _Sparkle(22, 0.9, Offset(185, 236.5), Offset(70, 120), 0.3), // Sparkle 1
  _Sparkle(14, 0.7, Offset(189, 241.5), Offset(320, 150), 1), // Sparkle 2
  _Sparkle(18, 0.8, Offset(187, 239), Offset(330, 330), 0.35), // Sparkle 3
  _Sparkle(12, 0.6, Offset(190, 242.5), Offset(58, 350), 1), // Sparkle 4
  _Sparkle(10, 0.7, Offset(191, 244), Offset(250, 90), 0.25), // Sparkle 5
];

class _Chip {
  const _Chip(
    this.label,
    this.intro,
    this.revealed,
    this.idle, {
    this.gold = false,
    this.sparkle = false,
  });

  final String label;

  /// Top-left at Intro (centred on the orbits, transparent), Revealed, Idle.
  final Offset intro;
  final Offset revealed;
  final Offset idle;
  final bool gold;
  final bool sparkle;
}

const _chips = [
  _Chip(
    '+50 ★',
    Offset(163.5, 234.5),
    Offset(258, 178),
    Offset(258, 172),
    gold: true,
  ),
  _Chip('🎤 Singing', Offset(153.5, 234.5), Offset(40, 262), Offset(40, 268)),
  _Chip(
    'Shooting Star',
    Offset(135.5, 234.5),
    Offset(236, 322),
    Offset(236, 317),
    sparkle: true,
  ),
];

/// Hero Star frame: 118 box at (137.5, 191); 0.2× at Intro; rotated 14°
/// clockwise about its top-left corner at Idle (as Figma does).
const _starOrigin = Offset(137.5, 191);
const _starSize = 118.0;
const _starTilt = 14 * math.pi / 180;

// ── Frame ───────────────────────────────────────────────────────────────────

class _StageFrame extends StatelessWidget {
  const _StageFrame({required this.reveal, required this.idle});

  final double reveal;
  final double idle;

  @override
  Widget build(BuildContext context) {
    const top = WelcomeChallengeStage.designTop;
    return SizedBox.fromSize(
      size: WelcomeChallengeStage.designSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _OrbitsPainter(reveal: reveal, idle: idle),
            ),
          ),
          for (final s in _sparkles) _sparkle(s, top),
          _heroStar(top),
          for (final c in _chips) _chip(c, top),
        ],
      ),
    );
  }

  Widget _sparkle(_Sparkle s, double top) {
    final opacity = _opacity(0, 1, s.idleOpacity, reveal, idle);
    final box = Offset.lerp(s.intro, s.revealed, reveal)!;
    final glyph = s.fontSize * _Sparkle._glyph;
    return Positioned(
      left: box.dx + s.fontSize * _Sparkle._dx,
      top: box.dy - top + s.fontSize * _Sparkle._dy,
      width: glyph,
      height: glyph,
      child: opacity <= 0
          ? const SizedBox.shrink()
          : SvgPicture.asset(
              WelcomeChallengeAssets.sparkle,
              width: glyph,
              height: glyph,
              colorFilter: ColorFilter.mode(
                AppColors.gold.withValues(alpha: s.alpha * opacity),
                BlendMode.srcIn,
              ),
            ),
    );
  }

  Widget _heroStar(double top) {
    final opacity = _opacity(0, 1, 1, reveal, idle);
    final scale = math.max(_key(0.2, 1, 1, reveal, idle), 0.0);
    const half = _starSize / 2;
    final transform = Matrix4.rotationZ(_starTilt * idle)
      ..translateByDouble(half, half, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-half, -half, 0, 1);
    return Positioned(
      left: _starOrigin.dx,
      top: _starOrigin.dy - top,
      width: _starSize,
      height: _starSize,
      child: Opacity(
        opacity: opacity,
        child: Transform(
          transform: transform,
          child: const RepaintBoundary(child: _HeroStar()),
        ),
      ),
    );
  }

  Widget _chip(_Chip c, double top) {
    final opacity = _opacity(0, 1, 1, reveal, idle);
    final at = Offset.lerp(
      Offset.lerp(c.intro, c.revealed, reveal),
      c.idle,
      idle,
    )!;
    return Positioned(
      left: at.dx,
      top: at.dy - top,
      child: Opacity(
        opacity: opacity,
        child: WelcomeChallengeGlassChip(
          label: c.label,
          fill: c.gold ? AppColors.gold : WelcomeChallengeColors.glassFill,
          foreground: c.gold ? WelcomeChallengeColors.goldInk : Colors.white,
          trailingSparkle: c.sparkle,
        ),
      ),
    );
  }
}

/// The star asset plus its glow (Figma drop shadow: 36 blur → σ 18,
/// #F5C452 @ 75%), drawn in the 118 frame with the file's 30.1px margin.
class _HeroStar extends StatelessWidget {
  const _HeroStar();

  static const _glow = Color(0xBFF5C452);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -30.1,
          top: -30.1,
          width: 178.2,
          height: 173.382,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: SvgPicture.asset(
                  WelcomeChallengeAssets.heroStar,
                  width: 178.2,
                  height: 173.382,
                  colorFilter: const ColorFilter.mode(_glow, BlendMode.srcIn),
                ),
              ),
              SvgPicture.asset(
                WelcomeChallengeAssets.heroStar,
                width: 178.2,
                height: 173.382,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Glow, orbits and planets (ellipse layers with blur effects, painted
/// directly so the effects render and strokes stay 1.2px while they grow).
class _OrbitsPainter extends CustomPainter {
  const _OrbitsPainter({required this.reveal, required this.idle});

  final double reveal;
  final double idle;

  @override
  void paint(Canvas canvas, Size size) {
    final c = _center.translate(0, -WelcomeChallengeStage.designTop);
    Offset local(Offset frame) =>
        frame.translate(0, -WelcomeChallengeStage.designTop);

    // Glow: #F5C451 @ 35%, layer blur 90 (σ 45). 360 → 400 and 100% → 75%
    // at Idle.
    final glowOpacity = _opacity(0, 1, 0.75, reveal, idle);
    if (glowOpacity > 0) {
      canvas.drawCircle(
        c,
        _key(360, 360, 400, reveal, idle) / 2,
        Paint()
          ..color = AppColors.gold.withValues(alpha: 0.35 * glowOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45),
      );
    }

    // Orbits: 1.2 inside strokes, white. Orbit 3 is dashed 4/8.
    final orbitOpacity = _opacity(0, 1, 1, reveal, idle);
    if (orbitOpacity > 0) {
      final grow = math.max(reveal, 0.0);
      _orbit(
        canvas,
        c,
        _lerp(90, 300, grow),
        0.132 * orbitOpacity,
        dashed: true,
      );
      _orbit(canvas, c, _lerp(66, 220, grow), 0.22 * orbitOpacity);
      _orbit(canvas, c, _lerp(45, 150, grow), 0.352 * orbitOpacity);
    }

    // Planets: drop shadow 10 blur (σ 5) in their own colour @ 80%.
    final planetOpacity = _opacity(0, 1, 1, reveal, idle);
    if (planetOpacity > 0) {
      for (final p in _planets) {
        final at = local(p.at(reveal, idle));
        final r = p.diameter / 2;
        canvas
          ..drawCircle(
            at,
            r,
            Paint()
              ..color = p.color.withValues(alpha: 0.8 * planetOpacity)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
          )
          ..drawCircle(
            at,
            r,
            Paint()..color = p.color.withValues(alpha: planetOpacity),
          );
      }
    }
  }

  void _orbit(
    Canvas canvas,
    Offset c,
    double diameter,
    double alpha, {
    bool dashed = false,
  }) {
    const stroke = 1.2;
    final radius = diameter / 2 - stroke / 2;
    if (radius <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: alpha);
    if (!dashed) {
      canvas.drawCircle(c, radius, paint);
      return;
    }
    final rect = Rect.fromCircle(center: c, radius: radius);
    const dash = 4.0;
    const period = 12.0; // 4 on, 8 off
    final circumference = 2 * math.pi * radius;
    for (var d = 0.0; d < circumference; d += period) {
      final length = math.min(dash, circumference - d);
      canvas.drawArc(rect, d / radius, length / radius, false, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitsPainter old) =>
      old.reveal != reveal || old.idle != idle;
}
