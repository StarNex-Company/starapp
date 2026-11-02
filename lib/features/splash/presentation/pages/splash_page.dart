import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/shared/widgets/auth_buttons.dart';

/// Navy "S" logo of "Splash Screen 2" (Figma `50:141`), 88.77×78, #032886.
const _logoAsset = 'assets/vectors/auth_splash_logo.svg';
const _logoSize = Size(88.7714, 78);

/// Splash (Figma "Splash Screen 1" `45:428` → "Splash Screen 2" `50:136`).
///
/// Starts navy (#042C91) with a 5px lunar-white line through the middle and a
/// 17px lunar-white disc (Group 44, turned 180°). After 200ms the prototype
/// smart-animates for 1s (ease-out): the disc turns upright and grows to a
/// 1422px circle that floods the screen #F7F7F8, revealing the centred navy
/// "S" and the Loading Bar, while the line turns horizontal beneath it and
/// the navy deepens to #032886. Four seconds later it goes to onboarding.
///
/// [duration] is the whole time on screen before `context.go` to
/// [AppRoutes.onboarding] (default 5.2s = 0.2 hold + 1 reveal + 4 loading).
/// Shorter durations compress the hold and the reveal proportionally, so tests
/// can pass e.g. `Duration(milliseconds: 300)`.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.duration = defaultDuration});

  /// Prototype timing: 200ms hold, 1s reveal, 4s on the loading state.
  static const defaultDuration = Duration(milliseconds: 5200);

  /// Time on the splash before navigating to onboarding.
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _hold = Duration(milliseconds: 200);
  static const _reveal = Duration(milliseconds: 1000);

  late final AnimationController _controller;
  late final Animation<double> _progress;
  Timer? _holdTimer;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    final total = widget.duration;
    final intro = _hold + _reveal;
    // Squeeze the hold + reveal into short (test) durations.
    final k = total >= intro
        ? 1.0
        : total.inMicroseconds / intro.inMicroseconds;

    _controller = AnimationController(vsync: this, duration: _reveal * k);
    // Figma "Ease out" = cubic-bezier(0, 0, 0.58, 1) = Curves.easeOut.
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _holdTimer = Timer(_hold * k, () {
      if (mounted) _controller.forward();
    });
    _exitTimer = Timer(total, () {
      if (mounted) context.go(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _exitTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final centre = size.center(Offset.zero);
        // Half the diagonal: the circle must reach every corner.
        final reach = centre.distance;
        // 1422 in the design; grow further on screens it can't cover.
        final endDiameter = math.max(1422.0, reach * 2 + 2);
        final lineLength = math.max(1170.0, reach * 2 + 2);

        return AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final t = _progress.value;
            final diameter = lerpDouble(17, endDiameter, t)!;
            final lineWidth = lerpDouble(5, 6, t)!;
            final covered = diameter / 2 >= centre.dy;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value:
                  (covered
                          ? SystemUiOverlayStyle.dark
                          : SystemUiOverlayStyle.light)
                      .copyWith(statusBarColor: Colors.transparent),
              child: Scaffold(
                backgroundColor: Color.lerp(
                  AppColors.btnColor,
                  AppColors.brandBlue,
                  t,
                ),
                body: Stack(
                  children: [
                    // White line: vertical → horizontal, under the circle.
                    Positioned(
                      left: centre.dx - lineWidth / 2,
                      top: centre.dy - lineLength / 2,
                      width: lineWidth,
                      height: lineLength,
                      child: Transform.rotate(
                        angle: t * math.pi / 2,
                        child: const ColoredBox(color: AppColors.lunarWhite),
                      ),
                    ),

                    // Group 44: the lunar-white circle…
                    Positioned(
                      left: centre.dx - diameter / 2,
                      top: centre.dy - diameter / 2,
                      width: diameter,
                      height: diameter,
                      child: const DecoratedBox(
                        decoration: ShapeDecoration(
                          color: AppColors.lunarWhite,
                          shape: OvalBorder(),
                        ),
                      ),
                    ),

                    // …and its "S", scaling and turning upright with it.
                    Positioned.fill(
                      child: Center(
                        child: Transform.rotate(
                          angle: math.pi * (1 - t),
                          child: Transform.scale(
                            scale: diameter / endDiameter,
                            child: SvgPicture.asset(
                              _logoAsset,
                              width: _logoSize.width,
                              height: _logoSize.height,
                              semanticsLabel: 'Star App',
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Loading Bar (only on Splash Screen 2, fades in).
                    if (t > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: bottomInset + 31,
                        child: Opacity(
                          opacity: t,
                          child: const Center(child: AuthLoadingDots()),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
