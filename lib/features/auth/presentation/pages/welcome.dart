import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';

/// Welcome (Figma `77:234`): hero photo fading into #EDF2FF with white rings,
/// app icon, title, subtitle, "Create Account" / "Log In".
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Buttons end 54px above the bottom edge on the 852 frame (34 inset + 20).
    final bottom =
        math.max(MediaQuery.viewPaddingOf(context).bottom, 14.0) + 20;

    return Scaffold(
      backgroundColor: AppColors.lunarWhite,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _WelcomeBackdrop(),
          Positioned(
            left: 24,
            right: 24,
            bottom: bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: SvgPicture.asset(
                    AuthAssets.starIcon,
                    width: 94,
                    height: 94,
                    semanticsLabel: 'Star App',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome to Star App',
                  textAlign: TextAlign.center,
                  style: AuthTextStyles.welcomeTitle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'A social platform where creators share, grow, and get discovered.',
                  textAlign: TextAlign.center,
                  style: AuthTextStyles.welcomeSubtitle,
                ),
                const SizedBox(height: 53),
                AuthPrimaryButton(
                  label: 'Create Account',
                  onPressed: () => context.go(AppRoutes.signUp),
                ),
                const SizedBox(height: 15),
                AuthSecondaryButton(
                  label: 'Log In',
                  onPressed: () => context.go(AppRoutes.signIn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The 393×852 Figma backdrop (photo, #EDF2FF fade, rings), scaled to cover
/// the screen and anchored to the bottom so it lines up with the content.
class _WelcomeBackdrop extends StatelessWidget {
  const _WelcomeBackdrop();

  static const _rings = [229.0, 282.5, 336.0];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 393,
          height: 852,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: -147,
                top: -69,
                width: 688,
                height: 921,
                child: Image.asset(
                  AuthAssets.welcomeBackground,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 0,
                top: 13,
                width: 393,
                height: 839,
                child: ClipRect(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.authWelcomeTint.withValues(alpha: 0),
                          AppColors.authWelcomeTint,
                        ],
                        stops: const [0.32718, 0.61442],
                      ),
                    ),
                    child: Stack(
                      children: [
                        for (final left in _rings)
                          Positioned(
                            left: left,
                            top: 644,
                            width: 381.998,
                            height: 251,
                            child: const DecoratedBox(
                              decoration: ShapeDecoration(
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: AppColors.authRing,
                                    width: 19,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
