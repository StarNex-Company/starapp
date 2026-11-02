import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';
import 'package:starapp/features/profile/data/provider/creator_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_actions.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_challenge_banner.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_hero.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_identity.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_stats_card.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_style.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_tabs.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_share_sheet.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Another creator's public profile (Figma "Profile — Creator (Public)" /
/// "(Following)"), opened inside the current tab with `context.pushCreator`,
/// or full screen from pages outside the tabs.
///
/// Following moves Following / Message beside the photo and drops the full
/// width row. The header's share button opens the share sheet.
class CreatorProfilePage extends ConsumerWidget {
  const CreatorProfilePage({super.key, required this.creatorId});

  final String creatorId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(creatorProfileProvider(creatorId));
    final loaded = profile.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Creator',
        leading: StarIconButton.back(onPressed: () => _back(context)),
        trailing: loaded == null
            ? null
            : StarIconButton(
                icon: CreatorIcons.share,
                iconSize: 25,
                tooltip: 'Share profile',
                onPressed: () => _share(context, loaded),
              ),
      ),
      body: StarAsyncView(
        value: profile,
        onRetry: () => ref.invalidate(creatorProfileProvider(creatorId)),
        builder: (profile) => _ProfileBody(
          profile: profile,
          onFollowToggle: () => _toggleFollow(context, ref, profile),
          // The messages feature opens the existing thread or a new one.
          onMessage: () =>
              context.pushInTab('${AppRoutes.newMessage}?to=${profile.id}'),
        ),
      ),
    );
  }

  void _toggleFollow(BuildContext context, WidgetRef ref, CreatorProfile p) {
    final following = ref.read(followingProvider.notifier).toggle(p.id);
    if (following) {
      showStarToast(
        context,
        'Following · their posts will appear in your feed',
      );
    }
  }

  static Future<void> _share(BuildContext context, CreatorProfile p) {
    return showStarShareSheet(
      context,
      title: 'Share profile',
      subtitle: '${p.name} · @${p.handle}',
      link: p.profileLink,
      linkCaption: "${p.firstName}'s public profile link",
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({
    required this.profile,
    required this.onFollowToggle,
    required this.onMessage,
  });

  final CreatorProfile profile;
  final VoidCallback onFollowToggle;
  final VoidCallback onMessage;

  static const _motion = Duration(milliseconds: 240);

  void _openChallenge(BuildContext context, CreatorChallengeEntry entry) {
    switch (entry.status) {
      // Both live in the Challenges tab.
      case CreatorChallengeStatus.live:
        context.go(AppRoutes.challengesLeaderboard);
      case CreatorChallengeStatus.upcoming:
        context.go(AppRoutes.challengesUpcoming);
      case CreatorChallengeStatus.finished:
        context.push(AppRoutes.challengeWinners);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final following = ref.watch(
      followingProvider.select((ids) => ids.contains(profile.id)),
    );
    final posts = creatorPostsProvider(profile.id);
    final featured = profile.featuredChallenge;
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return NotificationListener<ScrollUpdateNotification>(
      // Fetch the next page of posts as the end comes into view.
      onNotification: (scroll) {
        if (scroll.metrics.extentAfter < 400) {
          ref.read(posts.notifier).loadMore();
        }
        return false;
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 5, bottom: bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CreatorHero(
              profile: profile,
              onOpenStory: () =>
                  context.push('${AppRoutes.story}?creator=${profile.id}'),
              actions: AnimatedSwitcher(
                duration: _motion,
                child: following
                    ? CreatorCompactActions(
                        onUnfollow: onFollowToggle,
                        onMessage: onMessage,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
            CreatorIdentity(profile: profile),
            const SizedBox(height: 16),
            CreatorStatsCard(
              stars: formatCompact(profile.stars),
              followers: formatCompact(
                profile.followersWhen(following: following),
              ),
              following: formatCompact(profile.following),
              wins: '${profile.wins}',
              onFollowers: () =>
                  context.pushCreatorConnections(profile.id, following: false),
              onFollowing: () =>
                  context.pushCreatorConnections(profile.id, following: true),
            ),
            AnimatedSize(
              duration: _motion,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              // Keeps the Follow button's shadow.
              clipBehavior: Clip.none,
              child: AnimatedSwitcher(
                duration: _motion,
                child: following
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: CreatorActionsRow(
                          onFollow: onFollowToggle,
                          onMessage: onMessage,
                        ),
                      ),
              ),
            ),
            if (featured != null) ...[
              const SizedBox(height: 16),
              CreatorChallengeBanner(
                text: featured.headline,
                onTap: () => _openChallenge(context, featured),
              ),
            ],
            const SizedBox(height: 16),
            CreatorContentTabs(
              profile: profile,
              posts: ref.watch(posts),
              onRetryPosts: () => ref.invalidate(posts),
              onOpenPost: (_) => context.push(AppRoutes.videos),
              onOpenChallenge: (entry) => _openChallenge(context, entry),
            ),
          ],
        ),
      ),
    );
  }
}
