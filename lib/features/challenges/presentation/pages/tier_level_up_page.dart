import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/tier.dart';
import 'package:starapp/features/challenges/data/provider/challenges_providers.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_celebration_style.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_emblem.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_gold_button.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_perks_card.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_progress.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _auraAsset = 'assets/vectors/challenges/tier_aura.svg';
const _sparkleIcon = 'assets/vectors/challenges/tier_ic_sparkle.svg';

/// Full-screen celebration shown when the user reaches a new tier: the tier
/// star spins out of a violet aura, sparkles twinkle around it and the tier
/// details, perks and progress to the next tier fade in. The reveal starts
/// once the tier has loaded.
class TierLevelUpPage extends ConsumerStatefulWidget {
  const TierLevelUpPage({super.key, this.animate = true});

  /// Plays the reveal and twinkling. When false (or when the platform asks
  /// to reduce motion) the settled screen is shown straight away.
  final bool animate;

  @override
  ConsumerState<TierLevelUpPage> createState() => _TierLevelUpPageState();
}

class _TierLevelUpPageState extends ConsumerState<TierLevelUpPage>
    with TickerProviderStateMixin {
  late final _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
    value: widget.animate ? 0 : 1,
  )..addStatusListener(_onRevealStatus);
  // Created up front: it may never start, but dispose still touches it.
  late final AnimationController _twinkle;

  // The aura swells as the star lands, then settles.
  late final _auraScale = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.08,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.08,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 45,
    ),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
  ]).animate(_reveal);
  late final _message = CurvedAnimation(
    parent: _reveal,
    curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
  );
  late final _messageSlide = Tween(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).animate(_message);
  late final _bar = CurvedAnimation(
    parent: _reveal,
    curve: const Interval(0.6, 1, curve: Curves.easeOut),
  );

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  bool get _loaded => ref.read(tierLevelUpProvider).hasValue;

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );
    ref.listenManual(tierLevelUpProvider, (_, next) {
      if (next.hasValue) _syncMotion();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void _syncMotion() {
    if (_reduceMotion) {
      _twinkle
        ..stop()
        ..value = 0;
      _reveal.value = 1;
    } else if (_reveal.isDismissed) {
      if (_loaded) _reveal.forward();
    } else if (widget.animate && _reveal.isCompleted && !_twinkle.isAnimating) {
      _twinkle.repeat();
    }
  }

  void _onRevealStatus(AnimationStatus status) {
    if (status.isCompleted && widget.animate && !_reduceMotion) {
      _twinkle.repeat();
    }
  }

  @override
  void dispose() {
    _message.dispose();
    _bar.dispose();
    _reveal.dispose();
    _twinkle.dispose();
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
    final levelUp = ref.watch(tierLevelUpProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: celebrationBackground,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned(
                top: -40,
                left: 0,
                right: 0,
                height: 560,
                child: OverflowBox(
                  maxWidth: 560,
                  child: ScaleTransition(
                    scale: _auraScale,
                    child: SvgPicture.asset(
                      _auraAsset,
                      width: 560,
                      height: 560,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: StarAsyncView(
                  value: levelUp,
                  onRetry: () => ref.invalidate(tierLevelUpProvider),
                  builder: (levelUp) => _Celebration(
                    levelUp: levelUp,
                    topInset: topInset,
                    reveal: _reveal,
                    twinkle: _twinkle,
                    message: _message,
                    messageSlide: _messageSlide,
                  ),
                ),
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
            child: _BottomBar(onShare: _comingSoon, onViewProfile: _comingSoon),
          ),
        ),
      ),
    );
  }
}

/// The emblem, then the tier's name, blurb, perks and progress.
class _Celebration extends StatelessWidget {
  const _Celebration({
    required this.levelUp,
    required this.topInset,
    required this.reveal,
    required this.twinkle,
    required this.message,
    required this.messageSlide,
  });

  final TierLevelUp levelUp;
  final double topInset;
  final Animation<double> reveal;
  final Animation<double> twinkle;
  final Animation<double> message;
  final Animation<Offset> messageSlide;

  @override
  Widget build(BuildContext context) {
    final tier = levelUp.tier;
    final next = tier.next;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, topInset + 34, 24, 24),
      child: Column(
        children: [
          TierEmblem(tier: tier.level, reveal: reveal, twinkle: twinkle),
          FadeTransition(
            opacity: message,
            child: SlideTransition(
              position: messageSlide,
              child: Column(
                spacing: 8,
                children: [
                  const _LevelUpPill(),
                  const Text(
                    "You've reached",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.21,
                      letterSpacing: 0,
                      color: CelebrationColors.textSecondary,
                    ),
                  ),
                  Text(
                    tier.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 40,
                      height: 1.21,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    'Tier ${tier.level} · ${formatGrouped(levelUp.minStars)} – '
                    '${formatGrouped(levelUp.maxStars)} Stars',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.21,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
                      color: CelebrationColors.textSecondary,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      levelUp.blurb,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 22 / 15,
                        letterSpacing: 0,
                        color: CelebrationColors.textSecondary,
                      ),
                    ),
                  ),
                  TierPerksCard(perks: levelUp.perks),
                  if (next != null)
                    TierNextProgress(
                      nextTier: next.label,
                      countLabel:
                          '${formatGrouped(levelUp.stars)} / '
                          '${formatGrouped(levelUp.maxStars + 1)}',
                      progress: levelUp.progress,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelUpPill extends StatelessWidget {
  const _LevelUpPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        gradient: celebrationGold,
        borderRadius: BorderRadius.all(Radius.circular(13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(_sparkleIcon, width: 11, height: 11),
          const Text(
            'LEVEL UP',
            style: TextStyle(
              fontSize: 11,
              height: 1.21,
              letterSpacing: 0.44,
              fontWeight: FontWeight.w600,
              color: AppColors.inkDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onShare, required this.onViewProfile});

  final VoidCallback onShare;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    // Design reserves 34px for the iPhone home indicator.
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 16.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 14, 24, bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          TierGoldButton(
            label: 'Share my new tier',
            icon: CelebrationAssets.share,
            onPressed: onShare,
          ),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                onTap: onViewProfile,
                child: const Center(
                  child: Text(
                    'View my profile',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
