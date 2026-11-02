import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// 224px-tall talent video thumbnail: author, caption and a bookmark toggle
/// over a dark bottom fade.
class DiscoverVideoCard extends StatelessWidget {
  const DiscoverVideoCard({
    super.key,
    required this.video,
    required this.onTap,
    required this.onBookmark,
  });

  static const height = 224.0;
  static const _radius = BorderRadius.all(Radius.circular(10));

  final DiscoverVideo video;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      foregroundDecoration: const BoxDecoration(
        borderRadius: _radius,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.borderDefault, width: 1.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: ColoredBox(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            children: [
              StarImage(video.posterUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00FFFFFF), Color(0xB0000000)],
                    stops: [0.5, 0.98438],
                  ),
                ),
              ),
              Positioned(
                left: 11,
                right: 11,
                bottom: 12,
                child: _Byline(video: video),
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  child: Semantics(
                    label: '${video.creator.name}: ${video.caption}',
                    button: true,
                  ),
                ),
              ),
              Positioned(
                top: 13,
                right: 8,
                child: _BookmarkButton(
                  bookmarked: video.isSaved,
                  onTap: onBookmark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Byline extends StatelessWidget {
  const _Byline({required this.video});

  final DiscoverVideo video;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brandNavy, width: 1.1),
          ),
          child: StarAvatar(video.creator.avatarUrl, size: 21),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 1,
                children: [
                  Flexible(
                    child: Text(
                      video.creator.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: discoverText(
                        8,
                        FontWeight.w500,
                        AppColors.lunarWhite,
                      ),
                    ),
                  ),
                  if (video.creator.isVerified)
                    SvgPicture.asset(
                      DiscoverIcons.verified,
                      width: 9,
                      height: 9,
                    ),
                ],
              ),
              Text(
                video.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: discoverText(
                  7,
                  FontWeight.w400,
                  AppColors.iconButtonBg,
                  lineHeight: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.bookmarked, required this.onTap});

  final bool bookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: bookmarked,
      label: 'Bookmark',
      child: Material(
        color: AppColors.brandNavy,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 30,
            child: Center(
              child: bookmarked
                  ? SvgPicture.asset(
                      DiscoverIcons.bookmarkFill,
                      width: 14,
                      height: 14,
                    )
                  : SvgPicture.asset(
                      DiscoverIcons.bookmark,
                      width: 18,
                      height: 18,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
