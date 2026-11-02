import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/home/data/models/trending_talent.dart';
import 'package:starapp/features/home/presentation/widgets/feed_primitives.dart';
import 'package:starapp/features/home/presentation/widgets/home_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _cardWidth = 136.0;
const _cardHeight = 190.0;
const _postedInk = Color(0xFFEEEEEE);
const _videoScrim = Color(0x42000000); // black @ 26%
const _captionFade = Color(0x96000000); // black @ 59%

/// "Trending Talents": a clipped horizontal row of short videos ending in a
/// "View all" card, framed by hairlines above and below.
class TrendingTalents extends StatelessWidget {
  const TrendingTalents({
    super.key,
    required this.talents,
    this.onViewAll,
    this.onAuthorTap,
  });

  final List<TrendingTalent> talents;
  final VoidCallback? onViewAll;
  final ValueChanged<TrendingTalent>? onAuthorTap;

  static const _hairline = BorderSide(
    color: AppColors.borderDefault,
    width: 1.05,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: _hairline, bottom: _hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Talents',
            style: TextStyle(
              fontSize: 14,
              height: 10 / 14,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              color: AppColors.brandNavy,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: _cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: talents.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                if (i == talents.length) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: FeedViewAllCard(
                      background: HomeIcons.trendingViewAllBg,
                      height: 188.598,
                      labelTop: 86.49,
                      onTap: onViewAll,
                    ),
                  );
                }
                final talent = talents[i];
                return TrendingTalentCard(
                  talent: talent,
                  onAuthorTap: onAuthorTap == null
                      ? null
                      : () => onAuthorTap!(talent),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _Playback { playing, paused, resuming }

/// One trending video. Tapping it walks the design's Play and Pause states:
/// playing → paused (pause glyph) → resuming (play glyph, 200ms) → playing.
class TrendingTalentCard extends StatefulWidget {
  const TrendingTalentCard({super.key, required this.talent, this.onAuthorTap});

  final TrendingTalent talent;
  final VoidCallback? onAuthorTap;

  @override
  State<TrendingTalentCard> createState() => _TrendingTalentCardState();
}

class _TrendingTalentCardState extends State<TrendingTalentCard> {
  _Playback _playback = _Playback.playing;
  Timer? _resume;

  void _toggle() {
    _resume?.cancel();
    if (_playback == _Playback.paused) {
      setState(() => _playback = _Playback.resuming);
      _resume = Timer(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _playback = _Playback.playing);
      });
    } else {
      setState(() => _playback = _Playback.paused);
    }
  }

  @override
  void dispose() {
    _resume?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final talent = widget.talent;
    final paused = _playback != _Playback.playing;

    return Semantics(
      button: true,
      label: '${talent.author.name} video',
      value: _playback == _Playback.paused ? 'Paused' : 'Playing',
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: _cardWidth,
          height: _cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderDefault, width: 1.05),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: StarImage(talent.coverUrl)),
                // Play and Pause overlay.
                Positioned(
                  left: 0.95,
                  top: -2.45,
                  width: 132,
                  height: 192,
                  child: AnimatedOpacity(
                    opacity: paused ? 1 : 0,
                    duration: const Duration(milliseconds: 120),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _videoScrim,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          _playback == _Playback.resuming
                              ? HomeIcons.playCircle
                              : HomeIcons.pauseCircle,
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: -1.1,
                  height: 189,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 8,
                    ),
                    alignment: Alignment.bottomLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00FFFFFF), _captionFade],
                        stops: [0.5484, 0.99699],
                      ),
                    ),
                    child: GestureDetector(
                      onTap: widget.onAuthorTap,
                      behavior: HitTestBehavior.opaque,
                      child: _AuthorRow(talent: talent),
                    ),
                  ),
                ),
                if (talent.tag.isNotEmpty)
                  Positioned(
                    left: 77.95,
                    top: 6.55,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          // The design has one tag style.
                          color: AppColors.tagActing,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          talent.tag,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 5,
                            height: feedLeading,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.talent});

  final TrendingTalent talent;

  @override
  Widget build(BuildContext context) {
    final author = talent.author;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RoundAvatar(
          url: author.avatarUrl,
          size: 19,
          ringWidth: 0.5,
          ringGap: 1,
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 6,
                        height: feedLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lunarWhite,
                      ),
                    ),
                  ),
                  if (author.isVerified) ...[
                    const SizedBox(width: 1),
                    SvgPicture.asset(
                      HomeIcons.verifiedLightXs,
                      width: 7,
                      height: 7,
                    ),
                  ],
                  // Creators carry a tier; fans don't.
                  if (author.tier != null) ...[
                    const SizedBox(width: 1),
                    SvgPicture.asset(
                      HomeIcons.creatorBadgeLight,
                      width: 6,
                      height: 5,
                    ),
                  ],
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    HomeIcons.worldLight,
                    width: 5.5,
                    height: 5.5,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Posted ${formatPostedAt(talent.createdAt)}',
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 5,
                      height: 2,
                      letterSpacing: 0,
                      color: _postedInk,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
