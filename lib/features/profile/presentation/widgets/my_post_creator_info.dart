import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/my_post_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _pill = BorderRadius.all(Radius.circular(9999));

/// Bottom-left block: the user's avatar, name and tier with the Insights
/// pill, then the caption and the sound chip.
class MyPostCreatorInfo extends StatelessWidget {
  const MyPostCreatorInfo({
    super.key,
    required this.name,
    required this.meta,
    required this.avatarUrl,
    required this.verified,
    required this.caption,
    required this.hashtag,
    required this.sound,
    required this.onProfile,
    required this.onInsights,
    required this.onSound,
  });

  final String name;

  /// Tier and city, e.g. "Rising Nova · Lagos".
  final String meta;

  /// The profile photo; null shows the placeholder.
  final String? avatarUrl;
  final bool verified;
  final String caption;
  final String? hashtag;
  final String sound;
  final VoidCallback onProfile;
  final VoidCallback onInsights;
  final VoidCallback onSound;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: true,
                label: 'Your profile',
                excludeSemantics: true,
                onTap: onProfile,
                child: GestureDetector(
                  onTap: onProfile,
                  child: _Avatar(image: avatarUrl, verified: verified),
                ),
              ),
              const SizedBox(width: 12),
              // The Insights pill sits 210px in for names up to 146px.
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 146),
                  child: Transform.translate(
                    offset: const Offset(0, 0.5),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onProfile,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: myPostText(
                              15,
                              weight: FontWeight.w700,
                              color: AppColors.lunarWhite,
                              lineHeight: 22.5,
                              letterSpacing: -0.375,
                              shadows: myPostTextShadows,
                            ),
                          ),
                          Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: myPostText(
                              11,
                              color: myPostMeta,
                              lineHeight: 16.5,
                              letterSpacing: -0.275,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: _InsightsPill(onPressed: onInsights),
              ),
            ],
          ),
        ),
        _Caption(caption: caption, hashtag: hashtag),
        _SoundChip(label: sound, onTap: onSound),
      ],
    );
  }
}

/// 40px portrait with the cobalt ring and, when verified, the star badge.
/// The photo is drawn 60px wide behind the circle, as the design crops it.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.image, required this.verified});

  final String? image;
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
              color: AppColors.avatarFallback,
              boxShadow: [
                BoxShadow(color: myPostCobaltRing, spreadRadius: 2),
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
            child: ClipOval(
              child: OverflowBox(
                maxWidth: 60,
                maxHeight: 60,
                child: StarImage(
                  image,
                  width: 60,
                  height: 60,
                  placeholderColor: AppColors.avatarFallback,
                ),
              ),
            ),
          ),
          if (verified)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: myPostCobalt,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black, spreadRadius: 1)],
                ),
                child: SvgPicture.asset(
                  MyPostIcons.verified,
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

/// Frosted blue "Insights" pill (where other creators' videos have Follow).
class _InsightsPill extends StatelessWidget {
  const _InsightsPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: _pill,
            boxShadow: [
              BoxShadow(
                color: Color(0x0D000000),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: _pill,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: 66,
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: myPostInsightsFill,
                  borderRadius: _pill,
                  border: Border.all(color: const Color(0x4DFFFFFF)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Insights',
                    maxLines: 1,
                    style: myPostText(
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
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.caption, required this.hashtag});

  final String caption;
  final String? hashtag;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 38),
      child: Transform.translate(
        offset: const Offset(-0.5, -1.22),
        child: SizedBox(
          width: 270,
          child: Text.rich(
            TextSpan(
              style: myPostText(
                13.5,
                color: myPostCaption,
                lineHeight: 18.56,
                shadows: myPostTextShadows,
              ),
              children: [
                TextSpan(text: caption),
                if (hashtag != null)
                  TextSpan(
                    text: hashtag,
                    style: const TextStyle(color: myPostHashtag),
                  ),
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
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: _pill,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                borderRadius: _pill,
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(MyPostIcons.sound, width: 12, height: 12),
                  const SizedBox(width: 6),
                  // The design lets "Original Sound · <full name>" run past
                  // its 170px box, so it only shortens at the column edge.
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: myPostText(
                        11,
                        color: myPostChipText,
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
