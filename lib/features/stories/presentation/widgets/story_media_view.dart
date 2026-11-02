import 'package:flutter/material.dart';
import 'package:starapp/features/stories/data/models/story_creator.dart';
import 'package:starapp/features/stories/presentation/widgets/story_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Full-screen story content: the photo (cover, or letterboxed on black) or
/// a text story on the brand gradient, under the design's top and bottom
/// shades.
class StoryMediaView extends StatelessWidget {
  const StoryMediaView({super.key, required this.story});

  final StoryItem story;

  @override
  Widget build(BuildContext context) {
    final image = story.mediaUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (image != null)
          ColoredBox(
            color: Colors.black,
            child: StarImage(
              image,
              fit: switch (story.fit) {
                StoryFit.cover => BoxFit.cover,
                StoryFit.contain => BoxFit.contain,
              },
              width: double.infinity,
              height: double.infinity,
              placeholderColor: Colors.black,
            ),
          )
        else
          const DecoratedBox(
            decoration: BoxDecoration(gradient: StoryColors.textStoryGradient),
          ),
        const Align(
          alignment: Alignment.topCenter,
          child: _Shade(
            height: 200,
            top: Color(0x8C000000),
            bottom: Color(0x00000000),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: _Shade(
            height: 220,
            top: Color(0x00000000),
            bottom: Color(0x99000000),
          ),
        ),
        if (story.text != null)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                story.text!,
                textAlign: TextAlign.center,
                style: storyText(26, weight: FontWeight.w700, height: 36 / 26),
              ),
            ),
          ),
      ],
    );
  }
}

class _Shade extends StatelessWidget {
  const _Shade({required this.height, required this.top, required this.bottom});

  final double height;
  final Color top;
  final Color bottom;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, bottom],
            ),
          ),
        ),
      ),
    );
  }
}
