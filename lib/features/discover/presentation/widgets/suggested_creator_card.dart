import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// 160×205 carousel card suggesting a creator to follow: photo, name,
/// handle, mutual followers, a Follow toggle and a dismiss ✕.
class SuggestedCreatorCard extends StatelessWidget {
  const SuggestedCreatorCard({
    super.key,
    required this.suggestion,
    required this.following,
    required this.onFollow,
    required this.onDismiss,
    required this.onTap,
  });

  static const width = 160.0;
  static const height = 205.0;
  static const _radius = BorderRadius.all(Radius.circular(16));

  final SuggestedCreator suggestion;
  final bool following;
  final VoidCallback onFollow;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final creator = suggestion.creator;

    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: _radius,
        border: Border.fromBorderSide(
          BorderSide(color: DiscoverColors.cardBorder),
        ),
        boxShadow: discoverHairShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: _radius,
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 18),
                  StarAvatar(creator.avatarUrl, size: 56),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        Text(
                          creator.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: discoverText(
                            12,
                            FontWeight.w700,
                            DiscoverColors.heading,
                            lineHeight: 16,
                          ),
                        ),
                        Text(
                          '@${creator.handle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: discoverText(
                            11,
                            FontWeight.w400,
                            DiscoverColors.body,
                            lineHeight: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.5),
                  _FollowedBy(people: suggestion.followedBy),
                  const SizedBox(height: 11.5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _FollowPill(following: following, onTap: onFollow),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Tooltip(
                  message: 'Dismiss suggestion',
                  child: InkResponse(
                    onTap: onDismiss,
                    radius: 16,
                    child: SizedBox.square(
                      dimension: 24,
                      child: Center(
                        child: SvgPicture.asset(DiscoverIcons.dismiss),
                      ),
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

/// "Followed by" with up to three overlapping mutual-follower avatars.
class _FollowedBy extends StatelessWidget {
  const _FollowedBy({required this.people});

  final List<CreatorSummary> people;

  @override
  Widget build(BuildContext context) {
    final shown = people.take(3).toList();
    // The design's middle avatar is a pixel narrower so the trio spans 45px.
    const widths = [18.0, 17.0, 18.0];
    const lefts = [0.0, 14.0, 27.0];

    return SizedBox(
      height: 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          Flexible(
            child: Text(
              'Followed by',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: discoverText(11, FontWeight.w500, AppColors.voidBlack),
            ),
          ),
          if (shown.isNotEmpty)
            SizedBox(
              width: lefts[shown.length - 1] + widths[shown.length - 1],
              height: 18,
              child: Stack(
                children: [
                  for (var i = 0; i < shown.length; i++)
                    Positioned(
                      left: lefts[i],
                      top: 0,
                      width: widths[i],
                      height: 18,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.avatarFallback,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white),
                        ),
                        child: StarImage(
                          shown[i].avatarUrl,
                          borderRadius: BorderRadius.circular(30),
                          placeholderColor: AppColors.avatarFallback,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Navy 32px pill with the add-person icon: "Follow" / "Following".
class _FollowPill extends StatelessWidget {
  const _FollowPill({required this.following, required this.onTap});

  final bool following;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: following,
      child: DecoratedBox(
        decoration: const ShapeDecoration(
          shape: StadiumBorder(),
          shadows: discoverHairShadow,
        ),
        child: Material(
          color: DiscoverColors.brand,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  SvgPicture.asset(DiscoverIcons.follow),
                  Text(
                    following ? 'Following' : 'Follow',
                    style: discoverText(
                      10,
                      FontWeight.w600,
                      Colors.white,
                      lineHeight: 14,
                    ),
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
