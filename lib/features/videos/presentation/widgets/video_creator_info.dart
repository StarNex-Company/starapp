import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/videos/data/models/feed_video.dart';
import 'package:starapp/features/videos/presentation/widgets/video_style.dart';
import 'package:starapp/features/videos/presentation/widgets/videos_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Bottom-left block: creator row with Follow, caption and sound chip.
class VideoCreatorInfo extends StatelessWidget {
  const VideoCreatorInfo({
    super.key,
    required this.video,
    required this.following,
    required this.onCreator,
    required this.onFollow,
    required this.onSound,
  });

  final FeedVideo video;
  final bool following;
  final VoidCallback onCreator;
  final VoidCallback onFollow;
  final VoidCallback onSound;

  @override
  Widget build(BuildContext context) {
    final creator = video.creator;
    final meta = [?creator.tier?.label, ?video.location].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        SizedBox(
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onCreator,
                child: CreatorAvatar(
                  imageUrl: creator.avatarUrl,
                  verified: creator.isVerified,
                ),
              ),
              const SizedBox(width: 12),
              // The Follow pill sits at a fixed offset for short names.
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 94.17),
                  child: Transform.translate(
                    offset: const Offset(0, 0.5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onCreator,
                          child: Text(
                            creator.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: videoText(
                              15,
                              weight: FontWeight.w700,
                              color: AppColors.lunarWhite,
                              lineHeight: 22.5,
                              letterSpacing: -0.375,
                              shadows: videoTextShadows,
                            ),
                          ),
                        ),
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: videoText(
                            11,
                            color: videoMeta,
                            lineHeight: 16.5,
                            letterSpacing: -0.275,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: FollowToggle(following: following, onPressed: onFollow),
              ),
            ],
          ),
        ),
        _Caption(video: video),
        _SoundChip(label: video.sound, onTap: onSound),
      ],
    );
  }
}

/// 40px creator photo with the cobalt ring and, for verified creators, the
/// star badge.
class CreatorAvatar extends StatelessWidget {
  const CreatorAvatar({
    super.key,
    required this.imageUrl,
    this.verified = false,
  });

  final String? imageUrl;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF858585),
              boxShadow: [
                BoxShadow(color: videoCobaltRing, spreadRadius: 2),
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
            child: StarAvatar(imageUrl, size: 40),
          ),
          if (verified)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: videoCobalt,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black, spreadRadius: 1)],
                ),
                child: SvgPicture.asset(
                  VideosIcons.verified,
                  width: 10,
                  height: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Frosted "Follow" / "Following" pill.
class FollowToggle extends StatelessWidget {
  const FollowToggle({
    super.key,
    required this.following,
    required this.onPressed,
  });

  final bool following;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(9999));

    return Semantics(
      button: true,
      toggled: following,
      child: GestureDetector(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Color(0x0D000000),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: following ? 83 : 66,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: following
                      ? const Color(0x2EFFFFFF)
                      : const Color(0x8C2424FF),
                  borderRadius: radius,
                  border: Border.all(
                    color: following
                        ? const Color(0x80FFFFFF)
                        : const Color(0x4DFFFFFF),
                  ),
                ),
                child: Text(
                  following ? 'Following' : 'Follow',
                  maxLines: 1,
                  style: videoText(
                    12,
                    weight: FontWeight.w700,
                    lineHeight: 16,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.video});

  final FeedVideo video;

  static final _hashtag = RegExp(r'#\w+');

  /// [text] in [weight], with its hashtags highlighted.
  static List<TextSpan> _spans(String text, FontWeight weight) {
    final plain = TextStyle(fontWeight: weight);
    final spans = <TextSpan>[];
    var start = 0;
    for (final match in _hashtag.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: plain),
        );
      }
      spans.add(
        TextSpan(
          text: match[0],
          style: TextStyle(color: videoHashtag, fontWeight: weight),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: plain));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final base = videoText(
      13.5,
      color: videoCaption,
      lineHeight: 18.56,
      shadows: videoTextShadows,
    );
    // A caption with a line break sets its second line (usually hashtags)
    // a touch bolder, as designed.
    final caption = video.caption;
    final lineBreak = caption.indexOf('\n');
    final first = lineBreak < 0 ? caption : caption.substring(0, lineBreak + 1);
    final rest = lineBreak < 0 ? '' : caption.substring(lineBreak + 1);

    return SizedBox(
      height: 37.13,
      child: Transform.translate(
        offset: const Offset(0, -1.22),
        child: SizedBox(
          // Captions that wrap do so at the design's 233px; ones with a hard
          // line break may run up to the column edge.
          width: lineBreak < 0 ? 233 : null,
          child: Text.rich(
            TextSpan(
              style: base,
              children: [
                ..._spans(first, FontWeight.w400),
                ..._spans(rest, FontWeight.w500),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _SoundChip extends StatelessWidget {
  const _SoundChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(9999));

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                borderRadius: radius,
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(VideosIcons.sound, width: 12, height: 12),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 170),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: videoText(
                        11,
                        color: videoChipText,
                        lineHeight: 16.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
