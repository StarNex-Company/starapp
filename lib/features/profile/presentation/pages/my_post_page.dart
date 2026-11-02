import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/profile/data/models/my_post.dart';
import 'package:starapp/features/profile/data/provider/my_post_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/my_post_top_bar.dart';
import 'package:starapp/features/profile/presentation/widgets/my_post_view.dart';
import 'package:starapp/features/profile/presentation/widgets/post_menu_sheet.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_share_sheet.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// The signed-in user's own video post, full screen (Figma "Post — My
/// Video"): Insights instead of Follow, the star/comment/share/save rail and
/// the ••• post menu. Opens over the shell at `AppRoutes.post?id=<postId>`,
/// so it has no bottom navigation. Unknown ids show the user's first post.
class MyPostPage extends ConsumerStatefulWidget {
  const MyPostPage({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends ConsumerState<MyPostPage> {
  bool _muted = false;
  double _volume = 0.8;

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.profile);

  void _comingSoon() => showStarToast(context, 'Coming soon');

  // The creator here is the user, so their avatar and name open Profile.
  void _openProfile() => context.go(AppRoutes.profile);

  // Full screen over the tabs, so Insights (inside the Profile tab) is
  // reached with `go`.
  void _openInsights() => context.go(AppRoutes.profileInsights);

  void _share(MyPost post) => showStarShareSheet(
    context,
    title: 'Share post',
    subtitle: post.title,
    link: 'starapp.io/p/${post.id}',
    linkCaption: 'Link to your post',
  );

  void _toggleMute() {
    setState(() {
      if (_muted || _volume == 0) {
        _muted = false;
        if (_volume == 0) _volume = 0.8;
      } else {
        _muted = true;
      }
    });
    if (_muted) showStarToast(context, 'Sound off');
  }

  void _setVolume(double v) => setState(() {
    _volume = v;
    _muted = v == 0;
  });

  void _soundSaved() =>
      showStarToast(context, 'Sound saved · use it in your next post');

  Future<void> _openMenu(MyPost post) async {
    final action = await showPostMenuSheet(context, post: post);
    if (!mounted || action == null) return;
    switch (action) {
      case PostMenuAction.insights:
        _openInsights();
      case PostMenuAction.editCaption:
        _comingSoon();
      case PostMenuAction.share:
        _share(post);
      case PostMenuAction.delete:
        try {
          await ref.read(myPostInteractionsProvider.notifier).delete(post.id);
        } catch (e) {
          if (mounted) showStarToast(context, describeError(e));
          return;
        }
        if (!mounted) return;
        showStarToast(context, 'Post deleted');
        _back();
    }
  }

  /// Runs a star or save; the change shows at once and the provider rolls it
  /// back if the server rejects it.
  Future<void> _mutate(Future<void> Function() change) async {
    try {
      await change();
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  /// "Rising Nova · Lagos" from the tier and the city part of the location.
  String _meta(CurrentUser user) {
    final city = user.location.split(',').first.trim();
    return city.isEmpty ? user.tier.label : '${user.tier.label} · $city';
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(myPostProvider(widget.postId));
    final user = ref.watch(currentUserProvider);
    final interactions = ref.watch(myPostInteractionsProvider);
    final notifier = ref.read(myPostInteractionsProvider.notifier);
    final loaded = post.value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: StarAsyncView(
                value: post,
                onRetry: () => ref.invalidate(myPostProvider(widget.postId)),
                builder: (post) => StarAsyncView(
                  value: user,
                  onRetry: () => ref.invalidate(currentUserProvider),
                  builder: (user) => MyPostView(
                    key: ValueKey(post.id),
                    post: post,
                    creatorName: user.fullName,
                    creatorMeta: _meta(user),
                    creatorAvatarUrl: user.avatarUrl,
                    creatorVerified: user.isVerified,
                    starred: interactions.isStarred(post),
                    stars: interactions.starsOf(post),
                    saved: interactions.isSaved(post),
                    saves: interactions.savesOf(post),
                    muted: _muted,
                    volume: _volume,
                    onProfile: _openProfile,
                    onInsights: _openInsights,
                    onStar: () => _mutate(() => notifier.toggleStar(post)),
                    // The comments thread isn't built for own posts yet.
                    onComments: _comingSoon,
                    onShare: () => _share(post),
                    onSave: () => _mutate(() => notifier.toggleSave(post)),
                    onSound: _soundSaved,
                    onMute: _toggleMute,
                    onVolume: _setVolume,
                    onPaused: () =>
                        showStarToast(context, 'Paused · tap again to play'),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: MyPostTopBar(
                onBack: _back,
                onMenu: loaded == null ? null : () => _openMenu(loaded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
