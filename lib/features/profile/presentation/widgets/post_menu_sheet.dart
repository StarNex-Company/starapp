import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/my_post.dart';
import 'package:starapp/features/profile/presentation/widgets/my_post_style.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';

/// What the user picked in the post menu.
enum PostMenuAction { insights, editCaption, share, delete }

/// Opens "Your post" (Figma "Sheet — Post Menu"): View insights, Edit
/// caption, Share post and Delete post. Resolves to the chosen action, or
/// null when dismissed; the sheet is closed by then.
Future<PostMenuAction?> showPostMenuSheet(
  BuildContext context, {
  required MyPost post,
}) {
  return showStarSheet<PostMenuAction>(
    context: context,
    builder: (sheetContext) {
      void pick(PostMenuAction action) =>
          Navigator.of(sheetContext).pop(action);

      return StarSheet(
        title: 'Your post',
        subtitle: post.title,
        children: [
          _MenuRow(
            icon: MyPostIcons.menuInsights,
            // The trend arrow's artwork is 23×20; it overhangs its 20px slot.
            iconWidth: 23.0606,
            title: 'View insights',
            subtitle:
                '${formatCompact(post.views)} views · '
                '${formatGrouped(post.starsEarned)} Stars',
            onTap: () => pick(PostMenuAction.insights),
          ),
          _MenuRow(
            icon: MyPostIcons.menuEdit,
            title: 'Edit caption',
            onTap: () => pick(PostMenuAction.editCaption),
          ),
          _MenuRow(
            icon: MyPostIcons.menuShare,
            title: 'Share post',
            onTap: () => pick(PostMenuAction.share),
          ),
          _MenuRow(
            icon: MyPostIcons.menuTrash,
            title: 'Delete post',
            subtitle: "This can't be undone",
            danger: true,
            onTap: () => pick(PostMenuAction.delete),
          ),
        ],
      );
    },
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconWidth = 20,
    this.danger = false,
  });

  final String icon;
  final double iconWidth;
  final String title;
  final String? subtitle;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: danger ? AppColors.dangerTint : AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(icon, width: iconWidth, height: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.21,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: danger ? AppColors.danger : AppColors.ink,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.21,
                          letterSpacing: 0,
                          color: AppColors.textSubtle,
                        ),
                      ),
                  ],
                ),
              ),
              SvgPicture.asset(
                danger
                    ? MyPostIcons.menuChevronDanger
                    : MyPostIcons.menuChevron,
                width: 18,
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
