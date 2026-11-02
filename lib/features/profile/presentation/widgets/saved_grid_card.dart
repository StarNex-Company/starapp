import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/data/models/saved_item.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_style.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_thumbnail.dart';

/// Grid tile: 166×210 cover with the saved mark, then title and creator.
class SavedGridCard extends StatelessWidget {
  const SavedGridCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onUnsave,
  });

  final SavedItem item;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        AspectRatio(
          aspectRatio: 166 / 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SavedThumbnail(
                item: item,
                radius: 14,
                viewsInset: const Offset(8, 9),
                onTap: onTap,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: SavedMarkButton(onTap: onUnsave),
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: savedLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              SavedByline(item: item),
            ],
          ),
        ),
      ],
    );
  }
}
