import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';

/// "24 hours Left" inside two days, then "6 Days Left", as the design
/// words it. Both round up, so a challenge ending in 23h 59m reads
/// "24 hours Left".
String _timeLeft(DateTime endsAt) {
  final left = endsAt.difference(DateTime.now());
  if (left <= Duration.zero) return 'Ended';
  final hours = (left.inMinutes / 60).ceil();
  if (hours < 48) return '$hours ${hours == 1 ? 'hour' : 'hours'} Left';
  return '${(hours / 24).ceil()} Days Left';
}

/// 300×286 dark arena banner: arena tag, time left, title, blurb, prize and
/// submission stats, and the Enter / View Details actions.
class FeaturedChallengeCard extends StatelessWidget {
  const FeaturedChallengeCard({
    super.key,
    required this.challenge,
    required this.onOpen,
    required this.onEnter,
  });

  static const width = 300.0;
  static const height = 286.0;
  static const _radius = BorderRadius.all(Radius.circular(16));

  final FeaturedChallenge challenge;

  /// Card, title and "View Details".
  final VoidCallback onOpen;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final gold = challenge.tone == ArenaTone.gold;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: gold ? DiscoverColors.arenaGoldBg : DiscoverColors.arenaNavyBg,
        borderRadius: _radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onOpen,
            child: Stack(
              children: [
                const Positioned(
                  right: -40,
                  bottom: -39.5,
                  child: _Aura(
                    size: 192,
                    color: DiscoverColors.brand,
                    opacity: 0.5,
                  ),
                ),
                const Positioned(
                  left: -48,
                  top: -48,
                  child: _Aura(
                    size: 160,
                    color: DiscoverColors.starGold,
                    opacity: 0.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 8,
                        children: [
                          _Pill(
                            color: DiscoverColors.arenaPill,
                            spacing: 6,
                            icon: gold
                                ? DiscoverIcons.arenaLight
                                : DiscoverIcons.arenaGold,
                            label: challenge.arena.toUpperCase(),
                            style: discoverText(
                              10,
                              FontWeight.w800,
                              gold
                                  ? DiscoverColors.arenaPillText
                                  : DiscoverColors.starGold,
                              lineHeight: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          _Pill(
                            color: DiscoverColors.glass10,
                            spacing: 4,
                            icon: DiscoverIcons.clock,
                            label: _timeLeft(challenge.endsAt),
                            style: discoverText(
                              10,
                              FontWeight.w600,
                              Colors.white,
                              lineHeight: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 4,
                        children: [
                          SizedBox(
                            height: 52,
                            child: Text(
                              challenge.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: discoverText(
                                16,
                                FontWeight.w800,
                                Colors.white,
                                lineHeight: 26,
                                letterSpacing: -0.45,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 36,
                            child: Text(
                              challenge.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: discoverText(
                                10,
                                FontWeight.w400,
                                DiscoverColors.arenaMuted,
                                lineHeight: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _StatsBar(challenge: challenge),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          spacing: 10,
                          children: [
                            Expanded(child: _EnterButton(onTap: onEnter)),
                            _ViewDetailsButton(onTap: onOpen),
                          ],
                        ),
                      ),
                    ],
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

/// Soft blurred glow behind the banner content.
class _Aura extends StatelessWidget {
  const _Aura({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 32,
          sigmaY: 32,
          tileMode: TileMode.decal,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.color,
    required this.spacing,
    required this.icon,
    required this.label,
    required this.style,
  });

  final Color color;
  final double spacing;
  final String icon;
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    // Shares its row with another pill; shrinks rather than overflow.
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing,
            children: [
              SvgPicture.asset(icon),
              Text(label, style: style),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.challenge});

  final FeaturedChallenge challenge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      decoration: BoxDecoration(
        color: DiscoverColors.glass10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: _Stat(
              icon: DiscoverIcons.prize,
              iconBackground: DiscoverColors.arenaPill,
              label: 'Prize Pool',
              value: challenge.prizePool.format(),
              valueStyle: discoverText(
                16,
                FontWeight.w800,
                DiscoverColors.starGold,
                lineHeight: 22.5,
              ),
            ),
          ),
          Expanded(
            child: _Stat(
              icon: DiscoverIcons.submissions,
              iconBackground: DiscoverColors.glass10,
              label: 'Submissions',
              value: formatGrouped(challenge.submissions),
              valueStyle: discoverText(
                16,
                FontWeight.w700,
                Colors.white,
                lineHeight: 22.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.iconBackground,
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  final String icon;
  final Color iconBackground;
  final String label;
  final String value;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(icon),
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 1,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: discoverText(
                  9,
                  FontWeight.w700,
                  DiscoverColors.arenaMuted,
                  lineHeight: 10,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.onTap});

  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x4DFDBF47),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x4DFDBF47),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: DiscoverColors.starGold,
        borderRadius: _radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                SvgPicture.asset(DiscoverIcons.enter),
                Flexible(
                  child: Text(
                    'Enter Challenge',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: discoverText(
                      13,
                      FontWeight.w700,
                      DiscoverColors.enterText,
                      lineHeight: 20,
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

class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DiscoverColors.glass15,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            'View Details',
            style: discoverText(
              13,
              FontWeight.w600,
              Colors.white,
              lineHeight: 20,
            ),
          ),
        ),
      ),
    );
  }
}
