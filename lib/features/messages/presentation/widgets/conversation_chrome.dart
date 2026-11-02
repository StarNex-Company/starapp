import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/messages/data/models/conversation.dart';
import 'package:starapp/features/messages/data/models/participant.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// "Verified company · Active now", "@amina_k · Active 2h ago".
String conversationSubtitle(Conversation c) {
  final p = c.counterpart;
  final who = switch (p.kind) {
    ParticipantKind.company =>
      p.isVerified ? 'Verified company' : (p.roleLabel ?? 'Company'),
    ParticipantKind.creator => p.handle == null ? null : '@${p.handle}',
    ParticipantKind.system => p.roleLabel,
  };
  final lastActive = c.lastActiveAt;
  final presence = p.kind == ParticipantKind.system
      ? null
      : c.isOnline
      ? 'Active now'
      : lastActive == null
      ? null
      : 'Active ${formatAgo(lastActive)}';
  return [?who, ?presence].join(' · ');
}

/// The thread's top bar: back, the counterpart's name and presence (tap for
/// their profile), and the ⋯ menu. Same frame as [StarScreenHeader].
class ConversationHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const ConversationHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle = '',
    this.online = false,
    this.onTitle,
    this.onMenu,
  });

  final String title;
  final String subtitle;

  /// Draws [subtitle] in green.
  final bool online;
  final VoidCallback onBack;
  final VoidCallback? onTitle;
  final VoidCallback? onMenu;

  @override
  Size get preferredSize => const Size.fromHeight(StarScreenHeader.barHeight);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: StarScreenHeader.barHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                spacing: 12,
                children: [
                  StarIconButton.back(onPressed: onBack),
                  Expanded(
                    child: Semantics(
                      button: onTitle != null,
                      child: InkWell(
                        onTap: onTitle,
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 2,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: messagesText(
                                19,
                                weight: FontWeight.w600,
                                color: AppColors.brandNavy,
                              ),
                            ),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: messagesText(
                                  11,
                                  weight: FontWeight.w500,
                                  color: online
                                      ? MessagesColors.online
                                      : AppColors.textSubtle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (onMenu != null)
                    StarIconButton(
                      icon: MessagesIcons.more,
                      iconSize: 3.84375,
                      tooltip: 'More',
                      onPressed: onMenu,
                    )
                  else
                    const SizedBox.square(dimension: StarIconButton.size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "+", the message field and send. Send is disabled while the field is
/// empty.
class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.hint,
    required this.onSend,
    required this.onAttach,
  });

  final String hint;
  final ValueChanged<String> onSend;
  final VoidCallback onAttach;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    // 30px above the home indicator, as designed; 12px over the keyboard.
    final bottom = math.max(MediaQuery.paddingOf(context).bottom - 4, 12.0);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x140B1020),
            offset: Offset(0, -6),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottom),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Tooltip(
                message: 'Attach',
                child: Material(
                  color: AppColors.closeButtonBg,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.onAttach,
                    child: SizedBox.square(
                      dimension: 42,
                      child: Center(
                        child: SvgPicture.asset(
                          MessagesIcons.plus,
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                style: messagesText(14, height: 20 / 14),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: messagesText(
                    14,
                    height: 20 / 14,
                    color: AppColors.textFaint,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.closeButtonBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) {
                final enabled = value.text.trim().isNotEmpty;
                return Semantics(
                  button: true,
                  enabled: enabled,
                  label: 'Send',
                  child: Opacity(
                    opacity: enabled ? 1 : 0.5,
                    child: Material(
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: AppColors.brandGradient,
                        ),
                        child: InkWell(
                          onTap: enabled ? _send : null,
                          child: SizedBox.square(
                            dimension: 44,
                            child: Center(
                              child: SvgPicture.asset(
                                MessagesIcons.send,
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
