import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/features/stories/presentation/widgets/story_icons.dart';
import 'package:starapp/features/stories/presentation/widgets/story_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// Avatar, "Name  ·  2h" and the close button over the top of a story.
class StoryViewerHeader extends StatelessWidget {
  const StoryViewerHeader({
    super.key,
    required this.creator,
    required this.age,
    required this.onCreatorTap,
    required this.onClose,
  });

  final CreatorSummary creator;

  /// How old the story is, e.g. "2h".
  final String age;
  final VoidCallback onCreatorTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                label: '${creator.name} profile',
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCreatorTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      StarAvatar(creator.avatarUrl, size: 36),
                      Flexible(
                        child: Text(
                          '${creator.name}  ·  $age',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: storyText(14, weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Close',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: SizedBox.square(
                dimension: 40,
                child: Center(
                  child: SvgPicture.asset(
                    StoryIcons.close,
                    width: 24,
                    height: 24,
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

/// 44px translucent round button on the story's bottom bar.
class StoryRoundButton extends StatelessWidget {
  const StoryRoundButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconSize = 20,
    this.selected = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final double iconSize;

  /// Reported to accessibility services for toggles.
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: selected,
      excludeSemantics: true,
      child: Material(
        color: const Color(0x29FFFFFF),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: SvgPicture.asset(
                  icon,
                  key: ValueKey(icon),
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Send a message…" pill. Shows a send arrow once something is typed;
/// sending clears the field.
class StoryReplyField extends StatefulWidget {
  const StoryReplyField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSend;

  @override
  State<StoryReplyField> createState() => _StoryReplyFieldState();
}

class _StoryReplyFieldState extends State<StoryReplyField> {
  static const _style = TextStyle(
    fontSize: 14,
    height: 1.21,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  void _submit() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      widget.focusNode.unfocus();
      return;
    }
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xB3FFFFFF), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: _style,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Send a message…',
                hintStyle: _style.copyWith(color: const Color(0xD9FFFFFF)),
                contentPadding: const EdgeInsets.fromLTRB(16.5, 13.5, 8, 13.5),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              if (value.text.trim().isEmpty) return const SizedBox.shrink();
              return Semantics(
                button: true,
                label: 'Send reply',
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _submit,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 14, 0),
                    child: SvgPicture.asset(
                      StoryIcons.share,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
