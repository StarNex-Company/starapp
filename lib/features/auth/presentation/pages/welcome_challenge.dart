import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';
import 'package:starapp/features/auth/presentation/widgets/welcome_challenge_card.dart';
import 'package:starapp/features/auth/presentation/widgets/welcome_challenge_glass_chip.dart';
import 'package:starapp/features/auth/presentation/widgets/welcome_challenge_motion.dart';
import 'package:starapp/features/auth/presentation/widgets/welcome_challenge_stage.dart';
import 'package:starapp/features/auth/presentation/widgets/welcome_challenge_style.dart';

/// Last step of registration (Figma "Welcome Challenge — 1 Intro / 2 Revealed
/// / 3 Idle"): on the blue gradient the orbits, planets, sparkles, hero star
/// and reward chips burst out of the centre while the white card springs up,
/// then the stage gently breathes between the Revealed and Idle frames.
///
/// * "Start My Journey" (and the challenge tile) → Home, with the Create
///   camera pushed on top so Back from the camera lands on Home.
/// * "Skip for now" → notifications permission.
/// * The language chip → Language selection.
///
/// When [animate] is false, or the platform asks to reduce motion, the
/// settled Idle frame is shown without motion.
class WelcomeChallengeScreen extends StatefulWidget {
  const WelcomeChallengeScreen({
    super.key,
    this.animate = true,
    this.firstName = 'Emmanuel',
    this.timings = const WelcomeChallengeTimings(),
  });

  final bool animate;

  /// Shown in "Welcome to the stage, {firstName} ✨". Defaults to the mock
  /// user used by Home until registration keeps the profile in state.
  final String firstName;

  /// Durations of the sequence (the prototype's by default).
  final WelcomeChallengeTimings timings;

  @override
  State<WelcomeChallengeScreen> createState() => _WelcomeChallengeScreenState();
}

class _WelcomeChallengeScreenState extends State<WelcomeChallengeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _loop;
  late final CurvedAnimation _reveal;
  late final Animation<double> _idle;
  bool? _still;

  @override
  void initState() {
    super.initState();
    final timings = widget.timings;
    _intro = AnimationController(vsync: this, duration: timings.intro)
      ..addStatusListener(_onIntroStatus);
    _loop = AnimationController(vsync: this, duration: timings.idleCycle);
    final introMs = timings.intro.inMicroseconds;
    final start = introMs <= 0
        ? 0.0
        : timings.introDelay.inMicroseconds / introMs;
    _reveal = CurvedAnimation(
      parent: _intro,
      curve: Interval(
        start.clamp(0.0, 1.0),
        1,
        curve: const WelcomeChallengeGentleCurve(),
      ),
    );
    _idle = welcomeChallengeBreath(_loop, timings);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(WelcomeChallengeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) _syncMotion();
  }

  /// Plays (or resumes) the sequence, or jumps to the settled Idle frame when
  /// motion is off.
  void _syncMotion() {
    final still = !widget.animate || MediaQuery.disableAnimationsOf(context);
    if (still == _still) return;
    _still = still;
    if (still) {
      _intro
        ..stop()
        ..value = 1;
      _loop
        ..stop()
        ..value = welcomeChallengeIdleRestValue(widget.timings);
    } else if (_intro.isCompleted) {
      _loop.repeat();
    } else {
      _intro.forward();
    }
  }

  void _onIntroStatus(AnimationStatus status) {
    if (status.isCompleted && _still == false && !_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _start() {
    context
      ..go(AppRoutes.home)
      ..push(AppRoutes.createCamera);
  }

  void _skip() => context.push(AppRoutes.registerNotifications);

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: WelcomeChallengeColors.backgroundEnd,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // Background: #0B46C5 → #032886 (55%) → #010F3D.
                      gradient: welcomeChallengeDiagonalGradient(
                        size,
                        colors: const [
                          WelcomeChallengeColors.backgroundStart,
                          Color(0xFF032886),
                          WelcomeChallengeColors.backgroundEnd,
                        ],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                // Figma layer order: stage, logo, language chip, card.
                Positioned.fill(
                  child: CustomMultiChildLayout(
                    delegate: _ScreenLayout(padding),
                    children: [
                      LayoutId(
                        id: _Slot.stage,
                        child: _StageArea(
                          topInset: padding.top,
                          reveal: _reveal,
                          idle: _idle,
                        ),
                      ),
                      LayoutId(
                        id: _Slot.logo,
                        child: Semantics(
                          label: 'Star',
                          image: true,
                          child: SvgPicture.asset(
                            AuthAssets.logo,
                            width: 33,
                            height: 29,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      LayoutId(
                        id: _Slot.language,
                        child: const WelcomeChallengeLanguageChip(),
                      ),
                      LayoutId(
                        id: _Slot.card,
                        child: AnimatedBuilder(
                          animation: _reveal,
                          builder: (context, child) => FractionalTranslation(
                            translation: Offset(0, 1 - _reveal.value),
                            child: child,
                          ),
                          child: WelcomeChallengeCard(
                            firstName: widget.firstName,
                            onStart: _start,
                            onSkip: _skip,
                          ),
                        ),
                      ),
                    ],
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

enum _Slot { stage, logo, language, card }

/// Card on the bottom edge (sized by its content, scrolling if it would come
/// within 56 of the status bar), the stage filling the space above it, the
/// logo at (24, top + 14) and the language chip 19 from the right at top + 16.
class _ScreenLayout extends MultiChildLayoutDelegate {
  _ScreenLayout(this.padding);

  final EdgeInsets padding;

  @override
  void performLayout(Size size) {
    final card = layoutChild(
      _Slot.card,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: math.max(size.height - padding.top - 56, 0),
      ),
    );
    final cardTop = size.height - card.height;
    positionChild(_Slot.card, Offset(0, cardTop));

    layoutChild(
      _Slot.stage,
      BoxConstraints.tight(Size(size.width, math.max(cardTop, 0))),
    );
    positionChild(_Slot.stage, Offset.zero);

    layoutChild(_Slot.logo, BoxConstraints.loose(size));
    positionChild(_Slot.logo, Offset(24, padding.top + 14));

    final chip = layoutChild(_Slot.language, BoxConstraints.loose(size));
    positionChild(
      _Slot.language,
      Offset(size.width - 19 - chip.width, padding.top + 16),
    );
  }

  @override
  bool shouldRelayout(_ScreenLayout oldDelegate) =>
      oldDelegate.padding != padding;
}

/// Places the 393×360 design stage between the status bar and the card:
/// unscaled and vertically centred when there's room, scaled down to fit on
/// short or narrow screens.
class _StageArea extends StatelessWidget {
  const _StageArea({
    required this.topInset,
    required this.reveal,
    required this.idle,
  });

  final double topInset;
  final Animation<double> reveal;
  final Animation<double> idle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const design = WelcomeChallengeStage.designSize;
        final available = math.max(constraints.maxHeight - topInset, 0.0);
        final scale = math.min(
          1.0,
          math.min(
            available / design.height,
            constraints.maxWidth / design.width,
          ),
        );
        return Padding(
          padding: EdgeInsets.only(top: topInset),
          child: OverflowBox(
            maxWidth: design.width,
            maxHeight: design.height,
            minWidth: design.width,
            minHeight: design.height,
            child: Transform.scale(
              scale: scale,
              child: RepaintBoundary(
                child: WelcomeChallengeStage(reveal: reveal, idle: idle),
              ),
            ),
          ),
        );
      },
    );
  }
}
