import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/saved_item.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_style.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_thumbnail.dart';

/// List-mode row: 72×96 cover, title, creator, "▶ 1.2M views · saved this
/// week" and the saved mark.
class SavedListRow extends StatelessWidget {
  const SavedListRow({
    super.key,
    required this.item,
    required this.onTap,
    required this.onUnsave,
  });

  final SavedItem item;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  static const _metaStyle = TextStyle(
    fontSize: 12,
    height: savedLeading,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.textBody,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          spacing: 14,
          children: [
            SizedBox(
              width: 72,
              height: 96,
              child: SavedThumbnail(
                item: item,
                radius: 12,
                viewsInset: const Offset(6, 6),
                onTap: onTap,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: savedLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    SavedByline(item: item),
                    Text(
                      '▶ ${formatCompact(item.views)} views · saved '
                      '${formatSavedWhen(item.savedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _metaStyle,
                    ),
                  ],
                ),
              ),
            ),
            SavedMarkButton(onTap: onUnsave),
          ],
        ),
      ),
    );
  }
}
