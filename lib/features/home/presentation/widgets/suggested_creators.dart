import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/home/data/models/suggested_creator.dart';
import 'package:starapp/features/home/presentation/widgets/feed_primitives.dart';
import 'package:starapp/features/home/presentation/widgets/home_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _heading = Color(0xFF191C1E); // text/body/191c1e
const _handle = Color(0xFF444652); // text/body/444652
const _action = Color(0xFF042987); // text/brand/042987
const _cardBorder = Color(0x4DC5C5D4); // c5c5d4 @ 30%
const _softShadow = BoxShadow(
  color: Color(0x0D000000),
  offset: Offset(0, 1),
  blurRadius: 1,
);

/// "Suggested Creators": heading with "See All", then a full-bleed row of
/// creator cards that can be followed or dismissed. Hides itself once
/// nothing is left.
class SuggestedCreators extends StatelessWidget {
  const SuggestedCreators({
    super.key,
    required this.creators,
    this.following = const {},
    this.onSeeAll,
    this.onCreatorTap,
    this.onFollow,
    this.onDismiss,
  });

  final List<SuggestedCreator> creators;

  /// Ids of the creators the user follows.
  final Set<String> following;
  final VoidCallback? onSeeAll;
  final ValueChanged<SuggestedCreator>? onCreatorTap;
  final ValueChanged<SuggestedCreator>? onFollow;
  final ValueChanged<SuggestedCreator>? onDismiss;

  void _dismiss(BuildContext context, SuggestedCreator creator) {
    if (onDismiss == null) return;
    onDismiss!(creator);
    showStarToast(context, 'Suggestion hidden');
  }

  @override
  Widget build(BuildContext context) {
    if (creators.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Suggested Creators',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    letterSpacing: -0.35,
                    fontWeight: FontWeight.w700,
                    color: _heading,
                  ),
                ),
              ),
              Semantics(
                button: true,
                child: GestureDetector(
                  onTap: onSeeAll,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 10,
                        height: 14 / 10,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: _action,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 205,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: creators.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final creator = creators[i];
              return _CreatorCard(
                key: ValueKey(creator.creator.id),
                creator: creator,
                isFollowing: following.contains(creator.creator.id),
                onTap: onCreatorTap == null
                    ? null
                    : () => onCreatorTap!(creator),
                onFollow: () => onFollow?.call(creator),
                onDismiss: () => _dismiss(context, creator),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CreatorCard extends StatelessWidget {
  const _CreatorCard({
    super.key,
    required this.creator,
    required this.isFollowing,
    required this.onFollow,
    required this.onDismiss,
    this.onTap,
  });

  final SuggestedCreator creator;
  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final person = creator.creator;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 160,
        height: 205,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
          boxShadow: const [_softShadow],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 51,
              top: 18,
              child: StarAvatar(person.avatarUrl, size: 56),
            ),
            Positioned(
              left: 14,
              right: 14,
              top: 84,
              child: Text(
                person.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  color: _heading,
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              top: 100,
              child: Text(
                '@${person.handle}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  height: 20 / 11,
                  letterSpacing: 0,
                  color: _handle,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 125.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Text(
                      'Followed by',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: feedLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.voidBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  AvatarPile(
                    avatarUrls: [
                      for (final c in creator.followedBy) c.avatarUrl,
                    ],
                    overlap: 4,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              top: 155,
              height: 32,
              child: _SuggestFollowButton(
                isFollowing: isFollowing,
                onTap: onFollow,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Tooltip(
                message: 'Dismiss suggestion',
                child: Material(
                  type: MaterialType.transparency,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onDismiss,
                    child: SizedBox.square(
                      dimension: 24,
                      child: Center(
                        child: SvgPicture.asset(
                          HomeIcons.dismiss,
                          width: 9.33333,
                          height: 9.33333,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle / Follow 3: the label flips between "Follow" and "Following".
class _SuggestFollowButton extends StatelessWidget {
  const _SuggestFollowButton({required this.isFollowing, required this.onTap});

  final bool isFollowing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isFollowing,
      child: DecoratedBox(
        decoration: const ShapeDecoration(
          shape: StadiumBorder(),
          shadows: [_softShadow],
        ),
        child: Material(
          color: _action,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  HomeIcons.personAdd,
                  width: 12.8333,
                  height: 9.33333,
                ),
                const SizedBox(width: 3.99),
                Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    fontSize: 10,
                    height: 14 / 10,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
