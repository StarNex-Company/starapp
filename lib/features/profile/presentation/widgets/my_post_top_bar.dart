import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/features/profile/presentation/widgets/my_post_style.dart';

/// The design's darkening behind the status bar and top bar.
const _headerGradient = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [Color(0x00000000), Color(0x80000207), Color(0x95000207)],
  stops: [0.16538, 0.88077, 1],
);

/// Back button, "Your post" and the ••• post-menu button, floating over the
/// video on a dark fade.
class MyPostTopBar extends StatelessWidget {
  const MyPostTopBar({super.key, required this.onBack, required this.onMenu});

  final VoidCallback onBack;

  /// Null while the post loads.
  final VoidCallback? onMenu;

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
              spacing: 12,
              children: [
                _BackButton(onPressed: onBack),
                Flexible(
                  child: Text(
                    'Your post',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: myPostText(17, weight: FontWeight.w700),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Post options',
                  excludeSemantics: true,
                  onTap: onMenu,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onMenu,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Text(
                        '•••',
                        style: myPostText(
                          14,
                          weight: FontWeight.w500,
                          lineHeight: 20,
                        ),
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
        color: myPostGlass,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 37,
            child: Center(
              child: SvgPicture.asset(MyPostIcons.back, width: 25, height: 25),
            ),
          ),
        ),
      ),
    );
  }
}
