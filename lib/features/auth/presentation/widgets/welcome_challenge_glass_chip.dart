import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';
import 'package:starapp/features/auth/presentation/widgets/welcome_challenge_style.dart';

/// Frosted pill on the blue stage: white @ 14% fill (or [fill]), 1px white
/// @ 25% stroke, 12px background blur, 12/7 padding, 12 Bold label.
/// 31 high.
class WelcomeChallengeGlassChip extends StatelessWidget {
  const WelcomeChallengeGlassChip({
    super.key,
    required this.label,
    this.fill = WelcomeChallengeColors.glassFill,
    this.foreground = Colors.white,
    this.trailingSparkle = false,
    this.onTap,
  });

  final String label;
  final Color fill;
  final Color foreground;

  /// Ends the label with the design's "✦" glyph (drawn from the sparkle
  /// asset, since Inter has no U+2726).
  final bool trailingSparkle;
  final VoidCallback? onTap;

  static const _radius = BorderRadius.all(Radius.circular(99));

  @override
  Widget build(BuildContext context) {
    final style = WelcomeChallengeText.chip.copyWith(color: foreground);
    Widget content = Text.rich(
      TextSpan(
        text: label,
        children: [
          if (trailingSparkle) ...[
            const TextSpan(text: ' '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _Sparkle(color: foreground),
            ),
          ],
        ],
      ),
      style: style,
      maxLines: 1,
      softWrap: false,
    );
    content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: _radius,
        border: Border.all(color: WelcomeChallengeColors.glassStroke),
      ),
      child: content,
    );
    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onTap, borderRadius: _radius, child: content),
      );
    }
    return ClipRRect(
      borderRadius: _radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: content,
      ),
    );
  }
}

/// The 12px "✦": 9.2px glyph in a 10.9px advance.
class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10.9,
      height: 15,
      child: Align(
        alignment: const Alignment(-0.3, 0),
        child: SvgPicture.asset(
          WelcomeChallengeAssets.sparkle,
          width: 9.2,
          height: 9.2,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}

/// "🌐 English" glass chip in the header. Shows the app's active locale and
/// pushes the Language selection screen when tapped.
class WelcomeChallengeLanguageChip extends StatelessWidget {
  const WelcomeChallengeLanguageChip({super.key});

  @override
  Widget build(BuildContext context) {
    final name = authLanguageName(Localizations.localeOf(context));
    return Semantics(
      button: true,
      label: 'Language: $name',
      excludeSemantics: true,
      child: WelcomeChallengeGlassChip(
        label: '🌐 $name',
        onTap: () => context.push(AppRoutes.language),
      ),
    );
  }
}
