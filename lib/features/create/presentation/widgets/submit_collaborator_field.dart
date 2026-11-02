import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/features/create/presentation/widgets/submit_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Input-style field showing the tagged collaborator as a removable chip.
class SubmitCollaboratorField extends StatelessWidget {
  const SubmitCollaboratorField({
    super.key,
    required this.collaborator,
    required this.onRemove,
    required this.onTag,
  });

  final CreatorSummary? collaborator;
  final VoidCallback onRemove;
  final VoidCallback onTag;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.borderField),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTag,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            spacing: 8,
            children: [
              if (collaborator != null)
                Flexible(child: _TaggedChip(collaborator!, onRemove: onRemove)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: collaborator == null ? 6 : 0),
                  child: Text(
                    collaborator == null
                        ? 'Tag a creator'
                        : 'Tag another creator',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1.2,
                      letterSpacing: 0,
                      fontSize: 14,
                      color: AppColors.textFaint,
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

class _TaggedChip extends StatelessWidget {
  const _TaggedChip(this.collaborator, {required this.onRemove});

  final CreatorSummary collaborator;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.only(left: 4, right: 10),
      decoration: const BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.all(Radius.circular(17)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          StarAvatar(collaborator.avatarUrl, size: 26),
          Flexible(
            child: Text(
              collaborator.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                height: 1.2,
                letterSpacing: 0,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.brandBlue,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Remove ${collaborator.name}',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: SvgPicture.asset(SubmitIcons.close, width: 13, height: 13),
            ),
          ),
        ],
      ),
    );
  }
}
