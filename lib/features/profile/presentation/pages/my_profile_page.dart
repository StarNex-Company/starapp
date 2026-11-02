import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/data/provider/my_post_providers.dart';
import 'package:starapp/features/profile/data/provider/my_profile_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_actions.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_challenge_row.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_content_tabs.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_hero.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_identity.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_stats_card.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_tier_card.dart';
import 'package:starapp/features/profile/presentation/widgets/profile_menu_sheet.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_share_sheet.dart';

/// The Profile tab's first page (Figma "Profile — My Profile"): cover and
/// avatar, identity, stats, actions, tier & passport card, recent challenges
/// and the My Content / Challenge History / Stats tabs.
class MyProfilePage extends ConsumerWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(myProfileProvider);
    final posts = ref.watch(myProfilePostsProvider);
    final deleted = ref.watch(myPostInteractionsProvider).deleted;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'My Profile',
        leading: Semantics(
          label: 'Star App',
          child: SvgPicture.asset(MyProfileIcons.logo, width: 28, height: 24),
        ),
        trailing: StarIconButton(
          icon: MyProfileIcons.more,
          // The meatball glyph is 21×3.84 inside its 25px frame. SvgPicture
          // derives the width from the height, so pass the glyph's height.
          iconSize: 3.84375,
          tooltip: 'More',
          onPressed: () => showProfileMenuSheet(
            context,
            ref,
            shareLink: switch (user.value) {
              final me? => _profileLink(me),
              null => null,
            },
          ),
        ),
      ),
      body: StarAsyncView<CurrentUser>(
        value: user,
        onRetry: () => ref.invalidate(currentUserProvider),
        builder: (user) => StarAsyncView<MyProfile>(
          value: profile,
          onRetry: () => ref.invalidate(myProfileProvider),
          builder: (profile) => StarAsyncView<List<ProfileGridPost>>(
            value: posts,
            onRetry: () => ref.invalidate(myProfilePostsProvider),
            builder: (posts) => NotificationListener<ScrollUpdateNotification>(
              // Fetch the next page of posts as the grid's end nears.
              onNotification: (scroll) {
                if (scroll.metrics.extentAfter < 400) {
                  ref.read(myProfilePostsProvider.notifier).loadMore();
                }
                return false;
              },
              child: _MyProfileBody(
                user: user,
                profile: profile,
                posts: [
                  for (final post in posts)
                    if (!deleted.contains(post.id)) post,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The creator's public profile link, without the scheme.
String _profileLink(CurrentUser user) => 'starapp.io/@${user.handle}';

class _MyProfileBody extends StatelessWidget {
  const _MyProfileBody({
    required this.user,
    required this.profile,
    required this.posts,
  });

  final CurrentUser user;
  final MyProfile profile;

  /// The grid's posts loaded so far, without the ones deleted this session.
  final List<ProfileGridPost> posts;

  /// Where a challenge row leads: the live board while it runs, the results
  /// once placed; completed one-offs don't open anything.
  VoidCallback? _challengeTap(BuildContext context, ChallengeHistoryEntry e) {
    return switch (e.standing) {
      ChallengeStanding.live => () => context.push(
        AppRoutes.challengesLeaderboard,
      ),
      ChallengeStanding.placed => () => context.push(
        AppRoutes.challengeWinners,
      ),
      ChallengeStanding.completed => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 32;
    void push(String route) => context.push(route);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18,
        children: [
          MyProfileHero(
            coverUrl: user.coverUrl ?? MyProfileImages.defaultCover,
            avatarUrl: user.avatarUrl,
            tier: user.tier.label,
          ),
          MyProfileIdentity(
            name: user.fullName,
            handle: user.handle,
            location: user.location,
            bio: user.bio,
            talents: user.talents,
            isFounder: profile.isFounder,
            isVerified: user.isVerified,
          ),
          _Section(
            child: MyProfileStatsCard(
              stats: [
                MyProfileStat(
                  label: 'Stars',
                  value: user.stars,
                  onTap: () => push(AppRoutes.profileInsights),
                ),
                MyProfileStat(
                  label: 'Followers',
                  value: user.followers,
                  onTap: () => push(AppRoutes.profileFollowers),
                ),
                MyProfileStat(
                  label: 'Following',
                  value: user.following,
                  onTap: () => push(AppRoutes.profileFollowing),
                ),
                MyProfileStat(label: 'Posts', value: user.posts),
              ],
            ),
          ),
          _Section(
            child: MyProfileActions(
              onEdit: () => push(AppRoutes.editProfile),
              onShare: () =>
                  showStarShareSheet(context, link: _profileLink(user)),
              onInsights: () => push(AppRoutes.profileInsights),
            ),
          ),
          _Section(
            child: MyProfileTierCard(
              tier: user.tier.label,
              tierLevel: user.tier.level,
              progress: profile.tierProgress,
              passport: profile.passport,
              onTap: () => push(AppRoutes.profilePassport),
            ),
          ),
          if (profile.challenges.isNotEmpty)
            _Section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  _SectionHeader(
                    title: 'My challenges',
                    action: 'All challenges',
                    onAction: () => push(AppRoutes.challengesMyEntries),
                  ),
                  for (final entry in profile.challenges.take(2))
                    MyProfileChallengeRow(
                      key: ValueKey(entry.id),
                      entry: entry,
                      onTap: _challengeTap(context, entry),
                    ),
                ],
              ),
            ),
          _Section(
            child: MyProfileContentTabs(
              posts: posts,
              challenges: profile.challenges,
              stats: profile.stats,
              onOpenPost: (post) => push('${AppRoutes.post}?id=${post.id}'),
              onOpenChallenge: (e) => _challengeTap(context, e),
              onOpenInsights: () => push(AppRoutes.profileInsights),
            ),
          ),
        ],
      ),
    );
  }
}

/// 24px side gutters, as every block below the identity has.
class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              height: myProfileLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
        ),
        Flexible(
          child: Semantics(
            button: true,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Text(
                action,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: myProfileLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.brandBlue,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
