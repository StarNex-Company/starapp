import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/features/messages/data/models/message.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';

const _bubblePadding = EdgeInsets.symmetric(horizontal: 14, vertical: 10);
const _inRadius = BorderRadius.only(
  topLeft: Radius.circular(18),
  topRight: Radius.circular(18),
  bottomRight: Radius.circular(18),
  bottomLeft: Radius.circular(4),
);
const _outRadius = BorderRadius.only(
  topLeft: Radius.circular(18),
  topRight: Radius.circular(18),
  bottomLeft: Radius.circular(18),
  bottomRight: Radius.circular(4),
);

/// Bubble corner shape: the tail corner sits on the sender's side.
BorderRadius bubbleRadius({required bool mine}) =>
    mine ? _outRadius : _inRadius;

/// "10:05 · Seen" under the user's own messages, "10:02" under others.
String messageMeta(Message m) {
  final time = DateFormat.Hm().format(m.sentAt);
  if (!m.isMine) return time;
  return switch (m.status) {
    MessageStatus.sending => 'Sending…',
    MessageStatus.failed => 'Not sent · Tap to retry',
    MessageStatus.sent => '$time · Sent',
    MessageStatus.delivered => '$time · Delivered',
    MessageStatus.seen => '$time · Seen',
  };
}

/// A text message: grey on the left for theirs, navy on the right for the
/// user's. A failed one can be tapped to send again.
class TextBubble extends StatelessWidget {
  const TextBubble({super.key, required this.message, this.onRetry});

  final Message message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final failed = message.isFailed;
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 268),
      padding: _bubblePadding,
      decoration: BoxDecoration(
        color: mine ? null : MessagesColors.bubbleIn,
        gradient: mine ? AppColors.brandGradient : null,
        borderRadius: bubbleRadius(mine: mine),
      ),
      child: Opacity(
        opacity: message.isPending ? 0.7 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              message.text ?? '',
              style: messagesText(
                14,
                height: 20 / 14,
                color: mine ? Colors.white : AppColors.ink,
              ),
            ),
            Text(
              messageMeta(message),
              style: messagesText(
                10,
                color: failed
                    ? MessagesColors.failedOnBrand
                    : mine
                    ? AppColors.onBrandSubtle
                    : AppColors.textFaint,
              ),
            ),
          ],
        ),
      ),
    );

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: failed && onRetry != null
          ? Semantics(
              button: true,
              label: 'Retry sending',
              child: GestureDetector(onTap: onRetry, child: bubble),
            )
          : bubble,
    );
  }
}

/// A file sent on its own: the file row in a card on the sender's side.
class AttachmentBubble extends StatelessWidget {
  const AttachmentBubble({
    super.key,
    required this.message,
    required this.onOpen,
  });

  final Message message;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final attachment = message.attachment;
    if (attachment == null) return const SizedBox.shrink();

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderField),
          borderRadius: bubbleRadius(mine: mine),
          boxShadow: const [MessagesColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            AttachmentRow(attachment: attachment, onTap: onOpen),
            Text(
              messageMeta(message),
              style: messagesText(10, color: AppColors.textFaint),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grey file row: icon tile, name and size. A Talent Passport share shows
/// as a portfolio link.
class AttachmentRow extends StatelessWidget {
  const AttachmentRow({
    super.key,
    required this.attachment,
    required this.onTap,
  });

  final Attachment attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final passport = attachment.kind == AttachmentKind.talentPassport;
    final radius = BorderRadius.circular(10);

    return Material(
      color: AppColors.closeButtonBg,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: passport ? AppColors.brandTint : AppColors.dangerTint,
                  borderRadius: radius,
                ),
                child: SvgPicture.asset(
                  passport ? MessagesIcons.idCard : MessagesIcons.fileRed,
                  width: 15,
                  height: 15,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      attachment.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: messagesText(12, weight: FontWeight.w600),
                    ),
                    Text(
                      passport ? 'Portfolio link' : attachment.sizeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: messagesText(11, color: AppColors.textSubtle),
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

/// A notice from Star App, centred in the thread.
class SystemNotice extends StatelessWidget {
  const SystemNotice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: messagesText(12, height: 18 / 12, color: AppColors.textSubtle),
      ),
    );
  }
}

/// "Today", "Yesterday", "Monday" or "Sep 28" between days.
class DaySeparator extends StatelessWidget {
  const DaySeparator({super.key, required this.day});

  final DateTime day;

  static String label(DateTime day, {DateTime? now}) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final date = DateUtils.dateOnly(day);
    final days = today.difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days > 1 && days < 7) return DateFormat.EEEE().format(date);
    return date.year == today.year
        ? DateFormat.MMMd().format(date)
        : DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: MessagesColors.track,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            label(day),
            style: messagesText(
              11,
              weight: FontWeight.w600,
              color: AppColors.textSubtle,
            ),
          ),
        ),
      ),
    );
  }
}
