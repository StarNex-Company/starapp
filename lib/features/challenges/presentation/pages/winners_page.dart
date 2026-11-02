import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/winners.dart';
import 'package:starapp/features/challenges/data/provider/challenges_providers.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_celebration_style.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_gold_button.dart';
import 'package:starapp/features/challenges/presentation/widgets/winners_avatar.dart';
import 'package:starapp/features/challenges/presentation/widgets/winners_confetti.dart';
import 'package:starapp/features/challenges/presentation/widgets/winners_entry_card.dart';
import 'package:starapp/features/challenges/presentation/widgets/winners_prize_card.dart';
import 'package:starapp/features/challenges/presentation/widgets/winners_runner_up_tile.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _spotlightAsset = 'assets/vectors/challenges/winners_spotlight.svg';
const _tierStarIcon = 'assets/vectors/challenges/winners_ic_star_pill.svg';
const _playIcon = 'assets/vectors/challenges/winners_ic_play.svg';

const _tierPillBg = Color(0x24E7A91A); // e7a91a @ 14%
const _tierPillText = Color(0xFF92400E);
const _barShadow = Color(0x290B1020); // 0b1020 @ 16%

/// Full-screen "And the winner is…" celebration for a finished challenge:
/// confetti drops in, then the winner, prize, winning entry and runners-up
/// fade in. The celebration starts once the results have loaded.
class WinnersPage extends ConsumerStatefulWidget {
  const WinnersPage({
    super.key,
    this.challengeId = defaultWinnersChallengeId,
    this.animate = true,
  });

  /// The finished challenge.
  final String challengeId;

  /// Plays the entrance and confetti. When false (or when the platform asks
  /// to reduce motion) the settled screen is shown straight away.
  final bool animate;

  @override
  ConsumerState<WinnersPage> createState() => _WinnersPageState();
}

