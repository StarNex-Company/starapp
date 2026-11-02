import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/my_post_style.dart';

/// Right-hand column: star, comments, share, save and the sound disc.
class MyPostActionRail extends StatelessWidget {
  const MyPostActionRail({
    super.key,
    required this.starred,
    required this.stars,
    required this.comments,
    required this.saved,
    required this.saves,
    required this.onStar,
    required this.onComments,
    required this.onShare,
    required this.onSave,
    required this.onSound,
  });

  final bool starred;
  final int stars;
  final int comments;
  final bool saved;
  final int saves;
  final VoidCallback onStar;
  final VoidCallback onComments;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onSound;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          _RailButton(
            tooltip: starred ? 'Remove star' : 'Star',
            icon: starred ? MyPostIcons.starActive : MyPostIcons.star,
            iconSize: starred ? 29 : 28.5,
            label: formatMyPostCount(stars),
            onTap: onStar,
            toggled: starred,
          ),
          _RailButton(
            tooltip: 'Comments',
            icon: MyPostIcons.comment,
            iconSize: 28.5,
            label: formatMyPostCount(comments),
            onTap: onComments,
          ),
          _RailButton(
            tooltip: 'Share',
            icon: MyPostIcons.share,
            iconSize: 30,
            label: 'Share',
            onTap: onShare,
          ),
          _RailButton(
            tooltip: saved ? 'Remove from saved' : 'Save',
            icon: saved ? MyPostIcons.saveActive : MyPostIcons.save,
            iconSize: 24,
            label: formatMyPostCount(saves),
            onTap: onSave,
            toggled: saved,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _SoundDisc(onTap: onSound),
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.tooltip,
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.onTap,
    this.toggled,
  });

  final String tooltip;
  final String icon;
  final double iconSize;
  final String label;
  final VoidCallback onTap;
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: toggled,
      label: tooltip,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Container(
              width: 45,
              height: 45,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: myPostGlass,
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween(begin: 0.6, end: 1.0).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: SvgPicture.asset(
                  icon,
                  key: ValueKey(icon),
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: myPostText(
                  13,
                  weight: FontWeight.w600,
                  color: AppColors.lunarWhite,
                  shadows: const [
                    Shadow(
                      color: Color(0x40000000),
                      offset: Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Spinning-record disc; tapping saves the post's sound.
class _SoundDisc extends StatelessWidget {
  const _SoundDisc({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sound',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xE6171717),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x33FFFFFF), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 20),
                blurRadius: 25,
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 8),
                blurRadius: 10,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF1D4ED8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x66FFFFFF)),
            ),
          ),
        ),
      ),
    );
  }
}
