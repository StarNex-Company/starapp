import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/moderation/data/models/moderation_case.dart';
import 'package:starapp/features/moderation/data/provider/moderation_providers.dart';
import 'package:starapp/features/moderation/presentation/widgets/paused_emblem.dart';
import 'package:starapp/features/moderation/presentation/widgets/paused_next_steps.dart';
import 'package:starapp/features/moderation/presentation/widgets/paused_post_card.dart';
import 'package:starapp/shared/widgets/shared_icons.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Why one of the creator's posts was paused, and what they can do about it.
class ContentPausedPage extends ConsumerWidget {
  const ContentPausedPage({super.key, this.caseId = defaultModerationCaseId});

  /// The moderation case, e.g. "SA-48213".
  final String caseId;

  void _comingSoon(BuildContext context) {
    showStarToast(context, 'Coming soon');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = moderationCaseProvider(caseId);
    final paused = ref.watch(provider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Content Notice',
        leading: const StarBackButton(),
        trailing: StarIconButton.info(onPressed: () => _comingSoon(context)),
      ),
      // Design text uses Inter's normal line height and no tracking.
      body: DefaultTextStyle.merge(
        style: const TextStyle(height: 1.21, letterSpacing: 0),
        child: StarAsyncView(
          value: paused,
          onRetry: () => ref.invalidate(provider),
          builder: (paused) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              spacing: 20,
              children: [
                const PausedEmblem(),
                const Text(
                  'Your post was paused',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: const Text(
                    "It may contain copyrighted music, so it's hidden from the feed "
                    'and leaderboards while we take a closer look.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 21 / 14,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ),
                PausedPostCard(
                  thumbnail: paused.post.thumbnailUrl,
                  title: paused.post.title,
                  meta: _meta(paused.post),
                  details: [
                    (label: 'Reason', value: paused.reason),
                    if (paused.guideline.isNotEmpty)
                      (label: 'Guideline', value: paused.guideline),
                    if (paused.visibility.isNotEmpty)
                      (label: 'Visibility', value: paused.visibility),
                  ],
                ),
                PausedNextSteps(steps: paused.nextSteps),
                PausedGuidelinesLink(onTap: () => _comingSoon(context)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: StarBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            StarPrimaryButton(
              label: 'Submit an appeal',
              onPressed: () =>
                  context.push('${AppRoutes.moderationAppeal}?id=$caseId'),
            ),
            StarOutlinedButton(
              label: 'Replace audio',
              leadingIcon: SharedIcons.music,
              onPressed: () => _comingSoon(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Posted Oct 8 · 2.1K views"; the year shows once it isn't this one.
String _meta(ModeratedPost post) {
  final posted = post.postedAt;
  final date = posted.year == DateTime.now().year
      ? DateFormat('MMM d').format(posted)
      : DateFormat('MMM d, y').format(posted);
  return 'Posted $date · ${formatCompact(post.viewCount)} views';
}