class _WinnersPageState extends ConsumerState<WinnersPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final CurvedAnimation _content;
  late final Animation<Offset> _contentSlide;
  late final CurvedAnimation _bar;

  bool get _loaded =>
      ref.read(challengeWinnersProvider(widget.challengeId)).hasValue;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      value: widget.animate ? 0 : 1,
    );
    _content = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    );
    _contentSlide = Tween(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(_content);
    _bar = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
    );
    ref.listenManual(challengeWinnersProvider(widget.challengeId), (_, next) {
      if (next.hasValue) _syncIntro();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncIntro();
  }

  void _syncIntro() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
    } else if (_intro.isDismissed && _loaded) {
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _content.dispose();
    _bar.dispose();
    _intro.dispose();
    super.dispose();
  }

  void _comingSoon() {
    showStarToast(context, 'Coming soon');
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final provider = challengeWinnersProvider(widget.challengeId);
    final winners = ref.watch(provider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: celebrationBackground,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned(
                top: -80,
                left: 0,
                right: 0,
                height: 520,
                child: OverflowBox(
                  maxWidth: 520,
                  child: SvgPicture.asset(
                    _spotlightAsset,
                    width: 520,
                    height: 520,
                  ),
                ),
              ),
              Positioned.fill(
                // Leaves room for the close button row.
                top: topInset + 50,
                child: FadeTransition(
                  opacity: _content,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: StarAsyncView(
                      value: winners,
                      onRetry: () => ref.invalidate(provider),
                      builder: (winners) => _Results(
                        winners: winners,
                        onPlayEntry: _comingSoon,
                        onCreator: context.pushCreator,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: winners.hasValue
                    ? WinnersConfetti(animate: widget.animate)
                    : const SizedBox.shrink(),
              ),
              Positioned(
                top: topInset + 8,
                left: 24,
                child: StarIconButton(
                  icon: CelebrationAssets.close,
                  background: CelebrationColors.brandWash,
                  tooltip: 'Close',
                  onPressed: _close,
                ),
              ),
            ],
          ),
          bottomNavigationBar: FadeTransition(
            opacity: _bar,
            child: _BottomBar(onShare: _comingSoon, onWatch: _comingSoon),
          ),
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.winners,
    required this.onPlayEntry,
    required this.onCreator,
  });

  final ChallengeWinners winners;
  final VoidCallback onPlayEntry;

  /// Opens a creator's profile by id.
  final ValueChanged<String> onCreator;

  @override
  Widget build(BuildContext context) {
    final challenge = winners.challenge;
    final prize = challenge.prize;
    final winner = winners.winner;
    final creator = winner.creator;
    final tier = creator.tier;
    final entry = winners.winningEntry;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        spacing: 16,
        children: [
          Text(
            '${formatLongMonth(challenge.endsAt)} · ${challenge.title}'
                .toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              height: 1.21,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
          const Text(
            'And the winner is…',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              height: 1.21,
              letterSpacing: 0,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          _CreatorTap(
            label: "View ${creator.name}'s profile",
            onTap: () => onCreator(creator.id),
            child: WinnersCrownedAvatar(photo: creator.avatarUrl),
          ),
          Column(
            spacing: 4,
            children: [
              _CreatorTap(
                onTap: () => onCreator(creator.id),
                child: Text(
                  creator.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    height: 1.21,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                joinDetails(['@${creator.handle}', winner.location]),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.21,
                  letterSpacing: 0,
                  color: CelebrationColors.textSecondary,
                ),
              ),
            ],
          ),
          if (tier != null) _TierPill(label: tier.label),
          if (prize != null)
            WinnersPrizeCard(
              title: prizeTitle(prize),
              perks: [
                for (final perk in prize.perks) '+ $perk',
                if (prize.bonusStars > 0)
                  '+ ${formatGrouped(prize.bonusStars)} bonus Stars',
              ],
            ),
          WinnersEntryCard(
            thumbnail: entry.thumbnailUrl,
            title: entry.title ?? '',
            stats:
                '${formatCompact(entry.viewCount)} views · '
                '${formatCompact(entry.stars)} Stars',
            onPlay: onPlayEntry,
          ),
          const SizedBox(
            width: double.infinity,
            child: Text(
              'Runners-up',
              style: TextStyle(
                fontSize: 16,
                height: 1.21,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          for (final runner in winners.runnersUp)
            _CreatorTap(
              onTap: () => onCreator(runner.creator.id),
              child: WinnersRunnerUpTile(
                rank: runner.rank,
                photo: runner.creator.avatarUrl,
                name: runner.creator.name,
                subtitle: joinDetails([
                  runner.location,
                  if (runner.prize case final prize?) '${prize.format()} prize',
                ]),
                stars: formatCompact(runner.stars),
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens a creator's profile from their photo, name or row.
class _CreatorTap extends StatelessWidget {
  const _CreatorTap({required this.onTap, required this.child, this.label});

  final VoidCallback onTap;
  final Widget child;

  /// For a photo, which has no text of its own.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _TierPill extends StatelessWidget {
  const _TierPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: _tierPillBg,
        borderRadius: BorderRadius.all(Radius.circular(13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(_tierStarIcon, width: 11, height: 11),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.21,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: _tierPillText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onShare, required this.onWatch});

  final VoidCallback onShare;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    // Design reserves 34px for the iPhone home indicator.
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 16.0);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.brandTintSoft,
        boxShadow: [
          BoxShadow(color: _barShadow, offset: Offset(0, -6), blurRadius: 20),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 14, 24, bottom),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              flex: 150,
              child: TierGoldButton(
                label: 'Share',
                icon: CelebrationAssets.share,
                onPressed: onShare,
              ),
            ),
            Expanded(flex: 183, child: _WatchButton(onPressed: onWatch)),
          ],
        ),
      ),
    );
  }
}

class _WatchButton extends StatelessWidget {
  const _WatchButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: CelebrationColors.brandWash,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: CelebrationColors.borderSoft),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              SvgPicture.asset(_playIcon, width: 18, height: 18),
              const Flexible(
                child: Text(
                  'Watch entry',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.21,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
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
