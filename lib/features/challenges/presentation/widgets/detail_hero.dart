import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_icons.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _scrimTop = Color(0x9907090D); // icon/primary/07090d @ 60%
const _scrimBottom = Color(0xBF07090D); // icon/primary/07090d @ 75%
const _clear = Color(0x0007090D);
const _pillDark = Color(0x8007090D); // icon/primary/07090d @ 50%

/// Cover photo behind the detail screen, darkened at the top for the status
/// bar and buttons and at the bottom for the pills.
class DetailHeroBackdrop extends StatelessWidget {
  const DetailHeroBackdrop({super.key, required this.image, this.height = 320});

  final String? image;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          StarImage(image),
          const Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_scrimTop, _clear],
                  ),
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_clear, _scrimBottom],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 40px frosted round button over the hero photo.
class DetailGlassButton extends StatelessWidget {
  const DetailGlassButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.iconSize = 18,
    this.background = AppColors.glass,
  });

  /// SVG asset path.
  final String icon;
  final double iconSize;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Material(
            color: background,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: 40,
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bookmark toggle: outline on glass, or a gold filled bookmark on white
/// once [saved].
class DetailBookmarkButton extends StatelessWidget {
  const DetailBookmarkButton({
    super.key,
    required this.saved,
    required this.onPressed,
  });

  final bool saved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: saved,
      child: DetailGlassButton(
        icon: saved ? DetailIcons.bookmarkFilled : DetailIcons.bookmark,
        background: saved ? Colors.white : AppColors.glass,
        tooltip: saved ? 'Remove bookmark' : 'Bookmark',
        onPressed: onPressed,
      ),
    );
  }
}

/// "Featured Arena" and "Ends in …" pills shown over the bottom of the hero.
class DetailHeroPills extends StatelessWidget {
  const DetailHeroPills({super.key, required this.endsIn});

  /// e.g. "4d 18h".
  final String endsIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        const _Pill(
          decoration: BoxDecoration(
            gradient: DetailGradients.gold,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          icon: DetailIcons.crown,
          label: 'Featured Arena',
          color: AppColors.inkDeep,
        ),
        Flexible(
          child: _Pill(
            decoration: const BoxDecoration(
              color: _pillDark,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            icon: DetailIcons.clock,
            label: 'Ends in $endsIn',
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.decoration,
    required this.icon,
    required this.label,
    required this.color,
  });

  final BoxDecoration decoration;
  final String icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          DetailSlotIcon(icon, size: 11),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: detailLeading,
                letterSpacing: 0,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
