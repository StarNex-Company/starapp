import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';

abstract final class _SuccessAssets {
  static const _dir = 'assets/vectors/shared';

  static const sparkleGold18 = '$_dir/success_sparkle_gold_18.svg';
  static const sparkleGold20 = '$_dir/success_sparkle_gold_20.svg';
  static const sparkleNavy14 = '$_dir/success_sparkle_navy_14.svg';
  static const sparkleNavy12 = '$_dir/success_sparkle_navy_12.svg';
}

/// Centred header of a success screen: the glowing navy emblem with sparkles,
/// a bold title, a grey message and an optional [chip] (see [StarSuccessChip]).
///
/// ```dart
/// StarSuccessHero(
///   icon: 'assets/vectors/create/submitted_check.svg',
///   glowColor: Color(0xFFF5C451),
///   title: "You're in the arena!",
///   message: 'Your entry is under review.',
///   chip: StarSuccessChip(...),
/// )
/// ```
class StarSuccessHero extends StatelessWidget {
  const StarSuccessHero({
    super.key,
    required this.icon,
    required this.glowColor,
    required this.title,
    required this.message,
    this.chip,
  });

  /// White SVG drawn at 44px on the disc.
  final String icon;

  /// Colour of the soft halo behind the disc.
  final Color glowColor;
  final String title;
  final String message;
  final Widget? chip;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        _AnimatedEmblem(icon: icon, glowColor: glowColor),
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              height: 1.2,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 22 / 15,
              letterSpacing: 0,
              color: AppColors.textSubtle,
            ),
          ),
        ),
        ?chip,
      ],
    );
  }
}

/// 30px rounded pill with a small icon, e.g. "+50 Stars · entry bonus".
class StarSuccessChip extends StatelessWidget {
  const StarSuccessChip({
    super.key,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  /// SVG asset path, drawn at 11px.
  final String icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(icon, width: 11, height: 11),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.2,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedEmblem extends StatefulWidget {
  const _AnimatedEmblem({required this.icon, required this.glowColor});

  final String icon;
  final Color glowColor;

  @override
  State<_AnimatedEmblem> createState() => _AnimatedEmblemState();
}

class _AnimatedEmblemState extends State<_AnimatedEmblem>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final _scaleCurve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  late final _scale = Tween<double>(begin: 0.7, end: 1).animate(_scaleCurve);
  late final _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    _scaleCurve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: _Emblem(icon: widget.icon, glowColor: widget.glowColor),
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({required this.icon, required this.glowColor});

  final String icon;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    Widget sparkle(String asset, double left, double top, double size) =>
        Positioned(
          left: left,
          top: top,
          child: SvgPicture.asset(asset, width: size, height: size),
        );

    return SizedBox(
      width: 180,
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 10,
            top: 0,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowColor.withValues(alpha: 0.45),
                    glowColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 42,
            top: 32,
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.brandGradient,
                boxShadow: [
                  BoxShadow(color: Color(0x4D032886), offset: Offset(0, 12), blurRadius: 15),
                ],
              ),
              child: SvgPicture.asset(icon, width: 44, height: 44),
            ),
          ),
          sparkle(_SuccessAssets.sparkleGold18, 14, 30, 18),
          sparkle(_SuccessAssets.sparkleNavy14, 150, 20, 14),
          sparkle(_SuccessAssets.sparkleGold20, 160, 110, 20),
          sparkle(_SuccessAssets.sparkleNavy12, 6, 118, 12),
        ],
      ),
    );
  }
}
