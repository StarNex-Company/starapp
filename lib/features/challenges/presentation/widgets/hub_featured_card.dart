import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/features/challenges/presentation/widgets/hub_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _navy = Color(0xFF001759);
const _navyClear = Color(0x00001759);
const _gold = Color(0xFFFDBF47);
const _goldMid = Color(0xFFFABC45);
const _goldInk = Color(0xFF704E00);
const _goldPale = Color(0xFFFFDEA9);
const _periwinkle = Color(0xFFDDE1FF);
const _periwinkleDim = Color(0xFFB7C4FF);
const _blueStars = Color(0xFF7E96F7);
const _pillDark = Color(0xD92D3133); // rgba(45, 49, 51, 0.85)
const _pillText = Color(0xFFEFF1F3);
const _labelDark = Color(0xE626334F); // rgba(38, 51, 79, 0.9)
const _track = Color(0x33E0E3E5); // rgba(224, 227, 229, 0.2)
const _muted = Color(0xFFE0E3E5); // surface/muted/e0e3e5
const _body = Color(0xFF444652); // text/body/444652
const _white5 = Color(0x0DFFFFFF);
const _white10 = Color(0x1AFFFFFF);
const _white15 = Color(0x26FFFFFF);

/// Navy hero card for the featured arena: cover photo with badges, title,
/// prize, capacity meter, the live top three and the "Enter Challenge" CTA.
///
/// The card body and CTA call [onOpen]; the standings box and the chart
/// button call [onStandings].
class HubFeaturedCard extends StatelessWidget {
  const HubFeaturedCard({
    super.key,
    required this.photo,
    required this.category,
    required this.title,
    required this.prize,
    required this.endsIn,
    required this.entries,
    required this.capacity,
    required this.podium,
    required this.refreshedLabel,
    required this.onOpen,
    required this.onStandings,
  });

  /// Cover image URL.
  final String? photo;
  final String category;
  final String title;
  final String prize;

  /// e.g. "4d 18h".
  final String endsIn;
  final int entries;
  final int capacity;

  /// The live top three.
  final List<LeaderboardEntry> podium;

  /// When the standings last changed, e.g. "2m ago".
  final ValueListenable<String> refreshedLabel;
  final VoidCallback onOpen;
  final VoidCallback onStandings;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 20),
            blurRadius: 25,
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 8),
            blurRadius: 10,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Material(
        color: _navy,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Cover(photo: photo, category: category, endsIn: endsIn),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14.875, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 4,
                      children: [
                        Semantics(
                          header: true,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 0.625),
                            child: Text(
                              title.toUpperCase(),
                              style: hubText(
                                15,
                                FontWeight.w800,
                                Colors.white,
                                lineHeight: 24.75,
                                tracking: -0.45,
                              ),
                            ),
                          ),
                        ),
                        _PrizeBadge(prize: prize),
                      ],
                    ),
                    _CapacityMeter(entries: entries, capacity: capacity),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _Standings(
                        podium: podium,
                        refreshedLabel: refreshedLabel,
                        onTap: onStandings,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        spacing: 8,
                        children: [
                          Expanded(child: _EnterButton(onPressed: onOpen)),
                          _StandingsButton(onPressed: onStandings),
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
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({
    required this.photo,
    required this.category,
    required this.endsIn,
  });

  final String? photo;
  final String category;
  final String endsIn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 192,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The design scales the photo slightly past the card's edges.
          Positioned(
            left: -8.95,
            right: -8.95,
            top: -4.8,
            bottom: -4.8,
            child: Opacity(opacity: 0.85, child: StarImage(photo)),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [_navy, _navyClear],
                stops: [0, 0.36058],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              // Pills shrink rather than overflow at large text sizes.
              children: [
                const Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _FeaturedPill(),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _EndsPill(endsIn: endsIn),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: _CategoryLabel(category: category),
          ),
        ],
      ),
    );
  }
}

class _FeaturedPill extends StatelessWidget {
  const _FeaturedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _gold,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          SvgPicture.asset(HubIcons.featured, width: 9.33333, height: 12.25),
          Text(
            'Featured Arena',
            style: hubText(
              10,
              FontWeight.w500,
              _goldInk,
              lineHeight: 14,
              tracking: 0.25,
            ),
          ),
        ],
      ),
    );
  }
}

/// Translucent pill that blurs the photo behind it.
class _GlassPill extends StatelessWidget {
  const _GlassPill({
    required this.color,
    required this.radius,
    required this.padding,
    required this.child,
    this.height,
  });

  final Color color;
  final double radius;
  final EdgeInsets padding;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          height: height,
          padding: padding,
          color: color,
          child: child,
        ),
      ),
    );
  }
}

class _EndsPill extends StatelessWidget {
  const _EndsPill({required this.endsIn});

  final String endsIn;

