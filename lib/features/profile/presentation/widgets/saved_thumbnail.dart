import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/saved_item.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Post cover with a dark scrim over its lower half and "▶ 1.2M" views in
/// the bottom-left corner. Fills its parent.
class SavedThumbnail extends StatelessWidget {
  const SavedThumbnail({
    super.key,
    required this.item,
    required this.radius,
    required this.viewsInset,
    required this.onTap,
  });

  final SavedItem item;
  final double radius;

  /// Left / bottom offset of the views label.
  final Offset viewsInset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          StarImage(item.thumbnailUrl),
          const Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.5,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [SavedColors.scrimStart, SavedColors.scrimEnd],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: viewsInset.dx,
            right: viewsInset.dx,
            bottom: viewsInset.dy,
            child: Row(
              spacing: 4,
              children: [
                SvgPicture.asset(SavedIcons.play, width: 10, height: 10),
                Flexible(
                  child: Text(
                    formatCompact(item.views),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: savedLeading,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: onTap),
          ),
        ],
      ),
    );
  }
}

/// "Saved Mark": gold bookmark on a dark 30px disc; tapping it unsaves.
class SavedMarkButton extends StatelessWidget {
  const SavedMarkButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Remove from Saved',
      child: Material(
        color: AppColors.inkOverlay,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 30,
            child: Center(
              child: SvgPicture.asset(
                SavedIcons.bookmark,
                width: 15,
                height: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 20px creator photo and name.
class SavedByline extends StatelessWidget {
  const SavedByline({super.key, required this.item});

  final SavedItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        StarAvatar(item.creator.avatarUrl, size: 20),
        Flexible(
          child: Text(
            item.creator.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: savedLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              color: AppColors.textBody,
            ),
          ),
        ),
      ],
    );
  }
}
