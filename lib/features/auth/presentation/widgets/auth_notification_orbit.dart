import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Animated illustration of the notifications-permission screen (Figma
/// "Notif rotate" `703:1541`, 302×300).
///
/// Three #001F6E @ 27% rings around an 87px navy bell with a red alert dot.
/// Three bubbles (like, heart, money) sit on the middle ring; three bubbles
/// (comment, share, gift) and three dots travel round the outer ring. The
/// component's six variants are shown in turn: each holds for
/// [hold], then the outer items glide counter-clockwise along the ring to the
/// next variant's positions over [move]. With `MediaQuery.disableAnimations`
/// it stays on the first variant.
class AuthNotificationOrbit extends StatefulWidget {
  const AuthNotificationOrbit({
    super.key,
    this.hold = const Duration(milliseconds: 3200),
    this.move = const Duration(milliseconds: 800),
  });

  /// Time each variant stays still.
  final Duration hold;

  /// Time to glide to the next variant.
  final Duration move;

  /// Design size.
  static const Size size = Size(302, 300);

  @override
  State<AuthNotificationOrbit> createState() => _AuthNotificationOrbitState();
}

// Assets (exported from the component).
const _orbit = 'assets/vectors/auth_notif_orbit.svg'; // 291×291 rings
const _bell = 'assets/vectors/auth_notif_bell.svg'; // ion:notifcations 47
const _comment = 'assets/vectors/auth_notif_comment.svg'; // 15×14.86 in 18
const _like = 'assets/vectors/auth_notif_like.svg';
const _heart = 'assets/vectors/auth_notif_heart.svg';
const _money = 'assets/vectors/auth_notif_money.svg'; // 16
const _share = 'assets/vectors/auth_notif_share.svg';
const _gift = 'assets/vectors/auth_notif_gift.svg'; // basil:bag-solid

const Color _bubbleColor = Color(0xFFB4BDD3);
const Color _alertColor = Color(0xFFF90000);

/// Centre of the rings in the 302×300 box.
const Offset _center = Offset(156.5, 145.5);

const int _variants = 6;

/// Top-left of each outer-ring item in variants 1–6 (from the component).
const List<_Orbiter> _orbiters = [
  _Orbiter(_comment, 27, [
    Offset(156, 273), Offset(273, 190), Offset(235, 23), //
    Offset(95, 0), Offset(1, 111), Offset(45, 237),
  ]),
  _Orbiter(null, 17, [
    Offset(83, 9), Offset(5, 134), Offset(49, 242), //
    Offset(191, 274), Offset(277, 199), Offset(256, 43),
  ]),
  _Orbiter(null, 17, [
    Offset(279, 195), Offset(250, 36), Offset(90, 6), //
    Offset(6, 116), Offset(49, 242), Offset(171, 278),
  ]),
  _Orbiter(null, 17, [
    Offset(46, 238), Offset(187, 274), Offset(280, 191), //
    Offset(253, 36), Offset(97, 4), Offset(5, 118),
  ]),
  _Orbiter(_share, 27, [
    Offset(0, 138), Offset(52, 242), Offset(173, 269), //
    Offset(277, 180), Offset(246, 31), Offset(91, 0),
  ]),
  _Orbiter(_gift, 27, [
    Offset(238, 24), Offset(99, -5), Offset(2, 108), //
    Offset(50, 241), Offset(156, 273), Offset(269, 198),
  ]),
];

class _Orbiter {
  const _Orbiter(this.icon, this.size, this.positions);

  /// `null` for a plain dot.
  final String? icon;
  final double size;
  final List<Offset> positions;

  /// Top-left at variant [from] + [t] of the way to the next one, moving
  /// counter-clockwise along the ring.
  Offset at(int from, double t) {
    final half = Offset(size / 2, size / 2);
    final a = positions[from % _variants] + half - _center;
    if (t <= 0) return a + _center - half;
    final b = positions[(from + 1) % _variants] + half - _center;
    var delta = b.direction - a.direction;
    // Screen y points down: counter-clockwise = decreasing angle.
    while (delta > 0) {
      delta -= 2 * math.pi;
    }
    while (delta <= -2 * math.pi) {
      delta += 2 * math.pi;
    }
    final angle = a.direction + delta * t;
    final radius = a.distance + (b.distance - a.distance) * t;
    return Offset.fromDirection(angle, radius) + _center - half;
  }
}

class _AuthNotificationOrbitState extends State<AuthNotificationOrbit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration get _step => widget.hold + widget.move;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _step * _variants);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AuthNotificationOrbit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hold != widget.hold || oldWidget.move != widget.move) {
      _controller.duration = _step * _variants;
      if (_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final holdShare = widget.hold.inMicroseconds / _step.inMicroseconds;
    return Semantics(
      label: 'Notifications illustration',
      image: true,
      excludeSemantics: true,
      child: SizedBox.fromSize(
        size: AuthNotificationOrbit.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 11,
              top: 0,
              child: SvgPicture.asset(_orbit, width: 291, height: 291),
            ),
            // Middle ring (static).
            const Positioned(left: 72, top: 206, child: _Bubble(icon: _like)),
            const Positioned(left: 97, top: 38, child: _Bubble(icon: _heart)),
            const Positioned(
              left: 232,
              top: 185,
              child: _Bubble(icon: _money, iconSize: 16),
            ),
            // Outer ring (animated).
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final v = _controller.value * _variants;
                final index = v.floor() % _variants;
                final phase = v - v.floor();
                final t = phase <= holdShare
                    ? 0.0
                    : Curves.easeInOut.transform(
                        (phase - holdShare) / (1 - holdShare),
                      );
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final o in _orbiters)
                      Positioned.fromRect(
                        rect: o.at(index, t) & Size.square(o.size),
                        child: o.icon == null
                            ? const _Dot()
                            : _Bubble(icon: o.icon!),
                      ),
                  ],
                );
              },
            ),
            // Bell.
            Positioned(
              left: 113,
              top: 102,
              child: Container(
                width: 87,
                height: 87,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.brandNavy,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(_bell, width: 47, height: 47),
              ),
            ),
            // Alert dot (Figma "alert", over the bell).
            Positioned(
              left: 160,
              top: 129,
              child: Container(
                width: 13,
                height: 13,
                decoration: const BoxDecoration(
                  color: _alertColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 27px #B4BDD3 circle with an 18px (or [iconSize]) #F7F7F8 icon.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.icon, this.iconSize = 18});

  final String icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    // mingcute:comment-fill: a 15×14.86 glyph at (1.5, 3) in its 18 box.
    final Widget glyph = icon == _comment
        ? SizedBox.square(
            dimension: 18,
            child: Padding(
              padding: const EdgeInsets.only(left: 1.5, top: 3),
              child: Align(
                alignment: Alignment.topLeft,
                child: SvgPicture.asset(icon, width: 15, height: 14.8605),
              ),
            ),
          )
        : SvgPicture.asset(icon, width: iconSize, height: iconSize);
    return Container(
      width: 27,
      height: 27,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _bubbleColor,
        shape: BoxShape.circle,
      ),
      child: glyph,
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 17,
      height: 17,
      decoration: const BoxDecoration(
        color: _bubbleColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