  @override
  Widget build(BuildContext context) {
    return _GlassPill(
      color: _pillDark,
      radius: 99,
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(HubIcons.timer, width: 11.6667, height: 11.6667),
          Text(
            'Ends in $endsIn',
            style: hubText(
              10,
              FontWeight.w600,
              _pillText,
              lineHeight: 14,
              tracking: -0.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return _GlassPill(
      color: _labelDark,
      radius: 4,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Text(
        category.toUpperCase(),
        style: hubText(
          10,
          FontWeight.w500,
          _periwinkle,
          lineHeight: 14,
          tracking: 0.5,
        ),
      ),
    );
  }
}

class _PrizeBadge extends StatelessWidget {
  const _PrizeBadge({required this.prize});

  final String prize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          spacing: 6,
          children: [
            SvgPicture.asset(HubIcons.prize, width: 13.3333, height: 13.3333),
            Expanded(
              child: Text(
                prize,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: hubText(9, FontWeight.w700, _goldPale, lineHeight: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapacityMeter extends StatelessWidget {
  const _CapacityMeter({required this.entries, required this.capacity});

  final int entries;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final filled = capacity == 0 ? 0.0 : (entries / capacity).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Row(
            spacing: 4,
            children: [
              SvgPicture.asset(HubIcons.group, width: 12.8333, height: 9.33333),
              Expanded(
                child: Text(
                  'Capacity: ${formatGrouped(entries)} / ${formatGrouped(capacity)} Entries',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: hubText(
                    12,
                    FontWeight.w400,
                    _periwinkle,
                    lineHeight: 18,
                  ),
                ),
              ),
              Text(
                '${(filled * 100).round()}% Filled',
                style: hubText(10, FontWeight.w700, _gold, lineHeight: 14),
              ),
            ],
          ),
          Semantics(
            label: 'Capacity',
            value: '${(filled * 100).round()}%',
            child: Container(
              height: 8,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _track,
                borderRadius: BorderRadius.circular(99),
              ),
              // Fills up once when the card first appears.
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: filled),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                      gradient: LinearGradient(
                        colors: [_gold, _goldMid, _gold],
                      ),
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

class _Standings extends StatelessWidget {
  const _Standings({
    required this.podium,
    required this.refreshedLabel,
    required this.onTap,
  });

  final List<LeaderboardEntry> podium;
  final ValueListenable<String> refreshedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _white5,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Row(
                spacing: 4,
                children: [
                  SvgPicture.asset(
                    HubIcons.crown,
                    width: 11.6667,
                    height: 10.5,
                  ),
                  Expanded(
                    child: Text(
                      'LIVE PODIUM STANDINGS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hubText(
                        9,
                        FontWeight.w500,
                        _periwinkle,
                        lineHeight: 14,
                        tracking: 0.5,
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: refreshedLabel,
                    builder: (context, label, _) => Text(
                      'Refreshed $label',
                      style: hubText(
                        9,
                        FontWeight.w500,
                        _periwinkleDim,
                        lineHeight: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  for (final entry in podium) _PodiumRow(entry: entry),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumRow extends StatelessWidget {
  const _PodiumRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final rank = entry.rank;
    final leader = rank == 1;
    final title = entry.entryTitle;
    final subtitle = joinDetails([
      entry.location,
      if (title != null) "'$title'",
    ], separator: ' • ');
    return Semantics(
      label: '#$rank ${entry.creator.name}, $subtitle, ${entry.stars} Stars',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: leader ? _white10 : _white5,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: leader ? _gold : _muted,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: hubText(
                  9,
                  FontWeight.w600,
                  leader ? _goldInk : _body,
                  lineHeight: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            StarAvatar(entry.creator.avatarUrl, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.creator.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: hubText(
                      11,
                      FontWeight.w500,
                      Colors.white,
                      lineHeight: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: hubText(
                      9,
                      FontWeight.w500,
                      _periwinkleDim,
                      lineHeight: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatGrouped(entry.stars),
              style: hubText(
                10,
                FontWeight.w500,
                leader ? _goldPale : _blueStars,
                lineHeight: 16,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(
              leader ? HubIcons.starGold : HubIcons.starBlue,
              width: 12.5,
              height: 11.875,
            ),
          ],
        ),
      ),
    );
  }
}

class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FDBF47),
            offset: Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x33FDBF47),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: _gold,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                SvgPicture.asset(HubIcons.bolt, width: 15, height: 16.6667),
                Flexible(
                  child: Text(
                    'Enter Challenge',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: hubText(
                      18,
                      FontWeight.w600,
                      _goldInk,
                      lineHeight: 26,
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

class _StandingsButton extends StatelessWidget {
  const _StandingsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Live standings',
      child: Material(
        color: _white15,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox.square(
            dimension: 40,
            child: Center(
              child: SvgPicture.asset(
                HubIcons.leaderboard,
                width: 15,
                height: 13.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
