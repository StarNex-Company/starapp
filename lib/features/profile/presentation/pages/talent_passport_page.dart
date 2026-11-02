import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/profile/data/models/talent_passport.dart';
import 'package:starapp/features/profile/data/provider/insights_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/features/profile/presentation/widgets/passport_best_work.dart';
import 'package:starapp/features/profile/presentation/widgets/passport_bottom_bar.dart';
import 'package:starapp/features/profile/presentation/widgets/passport_card.dart';
import 'package:starapp/features/profile/presentation/widgets/passport_metrics.dart';
import 'package:starapp/features/profile/presentation/widgets/passport_sections.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_share_sheet.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// "Profile — Talent Passport": the user's shareable card, AI score
/// breakdown, best work, challenge record, tier journey and company reviews,
/// with a sticky footer to copy or share the passport link.
class TalentPassportPage extends ConsumerWidget {
  const TalentPassportPage({super.key});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  /// The share sheet takes the link without its scheme.
  void _share(BuildContext context, String url) => showStarShareSheet(
    context,
    title: 'Share passport',
    subtitle: 'Send your Talent Passport to scouts and brands',
    link: _withoutScheme(url),
    linkCaption: 'Your Talent Passport link',
  );

  void _copy(BuildContext context, String url) {
    unawaited(Clipboard.setData(ClipboardData(text: url)));
    showStarToast(context, 'Link copied to clipboard');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passport = ref.watch(talentPassportProvider);
    final url = passport.value?.linkUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Talent Passport',
        leading: StarIconButton.back(onPressed: () => _back(context)),
        trailing: StarIconButton(
          icon: PassportIcons.share,
          tooltip: 'Share',
          onPressed: url == null ? null : () => _share(context, url),
        ),
      ),
      body: StarAsyncView(
        value: passport,
        onRetry: () => ref.invalidate(talentPassportProvider),
        builder: (passport) => _PassportContent(passport: passport),
      ),
      bottomNavigationBar: url == null
          ? null
          : PassportBottomBar(
              link: _withoutScheme(url),
              onCopy: () => _copy(context, url),
              onShare: () => _share(context, url),
            ),
    );
  }
}

/// "https://starapp.io/p/emmanuel" → "starapp.io/p/emmanuel".
String _withoutScheme(String url) =>
    url.replaceFirst(RegExp(r'^https?://'), '');

class _PassportContent extends ConsumerWidget {
  const _PassportContent({required this.passport});

  final TalentPassport passport;

  void _openPost(BuildContext context, String id) =>
      context.push('${AppRoutes.post}?id=$id');

  void _openChallenge(BuildContext context, PassportChallenge challenge) {
    switch (challenge.result) {
      case PassportChallengeResult.placed:
        context.push(AppRoutes.challengeWinners);
      // The passport sits on the root navigator, above the tabs, so pages
      // inside a tab are reached with `go`.
      case PassportChallengeResult.entered:
        context.go(AppRoutes.challengesLeaderboard);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          if (user != null) _card(user),
          PassportMetricsGrid(metrics: passport.metrics),
          if (passport.bestWork.isNotEmpty) ...[
            InsightsSectionHeader(
              title: 'Best work',
              onSeeAll: () => context.go(AppRoutes.profileTopPosts),
            ),
            PassportBestWork(
              items: passport.bestWork,
              onTap: (work) => _openPost(context, work.postId),
            ),
          ],
          if (passport.challenges.isNotEmpty) ...[
            const InsightsSectionHeader(title: 'Challenge record'),
            PassportChallengeRecord(
              items: passport.challenges,
              onTap: (c) => _openChallenge(context, c),
            ),
          ],
          if (passport.journey.isNotEmpty) ...[
            const InsightsSectionHeader(title: 'Tier journey'),
            PassportTierJourney(
              steps: passport.journey,
              onNextTap: () => context.push(AppRoutes.tierLevelUp),
            ),
          ],
          if (passport.reviews.isNotEmpty) ...[
            const InsightsSectionHeader(title: 'Company reviews'),
            for (final review in passport.reviews)
              PassportReviewCard(review: review),
          ],
        ],
      ),
    );
  }

  Widget _card(CurrentUser user) => PassportCard(
    name: user.fullName,
    handleLine: user.location.isEmpty
        ? '@${user.handle}'
        : '@${user.handle} · ${user.location}',
    avatarUrl: user.avatarUrl,
    tier: user.tier.label,
    passportId: passport.passportId,
    aiScore: passport.aiScore,
  );
}
