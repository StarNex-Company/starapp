import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/auth/presentation/widgets/welcome_challenge_style.dart';

/// White bottom card of the Welcome Challenge screen (Figma "Card"): title,
/// subtitle, the welcome-challenge tile, the Record → Post → Earn steps,
/// "Start My Journey" and "Skip for now".
///
/// Top corners 32, shadow 0/-10/40 #00051A @ 35%, padding 28/24, 14 gaps.
/// Sized by its content and meant to sit on the bottom edge of the screen;
/// a white strip below it covers the background if it springs past its rest
/// position.
class WelcomeChallengeCard extends StatelessWidget {
  const WelcomeChallengeCard({
    super.key,
    required this.firstName,
    required this.onStart,
    required this.onSkip,
  });

  final String firstName;

  /// "Start My Journey" and the challenge tile.
  final VoidCallback onStart;

  /// "Skip for now".
  final VoidCallback onSkip;

  static const _radius = BorderRadius.vertical(top: Radius.circular(32));

  @override
  Widget build(BuildContext context) {
    // The design leaves 24 under "Skip for now" (its 34 bottom padding is
    // clipped by the 430 card); keep clear of a taller home indicator.
    final bottom = math.max(24.0, MediaQuery.paddingOf(context).bottom - 10);
    final name = firstName.trim();
    final title = name.isEmpty
        ? 'Welcome to the stage ✨'
        : 'Welcome to the stage, $name ✨';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: -80,
          height: 80,
          child: const ColoredBox(color: Colors.white),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: _radius,
            boxShadow: [
              BoxShadow(
                color: Color(0x5900051A),
                offset: Offset(0, -10),
                blurRadius: 40,
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            // "Skip for now" carries 10px of the gaps above and below as tap
            // area, so the visible layout matches the design.
            padding: EdgeInsets.fromLTRB(24, 28, 24, bottom - 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: WelcomeChallengeText.title),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Your profile is ready. Every star starts with one performance, "
                  "so let's make your first one.",
                  style: WelcomeChallengeText.subtitle,
                ),
                const SizedBox(height: 14),
                _ChallengeTile(onTap: onStart),
                const SizedBox(height: 14),
                const _Steps(),
                const SizedBox(height: 14),
                _StartButton(onPressed: onStart),
                const SizedBox(height: 4),
                _SkipButton(onPressed: onSkip),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// "YOUR WELCOME CHALLENGE" tile: gold gradient, 1px #F5C451 @ 70% stroke,
/// radius 20, padding 16, 52 trophy badge + text.
class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({required this.onTap});

  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: _radius,
                border: Border.all(color: const Color(0xB3F5C451)),
                gradient: welcomeChallengeDiagonalGradient(
                  Size(constraints.maxWidth, 107),
                  colors: const [
                    WelcomeChallengeColors.tileStart,
                    WelcomeChallengeColors.tileEnd,
                  ],
                ),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: _radius,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _TrophyBadge(),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'YOUR WELCOME CHALLENGE',
                              style: WelcomeChallengeText.tileLabel,
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Post a 30-second intro of your talent',
                              style: WelcomeChallengeText.tileTitle,
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Earn +50 Stars and your first badge',
                              style: WelcomeChallengeText.tileBody,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  const _TrophyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: welcomeChallengeDiagonalGradient(
          const Size.square(52),
          colors: const [AppColors.gold, AppColors.goldDeep],
        ),
      ),
      child: SvgPicture.asset(
        WelcomeChallengeAssets.trophy,
        width: 26,
        height: 26,
      ),
    );
  }
}

/// ① Record → ② Post → ③ Earn ★ pills (#DAE4FF, 18px #032886 number dots).
class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    const arrow = Text('→', style: WelcomeChallengeText.stepArrow);
    return const Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          spacing: 8,
          children: [
            _Step(number: 1, label: 'Record'),
            arrow,
            _Step(number: 2, label: 'Post'),
            arrow,
            _Step(number: 3, label: 'Earn ★'),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: WelcomeChallengeColors.stepTint,
        borderRadius: BorderRadius.all(Radius.circular(99)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.brandBlue,
              shape: BoxShape.circle,
            ),
            child: Text('$number', style: WelcomeChallengeText.stepNumber),
          ),
          Text(label, style: WelcomeChallengeText.stepLabel),
        ],
      ),
    );
  }
}

/// "Start My Journey →": 52 high, radius 16, #0B46C5 → #032886, shadow
/// 0/8/20 #032987 @ 35%.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback onPressed;

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: SizedBox(
        height: 52,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: _radius,
            gradient: LinearGradient(
              colors: [
                WelcomeChallengeColors.backgroundStart,
                AppColors.brandBlue,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x59032987),
                offset: Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius: _radius,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  const Flexible(
                    child: Text(
                      'Start My Journey',
                      style: WelcomeChallengeText.button,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SvgPicture.asset(
                    WelcomeChallengeAssets.arrowRight,
                    width: 18,
                    height: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Skip for now": 14 SemiBold #7D7D7D, centred; 10px of extra tap area
/// above and below.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Skip for now',
              textAlign: TextAlign.center,
              style: WelcomeChallengeText.skip,
            ),
          ),
        ),
      ),
    );
  }
}
