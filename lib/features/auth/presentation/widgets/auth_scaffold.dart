import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_assets.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_language_chip.dart';
import 'package:starapp/features/auth/presentation/widgets/step_indicator.dart';

/// Page shell shared by the auth screens (Login, Register 1–4, OTP, Forgot /
/// New Password, Verify Email…), laid out on the 393×852 Figma frames:
///
/// * #F7F7F8 background;
/// * header: 33×29 navy logo at x=24 and the [AuthLanguageChip] at the right,
///   13px below the safe area (y=75 with a 62px status bar);
/// * optional registration [step] bar (1-based, of [totalSteps]) 22px below
///   the header — the body then starts 20px below it (y=153), otherwise 33px
///   below the header (y=140);
/// * [child] in a 24px side-padded, scrollable column;
/// * optional [footer] (usually an `AuthFooterLink`) 35px above the bottom
///   edge (y=800 on the 852 frame), over the bottom wave. On short screens it
///   is not pinned: it follows the content (24px gap) and scrolls with it.
///
/// Keyboard-safe: the body resizes and scrolls the focused field into view;
/// the wave hides while the keyboard is open.
///
/// ```dart
/// AuthScaffold(
///   step: 2, // "step 2 of 4" — omit on non-registration screens
///   footer: AuthFooterLink(
///     prompt: 'Already have an account?',
///     action: 'Login here',
///     onTap: () => context.go(AppRoutes.signIn),
///   ),
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.stretch,
///     children: [
///       const AuthHeading(title: 'Create Your Account', subtitle: '…'),
///       const SizedBox(height: 20),
///       AuthTextField.name(label: 'Full Name', controller: _name),
///       …
///     ],
///   ),
/// )
/// ```
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.step,
    this.totalSteps = 4,
    this.footer,
    this.showWave = true,
    this.showLanguageChip = true,
    this.onLanguageTap,
    this.scrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  }) : assert(step == null || (step >= 1 && step <= totalSteps));

  /// Screen content (below the header / step bar).
  final Widget child;

  /// 1-based registration step; `null` hides the step bar.
  final int? step;
  final int totalSteps;

  /// Bottom line, e.g. `AuthFooterLink(...)`.
  final Widget? footer;

  /// Bottom wave decoration (on by default, like every auth frame).
  final bool showWave;
  final bool showLanguageChip;

  /// Overrides the chip's default `context.push(AppRoutes.language)`.
  final VoidCallback? onLanguageTap;

  /// `false` gives [child] the remaining height instead of a scroll view
  /// (for screens with their own `ListView`, e.g. a searchable list).
  final bool scrollable;

  /// Padding around [child] and the footer (the top gap is added to it).
  final EdgeInsets padding;

  /// Distance from the screen's bottom edge to the footer's bottom.
  static double footerBottom(BuildContext context) =>
      math.max(MediaQuery.viewPaddingOf(context).bottom + 1, 20);

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final bottomGap = keyboardOpen
        ? 16.0
        : footer != null
        ? AuthScaffold.footerBottom(context)
        : safeBottom + 24;
    final childPadding = padding.add(
      EdgeInsets.only(top: step != null ? 20 : 33),
    );

    // Footer (or bottom spacing) that sits at the bottom of the viewport when
    // the content is short and flows after it (≥24px gap) when it is long.
    final Widget bottom = footer == null
        ? SizedBox(height: bottomGap)
        : Padding(
            padding: EdgeInsets.fromLTRB(
              padding.left,
              24,
              padding.right,
              bottomGap,
            ),
            child: Align(alignment: Alignment.bottomCenter, child: footer),
          );

    final Widget body = scrollable
        ? CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: childPadding,
                sliver: SliverToBoxAdapter(child: child),
              ),
              SliverFillRemaining(hasScrollBody: false, child: bottom),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(padding: childPadding, child: child),
              ),
              bottom,
            ],
          );

    return Scaffold(
      backgroundColor: AppColors.lunarWhite,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (showWave && !keyboardOpen)
            const Positioned(left: 0, right: 0, bottom: 0, child: AuthWave()),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeaderBar(
                  showLanguageChip: showLanguageChip,
                  onLanguageTap: onLanguageTap,
                ),
                if (step != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                    child: StepIndicator(
                      currentStep: step! - 1,
                      totalSteps: totalSteps,
                    ),
                  ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo (left) + language chip (right) row: 24px side padding, 13px top
/// padding, 32 high. Used by [AuthScaffold] and `AuthAppBar`.
class AuthHeaderBar extends StatelessWidget {
  const AuthHeaderBar({
    super.key,
    this.showLanguageChip = true,
    this.onLanguageTap,
  });

  final bool showLanguageChip;
  final VoidCallback? onLanguageTap;

  /// Total height of the bar (13 top padding + 32).
  static const double height = 45;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 13, 24, 0),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            Semantics(
              label: 'Star App',
              image: true,
              child: SvgPicture.asset(AuthAssets.logo, width: 33, height: 29),
            ),
            const Spacer(),
            if (showLanguageChip) AuthLanguageChip(onTap: onLanguageTap),
          ],
        ),
      ),
    );
  }
}

/// The auth bottom wave (Figma "Group 46": three #4976E9 @ 18% layers,
/// rotated 7.57°). Its visible part is 393×227 at the bottom of the frame;
/// it scales with the screen width. Place it at the bottom of a `Stack`.
class AuthWave extends StatelessWidget {
  const AuthWave({super.key});

  static const double _designWidth = 393;
  static const double _designHeight = 227; // 852 - 625

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio: _designWidth / _designHeight,
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: _designWidth,
            height: _designHeight,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Rotated bounds in the frame: x -45.77, y 625.36, 469.958×349.65.
                Positioned(
                  left: -45.77,
                  top: 0.36,
                  width: 469.958,
                  height: 349.65,
                  child: Center(
                    child: Transform.rotate(
                      angle: 7.57 * math.pi / 180,
                      child: SvgPicture.asset(
                        AuthAssets.wave,
                        width: 434.895,
                        height: 294.927,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
