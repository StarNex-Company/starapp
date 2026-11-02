// The white content panel starts 40px above the bottom of the 320px hero.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/provider/challenges_providers.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_rules_sheet.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_countdown.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_hero.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_icons.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_overview.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_sections.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _heroHeight = 320.0;
const _panelTop = 280.0;

/// Full-screen page for one challenge: prize, stats, live entry countdown,
/// rules, inspiration and the current top three.
class ChallengeDetailPage extends ConsumerStatefulWidget {
  const ChallengeDetailPage({
    super.key,
    this.challengeId = defaultChallengeId,
    this.ticking = true,
  });

  final String challengeId;

  /// Counts the time left down once a second. Turn off for still renders.
  final bool ticking;

  @override
  ConsumerState<ChallengeDetailPage> createState() =>
      _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends ConsumerState<ChallengeDetailPage> {
  /// The clock the countdown reads; ticks once a second.
  final _now = ValueNotifier(DateTime.now());
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.ticking) {
      _ticker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _now.value = DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _now.dispose();
    super.dispose();
  }

  void _comingSoon() {
    showStarToast(context, 'Coming soon');
  }

  void _openLeaderboard() => context.go(
    '${AppRoutes.challengesLeaderboard}?challenge=${widget.challengeId}',
  );

  Future<void> _toggleSaved() async {
    try {
      await ref
          .read(challengeDetailProvider(widget.challengeId).notifier)
          .toggleSaved();
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final provider = challengeDetailProvider(widget.challengeId);
    final detail = ref.watch(provider);
    final challenge = detail.value?.challenge;
    final saved = challenge?.isSaved ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: StarAsyncView(
                value: detail,
                onRetry: () => ref.invalidate(provider),
                builder: _content,
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: topInset + 10,
              child: Row(
                children: [
                  DetailGlassButton(
                    icon: DetailIcons.back,
                    iconSize: 22,
                    tooltip: 'Back',
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  DetailBookmarkButton(
                    saved: saved,
                    onPressed: challenge == null ? () {} : _toggleSaved,
                  ),
                  const SizedBox(width: 10),
                  DetailGlassButton(
                    icon: DetailIcons.share,
                    tooltip: 'Share',
                    onPressed: _comingSoon,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: challenge == null
            ? null
            : _DeadlineBar(
                deadline: formatDeadline(challenge.endsAt),
                onSubmit: () => context.push(
                  '${AppRoutes.createCamera}?challenge=${challenge.id}',
                ),
              ),
      ),
    );
  }

  /// The hero with its pills, and the white content panel over it.
  Widget _content(ChallengeDetail detail) {
    final arena = detail.challenge;
    final prize = arena.prize;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DetailHeroBackdrop(image: arena.coverUrl, height: _heroHeight),
        ),
        Positioned(
          left: 24,
          right: 24,
          top: _panelTop - 16 - 28,
          child: ValueListenableBuilder(
            valueListenable: _now,
            builder: (_, now, _) =>
                DetailHeroPills(endsIn: formatTimeLeft(arena.endsAt, now: now)),
          ),
        ),
        Positioned.fill(
          top: _panelTop,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Material(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 42),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 18,
                  children: [
                    Text(
                      arena.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: detailLeading,
                        letterSpacing: 0.72,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandBlue,
                      ),
                    ),
                    Text(
                      arena.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 31 / 26,
                        letterSpacing: 0,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    if (prize != null)
                      DetailPrizeCard(
                        prize: prizeTitle(prize),
                        perks: joinDetails([
                          for (final perk in prize.perks) '+ $perk',
                          if (prize.bonusStars > 0)
                            '+${formatGrouped(prize.bonusStars)} bonus Stars',
                        ]),
                      ),
                    DetailStatRow(
                      stats: [
                        (formatGrouped(arena.entryCount), 'Entries'),
                        (formatGrouped(arena.countryCount), 'Countries'),
                        (formatGrouped(arena.topStars), 'Top Stars'),
                      ],
                    ),
                    if (arena.capacity > 0)
                      DetailCapacityBar(
                        summary:
                            'Capacity · ${formatGrouped(arena.entryCount)} / '
                            '${formatGrouped(arena.capacity)} entries',
                        filled: arena.entryCount / arena.capacity,
                      ),
                    ValueListenableBuilder(
                      valueListenable: _now,
                      builder: (_, now, _) => DetailCountdown(
                        remaining: timeLeft(arena.endsAt, now: now),
                      ),
                    ),
                    const DetailSectionHead(title: 'About this arena'),
                    Text(
                      detail.about,
                      style: const TextStyle(
                        height: 22 / 14,
                        letterSpacing: 0,
                        fontSize: 14,
                        color: AppColors.textBody,
                      ),
                    ),
                    const DetailSectionHead(title: 'Rules'),
                    DetailRuleList(
                      rules: detail.rules,
                      onTap: () => showChallengeRulesSheet(
                        context,
                        challengeId: arena.id,
                        challengeTitle: arena.title,
                      ),
                    ),
                    DetailSectionHead(
                      title: 'Inspiration',
                      action: 'See all',
                      onAction: _comingSoon,
                    ),
                    DetailInspirationStrip(
                      items: detail.inspiration,
                      onTap: (_) => _comingSoon(),
                    ),
                    DetailSectionHead(
                      title: 'Current top 3',
                      action: 'Leaderboard',
                      onAction: _openLeaderboard,
                    ),
                    DetailTopThreeCard(
                      rankings: detail.topThree,
                      onTap: _openLeaderboard,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Deadline" with the date, and the "Submit Entry" button.
class _DeadlineBar extends StatelessWidget {
  const _DeadlineBar({required this.deadline, required this.onSubmit});

  /// e.g. "Oct 31 · 23:59 WAT".
  final String deadline;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return StarBottomBar(
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                const Text(
                  'Deadline',
                  style: TextStyle(
                    height: detailLeading,
                    letterSpacing: 0,
                    fontSize: 12,
                    color: AppColors.textSubtle,
                  ),
                ),
                Text(
                  deadline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: detailLeading,
                    letterSpacing: 0,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          StarPrimaryButton(
            label: 'Submit Entry',
            leadingIcon: DetailIcons.submitTrophy,
            width: 170,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
