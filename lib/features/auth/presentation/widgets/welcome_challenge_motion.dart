import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// Timing of the Welcome Challenge sequence, read from the Figma prototype:
///
/// 1. Intro → Revealed: after [introDelay] (0.2s), smart-animate over
///    [reveal] (0.9s) with the "Gentle" spring ([WelcomeChallengeGentleCurve]).
/// 2. Revealed → Idle: after [revealedHold] (1.2s), smart-animate over
///    [breathe] (1.6s), ease in and out.
/// 3. Idle → Revealed: after [idleHold] (0.1s), the same [breathe] back, then
///    the Revealed ↔ Idle loop repeats.
///
/// Tests can pass shorter durations.
class WelcomeChallengeTimings {
  const WelcomeChallengeTimings({
    this.introDelay = const Duration(milliseconds: 200),
    this.reveal = const Duration(milliseconds: 900),
    this.revealedHold = const Duration(milliseconds: 1200),
    this.breathe = const Duration(milliseconds: 1600),
    this.idleHold = const Duration(milliseconds: 100),
  });

  final Duration introDelay;
  final Duration reveal;
  final Duration revealedHold;
  final Duration breathe;
  final Duration idleHold;

  /// Intro delay + reveal.
  Duration get intro => introDelay + reveal;

  /// One Revealed → Idle → Revealed loop, starting with [revealedHold].
  Duration get idleCycle => revealedHold + breathe + idleHold + breathe;
}

/// Figma's "Gentle" spring (mass 1, stiffness 100, damping 15) as a curve over
/// the prototype's 0.9s: it overshoots by ~3% and settles by the end.
class WelcomeChallengeGentleCurve extends Curve {
  const WelcomeChallengeGentleCurve();

  static const double _seconds = 0.9;
  static const double _omega = 10; // sqrt(stiffness / mass)
  static const double _zeta = 0.75; // damping / (2 * sqrt(stiffness * mass))

  @override
  double transformInternal(double t) {
    final x = t * _seconds;
    final damped = _omega * math.sqrt(1 - _zeta * _zeta);
    final envelope = math.exp(-_zeta * _omega * x);
    return 1 -
        envelope *
            (math.cos(damped * x) +
                _zeta * _omega / damped * math.sin(damped * x));
  }
}

/// Builds the 0 → 1 "breath" of the idle loop (0 = Revealed, 1 = Idle) on a
/// controller that repeats over [WelcomeChallengeTimings.idleCycle].
Animation<double> welcomeChallengeBreath(
  Animation<double> cycle,
  WelcomeChallengeTimings timings,
) {
  double ms(Duration d) => math.max(d.inMicroseconds / 1000, 0.001);
  return TweenSequence<double>([
    TweenSequenceItem(
      tween: ConstantTween<double>(0),
      weight: ms(timings.revealedHold),
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: ms(timings.breathe),
    ),
    TweenSequenceItem(
      tween: ConstantTween<double>(1),
      weight: ms(timings.idleHold),
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: ms(timings.breathe),
    ),
  ]).animate(cycle);
}

/// Controller value of the idle cycle at the middle of the Idle hold (the
/// settled frame shown when motion is off).
double welcomeChallengeIdleRestValue(WelcomeChallengeTimings timings) {
  final total = timings.idleCycle.inMicroseconds;
  if (total <= 0) return 0.5;
  final rest = timings.revealedHold + timings.breathe;
  return (rest.inMicroseconds + timings.idleHold.inMicroseconds / 2) / total;
}
