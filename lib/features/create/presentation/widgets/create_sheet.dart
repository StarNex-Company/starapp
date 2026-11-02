import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/create/data/models/challenge_summary.dart';
import 'package:starapp/features/create/data/provider/create_providers.dart';
import 'package:starapp/features/create/presentation/widgets/create_format.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _dir = 'assets/vectors/create';

// Inter's "normal" line height, so text boxes match the design.
const _leading = 1.21;

enum _CreateAction {
  recordVideo,
  uploadVideo,
  uploadImages,
  textPost,
  challenge,
  drafts,
}

/// Slides the Create sheet up over the current screen, then runs the picked
/// action once it has closed.
Future<void> showCreateSheet(BuildContext context) async {
  final action = await showStarSheet<_CreateAction>(
    context: context,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) => CreateSheet(
        challenge: ref.watch(featuredChallengeProvider).value,
        draftCount: ref.watch(draftCountProvider).value ?? 0,
        onRecordVideo: () =>
            Navigator.pop(sheetContext, _CreateAction.recordVideo),
        onUploadVideo: () =>
            Navigator.pop(sheetContext, _CreateAction.uploadVideo),
        onUploadImages: () =>
            Navigator.pop(sheetContext, _CreateAction.uploadImages),
        onTextPost: () => Navigator.pop(sheetContext, _CreateAction.textPost),
        onChallenge: () => Navigator.pop(sheetContext, _CreateAction.challenge),
        onDrafts: () => Navigator.pop(sheetContext, _CreateAction.drafts),
        onClose: () => Navigator.pop(sheetContext),
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  switch (action) {
    case _CreateAction.recordVideo:
      context.push(AppRoutes.createCamera);
    case _CreateAction.uploadVideo:
      context.push(AppRoutes.createPreview);
    case _CreateAction.challenge:
      context.push(AppRoutes.createSubmitEntry);
    case _CreateAction.uploadImages ||
        _CreateAction.textPost ||
        _CreateAction.drafts:
      showStarToast(context, 'Coming soon');
  }
}

/// "Create" bottom sheet: the ways to post, this month's challenge and drafts.
class CreateSheet extends StatelessWidget {
  const CreateSheet({
    super.key,
    required this.challenge,
    required this.draftCount,
    required this.onRecordVideo,
    required this.onUploadVideo,
    required this.onUploadImages,
    required this.onTextPost,
    required this.onChallenge,
    required this.onDrafts,
    required this.onClose,
  });

  /// This month's challenge; its banner shows once it has loaded.
  final FeaturedChallenge? challenge;
  final int draftCount;
  final VoidCallback onRecordVideo;
  final VoidCallback onUploadVideo;
  final VoidCallback onUploadImages;
  final VoidCallback onTextPost;
  final VoidCallback onChallenge;
  final VoidCallback onDrafts;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final challenge = this.challenge;
    return StarSheet(
      title: 'Create',
      subtitle: 'Share your talent with the world',
      onClose: onClose,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _OptionTile(
                icon: '$_dir/sheet_ic_video.svg',
                title: 'Record video',
                subtitle: 'Up to 3 minutes',
                highlighted: true,
                onTap: onRecordVideo,
              ),
            ),
            Expanded(
              child: _OptionTile(
                icon: '$_dir/sheet_ic_upload.svg',
                title: 'Upload video',
                subtitle: 'MP4 or MOV',
                onTap: onUploadVideo,
              ),
            ),
          ],
        ),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _OptionTile(
                icon: '$_dir/sheet_ic_image.svg',
                title: 'Upload images',
                subtitle: 'Up to 10 photos',
                onTap: onUploadImages,
              ),
            ),
            Expanded(
              child: _OptionTile(
                icon: '$_dir/sheet_ic_text.svg',
                title: 'Text post',
                subtitle: 'Share an idea',
                onTap: onTextPost,
              ),
            ),
          ],
        ),
        if (challenge != null)
          _ChallengeBanner(
            subtitle:
                '${challenge.challenge.title} · '
                '${formatTimeLeft(challenge.challenge.endsAt)} left',
            onTap: onChallenge,
          ),
        _DraftsRow(count: draftCount, onTap: onDrafts),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  static const _radius = BorderRadius.all(Radius.circular(20));

  /// SVG asset path, drawn at 22px.
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          highlighted
              ? const BoxShadow(
                  color: Color(0x40032886),
                  offset: Offset(0, 10),
                  blurRadius: 12,
                )
              : const BoxShadow(
                  color: Color(0x0F0B1020),
                  offset: Offset(0, 4),
                  blurRadius: 9,
                ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            color: highlighted ? null : Colors.white,
            gradient: highlighted ? AppColors.brandGradient : null,
            border: highlighted
                ? null
                : Border.all(color: AppColors.borderField),
            borderRadius: _radius,
          ),
          child: InkWell(
            borderRadius: _radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: highlighted
                          ? const Color(0x29FFFFFF)
                          : AppColors.brandTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SvgPicture.asset(icon, height: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: _leading,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: highlighted ? Colors.white : AppColors.ink,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: _leading,
                          fontSize: 12,
                          color: highlighted
                              ? AppColors.onBrandSubtle
                              : AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChallengeBanner extends StatelessWidget {
  const _ChallengeBanner({required this.subtitle, required this.onTap});

  static const _radius = BorderRadius.all(Radius.circular(18));

  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x38E7A91A),
            offset: Offset(0, 8),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: const BoxDecoration(
            borderRadius: _radius,
            // CSS 168.2deg across a 345x72 banner.
            gradient: LinearGradient(
              begin: Alignment(-0.084, -1.917),
              end: Alignment(0.084, 1.917),
              colors: [
                AppColors.goldLight,
                Color(0xFFF5C451),
                AppColors.goldDeep,
              ],
              stops: [0, 0.45, 1],
            ),
          ),
          child: InkWell(
            borderRadius: _radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.inkDeep,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      '$_dir/sheet_ic_trophy.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        const Text(
                          "Enter this month's challenge",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: _leading,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkDeep,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: _leading,
                            fontSize: 12,
                            color: AppColors.goldInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    '$_dir/sheet_ic_chevron_dark.svg',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DraftsRow extends StatelessWidget {
  const _DraftsRow({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 20,
        child: Row(
          spacing: 8,
          children: [
            SvgPicture.asset('$_dir/sheet_ic_file.svg', width: 16, height: 16),
            const Text(
              'Drafts',
              style: TextStyle(
                height: _leading,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textBody,
              ),
            ),
            if (count > 0)
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    height: _leading,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
            const Spacer(),
            SvgPicture.asset(
              '$_dir/sheet_ic_chevron_muted.svg',
              width: 18,
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}
