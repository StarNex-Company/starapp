import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/stories/data/models/new_story.dart';
import 'package:starapp/features/stories/presentation/widgets/story_circle_button.dart';
import 'package:starapp/features/stories/presentation/widgets/story_icons.dart';
import 'package:starapp/features/stories/presentation/widgets/story_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Step 2 of story creation: the chosen media full screen with a caption
/// field, editing tools, the audience/duration chip and "Your story".
class StoryCaptionStep extends StatelessWidget {
  const StoryCaptionStep({
    super.key,
    required this.media,
    required this.userAvatarUrl,
    required this.caption,
    required this.settings,
    required this.onBack,
    required this.onTool,
    required this.onSettings,
    required this.onPost,
  });

  final StoryMedia media;

  /// The signed-in user's photo on "Your story"; null shows the placeholder.
  final String? userAvatarUrl;
  final TextEditingController caption;
  final StorySettings settings;
  final VoidCallback onBack;

  /// Text, sticker and music tools.
  final ValueChanged<String> onTool;
  final VoidCallback onSettings;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final mediaTop = math.max(mq.viewPadding.top - 12, 0.0);
    final barBottom = math.max(mq.viewPadding.bottom + 4, 16.0);
    // Media ends 20px above the 44px bottom bar.
    final mediaBottom = barBottom + 64;
    final captionBottom = math.max(mediaBottom + 22, mq.viewInsets.bottom + 12);

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned(
            top: mediaTop,
            left: 0,
            right: 0,
            bottom: mediaBottom,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(media.path, fit: BoxFit.cover),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: _Shade(
                      height: 160,
                      from: Color(0x8C000000),
                      to: Color(0x00000000),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: _Shade(
                      height: 220,
                      from: Color(0x00000000),
                      to: Color(0xA6000000),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: mediaTop + 16,
            left: 16,
            child: StoryCircleButton(
              icon: StoryIcons.chevronLeft,
              label: 'Back',
              onTap: onBack,
            ),
          ),
          if (media.isVideo)
            Positioned(
              top: mediaTop + 16,
              left: 72,
              right: 72,
              height: 40,
              child: Center(
                child: _ClipLength(duration: formatDuration(media.duration!)),
              ),
            ),
          Positioned(
            top: mediaTop + 16,
            right: 16,
            child: Column(
              spacing: 12,
              children: [
                StoryCircleButton(
                  icon: StoryIcons.toolText,
                  label: 'Text',
                  iconSize: 18,
                  onTap: () => onTool('Text'),
                ),
                StoryCircleButton(
                  icon: StoryIcons.toolSticker,
                  label: 'Stickers',
                  iconSize: 18,
                  onTap: () => onTool('Stickers'),
                ),
                StoryCircleButton(
                  icon: StoryIcons.toolMusic,
                  label: 'Music',
                  iconSize: 18,
                  onTap: () => onTool('Music'),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: captionBottom,
            child: _CaptionField(controller: caption),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: barBottom,
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _AudienceChip(settings: settings, onTap: onSettings),
                ),
                const SizedBox(width: 12),
                _PostButton(avatarUrl: userAvatarUrl, onTap: onPost),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Shade extends StatelessWidget {
  const _Shade({required this.height, required this.from, required this.to});

  final double height;
  final Color from;
  final Color to;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [from, to],
          ),
        ),
      ),
    );
  }
}

class _ClipLength extends StatelessWidget {
  const _ClipLength({required this.duration});

  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x73000000),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          SvgPicture.asset(StoryIcons.play10, width: 10, height: 10),
          Flexible(
            child: Text(
              '$duration · fits in one story',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: storyText(12, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptionField extends StatelessWidget {
  const _CaptionField({required this.controller});

  final TextEditingController controller;

  static const _style = TextStyle(
    fontSize: 15,
    height: 1.21,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0x73000000),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x59FFFFFF)),
      ),
      child: TextField(
        controller: controller,
        maxLength: 120,
        style: _style,
        cursorColor: Colors.white,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          counterText: '',
          hintText: 'Add a caption…',
          hintStyle: _style.copyWith(color: const Color(0xB3FFFFFF)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({required this.settings, required this.onTap});

  final StorySettings settings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          'Story settings: ${settings.audience.title}, ${settings.duration.label}',
      excludeSemantics: true,
      child: Material(
        color: const Color(0x24FFFFFF),
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                SvgPicture.asset(StoryIcons.users14, width: 14, height: 14),
                Flexible(
                  child: Text(
                    '${settings.audience.title} · ${settings.duration.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: storyText(12, weight: FontWeight.w600),
                  ),
                ),
                // The design's "  ▾", drawn so it doesn't depend on a
                // fallback font.
                const Padding(
                  padding: EdgeInsets.only(left: 1, top: 1),
                  child: CustomPaint(
                    size: Size(5, 3.5),
                    painter: _CaretPainter(),
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

class _CaretPainter extends CustomPainter {
  const _CaretPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_CaretPainter oldDelegate) => false;
}

class _PostButton extends StatelessWidget {
  const _PostButton({required this.avatarUrl, required this.onTap});

  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Share to your story',
      excludeSemantics: true,
      child: Material(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 18, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                StarAvatar(avatarUrl, size: 28),
                Text(
                  'Your story',
                  style: storyText(
                    14,
                    weight: FontWeight.w700,
                    color: StoryColors.onGold,
                  ),
                ),
                SvgPicture.asset(StoryIcons.send16, width: 16, height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
