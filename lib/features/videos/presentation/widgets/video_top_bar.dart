import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/features/videos/presentation/widgets/video_style.dart';
import 'package:starapp/features/videos/presentation/widgets/videos_icons.dart';

/// The design's darkening behind the status bar and top bar.
const _headerGradient = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [Color(0x00000000), Color(0x80000207), Color(0x95000207)],
  stops: [0.16538, 0.88077, 1],
);

/// Status-bar backdrop plus the back button, Following | For You tabs and
/// "Saved" link floating over the feed.
class VideoTopBar extends StatelessWidget {
  const VideoTopBar({
    super.key,
    required this.followingSelected,
    required this.onFollowing,
    required this.onForYou,
    required this.onBack,
    required this.onSaved,
  });

  final bool followingSelected;
  final VoidCallback onFollowing;
  final VoidCallback onForYou;
  final VoidCallback onBack;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(gradient: _headerGradient),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, top + 1 + 15, 24, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BackButton(onPressed: onBack),
                // Scales down rather than overflow at large text sizes.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 22,
                      children: [
                        _FeedTab(
                          label: 'Following',
                          selected: followingSelected,
                          onTap: onFollowing,
                        ),
                        Text(
                          '|',
                          style: videoText(
                            15,
                            weight: FontWeight.w500,
                            color: const Color(0x59FFFFFF),
                          ),
                        ),
                        _FeedTab(
                          label: 'For You',
                          selected: !followingSelected,
                          onTap: onForYou,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSaved,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Saved',
                      style: videoText(
                        14,
                        weight: FontWeight.w500,
                        lineHeight: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // The bar's drop shadow (0 4 4 @ 25%), drawn only below it.
        const Positioned(
          left: 0,
          right: 0,
          bottom: -8,
          height: 8,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x3D000000),
                    Color(0x20000000),
                    Color(0x00000000),
                  ],
                  stops: [0, 0.5, 1],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Back',
      child: Material(
        color: videoGlass,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 37,
            child: Center(
              child: SvgPicture.asset(VideosIcons.back, width: 25, height: 25),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            Text(
              label,
              style: videoText(
                17,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : const Color(0x99FFFFFF),
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 22,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
