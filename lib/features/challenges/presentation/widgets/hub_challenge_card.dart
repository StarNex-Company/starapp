import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/presentation/widgets/hub_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _body = Color(0xFF444652); // text/body/444652
const _ink = Color(0xFF191C1E); // text/body/191c1e
const _tagBg = Color(0xFFDDE1FF); // surface/brand-tint/dde1ff
const _tagInk = Color(0xFF001452); // text/brand/001452
const _pool = Color(0xFF7D5800);
const _brand = Color(0xFF042987); // text/brand/042987
const _thumbBg = Color(0xFFECEEF0); // surface/muted/eceef0
const _edge = Color(0xFFD7D7D7);
const _shade = Color(0xCC000000); // black @ 80%
const _clear = Color(0x00000000);
const _bannerNavy = Color(0xE6101E39); // rgba(16, 30, 57, 0.9)
const _bannerNavyMid = Color(0x66101E39); // rgba(16, 30, 57, 0.4)
const _bannerNavyClear = Color(0x00101E39);
const _glass = Color(0x33FFFFFF); // white @ 20%

/// White card for an active arena below the featured one: category tag, time
/// left, prize pool, title, a [preview] and a "Participate" button.
class HubChallengeCard extends StatelessWidget {
  const HubChallengeCard({
    super.key,
    required this.tag,
    required this.timeLeft,
    required this.poolLabel,
    required this.pool,
    required this.title,
    required this.preview,
    required this.onParticipate,
  });

  /// Category tag, shown upper-case ("DANCE").
  final String tag;

  /// e.g. "12 Days Left".
  final String timeLeft;

  /// e.g. "Bounty Pool", "Prize Pool".
  final String poolLabel;

  /// e.g. "$5,000 USD".
  final String pool;
  final String title;

  /// [HubEntriesPreview] or [HubBannerPreview].
  final Widget preview;
  final VoidCallback onParticipate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: _edge, offset: Offset(-1, -1), blurRadius: 1),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          // The meta row's 36px content is centred on a 33px line.
          SizedBox(
            height: 33,
            child: OverflowBox(
              maxHeight: 36,
              child: Row(
                children: [
                  _Tag(tag),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    HubIcons.daysLeft,
                    width: 10.8333,
                    height: 10.8333,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      timeLeft,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hubText(
                        10,
                        FontWeight.w500,
                        _body,
                        lineHeight: 14,
                      ),
                    ),
                  ),
                  _Pool(label: poolLabel, amount: pool),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40, bottom: 0.75),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: hubText(16, FontWeight.w700, _ink, lineHeight: 22.5),
              ),
            ),
          ),
          preview,
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _ParticipateButton(onPressed: onParticipate),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _tagBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: hubText(
          10,
          FontWeight.w700,
          _tagInk,
          lineHeight: 14,
          tracking: 0.5,
        ),
      ),
    );
  }
}

class _Pool extends StatelessWidget {
  const _Pool({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    // The amount's 26px line tucks 4px up under the 14px label.
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            amount,
            style: hubText(14, FontWeight.w600, _pool, lineHeight: 26),
          ),
        ),
        Text(label, style: hubText(10, FontWeight.w500, _body, lineHeight: 14)),
      ],
    );
  }
}

class _ParticipateButton extends StatelessWidget {
  const _ParticipateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _brand,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              Text(
                'Participate',
                style: hubText(
                  12,
                  FontWeight.w700,
                  Colors.white,
                  lineHeight: 16,
                ),
              ),
              SvgPicture.asset(
                HubIcons.arrowRight,
                width: 9.33333,
                height: 9.33333,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Leading Entries" strip: a header with a "Watch & Vote" link and three
/// portrait thumbnails with their vote counts.
class HubEntriesPreview extends StatelessWidget {
  const HubEntriesPreview({
    super.key,
    required this.submitted,
    required this.entries,
    required this.onWatch,
  });

  final int submitted;
  final List<ChallengeEntry> entries;

  /// Called by the link and by each thumbnail.
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Leading Entries (${formatGrouped(submitted)} submitted)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: hubText(12, FontWeight.w600, _ink, lineHeight: 16),
                ),
              ),
              Semantics(
                button: true,
                child: InkWell(
                  onTap: onWatch,
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    'Watch & Vote →',
                    style: hubText(10, FontWeight.w500, _brand, lineHeight: 14),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 137.77,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                for (final entry in entries)
                  Expanded(
                    child: _EntryThumb(entry: entry, onTap: onWatch),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryThumb extends StatelessWidget {
  const _EntryThumb({required this.entry, required this.onTap});

  final ChallengeEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = entry.creator?.name ?? entry.title ?? '';
    return Semantics(
      button: true,
      label: '$name, ${entry.stars} votes',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: _thumbBg),
            StarImage(entry.thumbnailUrl, placeholderColor: _thumbBg),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [_shade, _clear, _clear],
                ),
              ),
            ),
            Positioned(
              left: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    SvgPicture.asset(
                      HubIcons.starVote,
                      width: 9.16667,
                      height: 8.70833,
                    ),
                    Text(
                      '${entry.stars}',
                      style: hubText(
                        10,
                        FontWeight.w700,
                        Colors.white,
                        lineHeight: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: hubText(
                  10,
                  FontWeight.w600,
                  Colors.white,
                  lineHeight: 14,
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wide banner preview: artwork fading in from a navy left edge, with a
/// "N Creators Competing" pill and the arena's theme.
class HubBannerPreview extends StatelessWidget {
  const HubBannerPreview({
    super.key,
    required this.image,
    required this.competing,
    required this.theme,
  });

  final String? image;
  final int competing;

  /// e.g. "Solarpunk Horizons".
  final String theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: _thumbBg),
            StarImage(image, placeholderColor: _thumbBg),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_bannerNavy, _bannerNavyMid, _bannerNavyClear],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(
                        color: _glass,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 6,
                          children: [
                            SvgPicture.asset(
                              HubIcons.palette,
                              width: 10,
                              height: 10,
                            ),
                            Text(
                              '${formatGrouped(competing)} Creators Competing',
                              style: hubText(
                                10,
                                FontWeight.w700,
                                Colors.white,
                                lineHeight: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Theme: '$theme'",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: hubText(
                      12,
                      FontWeight.w700,
                      Colors.white,
                      lineHeight: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
