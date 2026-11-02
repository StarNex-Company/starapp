// Palette and piece shapes of the design's confetti layer.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

const _palette = [
  Color(0xFFF5C451), // gold
  AppColors.goldDeep, // gold deep
  Color(0xFF7C5CFF), // violet
  Color(0xFF3BA7FF), // sky
  AppColors.success, // green
  Color(0xFFEC4899), // pink
  Colors.white,
];
const _pieceCount = 64;
const _seed = 2026;

const _burstDuration = Duration(milliseconds: 2000);
const _driftPeriod = Duration(seconds: 30);

/// Full-bleed confetti overlay. Pieces drop in from above the screen, land
/// in a scattered layout (the design's settled frame) and then keep drifting
/// down slowly in a seamless loop.
///
/// With [animate] off, or when the platform asks to reduce motion, the
/// settled layout is shown without movement.
class WinnersConfetti extends StatefulWidget {
  const WinnersConfetti({super.key, this.animate = true});

  final bool animate;

  @override
  State<WinnersConfetti> createState() => _WinnersConfettiState();
}

class _WinnersConfettiState extends State<WinnersConfetti>
    with TickerProviderStateMixin {
  static final _pieces = _generatePieces();

  late final AnimationController _burst;
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(vsync: this, duration: _burstDuration)
      ..addStatusListener(_onBurstStatus);
    _drift = AnimationController(vsync: this, duration: _driftPeriod);
    if (!widget.animate) _burst.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.animate) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _drift
        ..stop()
        ..value = 0;
      _burst.value = 1;
    } else if (_burst.isDismissed) {
      _burst.forward();
    } else if (_burst.isCompleted && !_drift.isAnimating) {
      _drift.repeat();
    }
  }

  void _onBurstStatus(AnimationStatus status) {
    if (status.isCompleted &&
        widget.animate &&
        !MediaQuery.disableAnimationsOf(context)) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _burst.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, burst: _burst, drift: _drift),
        ),
      ),
    );
  }
}

enum _Shape { strip, dot, chip }

class _Piece {
  const _Piece({
    required this.shape,
    required this.color,
    required this.x,
    required this.y,
    required this.dropFrom,
    required this.angle,
    required this.opacity,
    required this.delay,
    required this.laps,
    required this.spins,
    required this.sway,
    required this.swayCycles,
    required this.swayPhase,
  });

  final _Shape shape;
  final Color color;

  /// Settled position as a fraction of the overlay size.
  final double x;
  final double y;

  /// Start height above the top edge, in px.
  final double dropFrom;

  /// Settled rotation, radians.
  final double angle;

  /// Settled opacity (pieces are fully opaque while dropping in).
  final double opacity;

  /// Burst start offset, fraction of the burst.
  final double delay;

  /// Drift: screen heights travelled, full turns and sway cycles per loop.
  final int laps;
  final int spins;
  final double sway;
  final int swayCycles;
  final double swayPhase;
}

List<_Piece> _generatePieces() {
  final random = math.Random(_seed);
  double between(double a, double b) => a + random.nextDouble() * (b - a);

  return List.generate(_pieceCount, (i) {
    // Stratify horizontally so the burst covers the whole width.
    final column = (i * 7) % 16;
    return _Piece(
      shape: _Shape.values[i % 3],
      color: _palette[i % _palette.length],
      x: (column + random.nextDouble()) / 16,
      y: between(0.04, 0.97),
      dropFrom: between(60, 460),
      angle: between(-math.pi, math.pi),
      opacity: between(0.55, 1),
      delay: between(0, 0.25),
      laps: 1 + random.nextInt(2),
      spins: (random.nextBool() ? 1 : -1) * (1 + random.nextInt(4)),
      sway: between(4, 14),
      swayCycles: 3 + random.nextInt(4),
      swayPhase: between(0, 2 * math.pi),
    );
  }, growable: false);
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, {required this.burst, required this.drift})
    : super(repaint: Listenable.merge([burst, drift]));

  final List<_Piece> pieces;
  final Animation<double> burst;
  final Animation<double> drift;

  static const _margin = 24.0;
  static const _dropTurn = 140 * math.pi / 180;
  static final _strip = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset.zero, width: 7, height: 14),
    const Radius.circular(2),
  );
  static final _chip = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset.zero, width: 10, height: 5),
    const Radius.circular(1),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final t = burst.value;
    final d = drift.value;
    final wrap = size.height + 2 * _margin;
    final paint = Paint()..isAntiAlias = true;

    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      final fall = Curves.easeOutCubic.transform(local);

      var x = p.x * size.width;
      var y = _lerp(-p.dropFrom, p.y * size.height, fall);
      var angle = p.angle - _dropTurn * (1 - fall);
      final opacity = _lerp(1, p.opacity, fall);

      if (d > 0) {
        y = (y + p.laps * wrap * d + _margin) % wrap - _margin;
        x +=
            p.sway *
            (math.sin(2 * math.pi * p.swayCycles * d + p.swayPhase) -
                math.sin(p.swayPhase));
        angle += 2 * math.pi * p.spins * d;
      }
      if (y < -_margin) continue;

      paint.color = p.color.withValues(alpha: opacity);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(angle);
      switch (p.shape) {
        case _Shape.strip:
          canvas.drawRRect(_strip, paint);
        case _Shape.dot:
          canvas.drawCircle(Offset.zero, 4, paint);
        case _Shape.chip:
          canvas.drawRRect(_chip, paint);
      }
      canvas.restore();
    }
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.pieces != pieces ||
      oldDelegate.burst != burst ||
      oldDelegate.drift != drift;
}
