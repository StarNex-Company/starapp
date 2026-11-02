import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// "Thumbnail": a post's cover with its view count and, for challenge
/// entries, the gold "Entry" pill.
class MyProfilePostTile extends StatelessWidget {
  const MyProfilePostTile({super.key, required this.post, required this.onTap});

  final ProfileGridPost post;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(8));

  @override
  Widget build(BuildContext context) {
    final views = formatCompact(post.views);
    return Semantics(
      button: true,
      label: post.isChallengeEntry
          ? 'Challenge entry, $views views'
          : '$views views',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: _radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StarImage(post.thumbnailUrl),
            const _Scrim(),
            Positioned(
              left: 8,
              right: 8,
              bottom: 9,
              child: Row(
                spacing: 4,
                children: [
                  SvgPicture.asset(MyProfileIcons.play, width: 10, height: 10),
                  Flexible(
                    child: Text(
                      views,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: myProfileLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (post.isChallengeEntry)
              const Positioned(left: 8, top: 8, child: _EntryPill()),
            Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0007090D), Color(0xB307090D)],
          // The design's scrim covers the bottom half.
          stops: [0.5, 1],
        ),
      ),
    );
  }
}

class _EntryPill extends StatelessWidget {
  const _EntryPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: LinearGradient(
          begin: Alignment(-0.13, -1),
          end: Alignment(0.13, 1),
          colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDeep],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SizedBox.square(
            dimension: 11,
            child: OverflowBox(
              maxWidth: 11.77,
              maxHeight: 11.77,
              child: SvgPicture.asset(
                MyProfileIcons.entryTrophy,
                width: 11.77,
                height: 11.77,
              ),
            ),
          ),
          const Text(
            'Entry',
            maxLines: 1,
            style: TextStyle(
              fontSize: 10,
              height: myProfileLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.inkDeep,
            ),
          ),
        ],
      ),
    );
  }
}
