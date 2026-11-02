import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/features/messages/data/models/conversation.dart';
import 'package:starapp/features/messages/data/models/offer.dart';
import 'package:starapp/features/messages/presentation/widgets/message_bubbles.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';

/// "Nov 14 – 16 · 3 days".
String offerDatesLabel(Offer offer) {
  final start = offer.startDate;
  final end = offer.endDate;
  final days = offer.dayCount;
  final range = DateUtils.isSameDay(start, end)
      ? DateFormat.MMMd().format(start)
      : start.month == end.month && start.year == end.year
      ? '${DateFormat.MMMd().format(start)} – ${end.day}'
      : '${DateFormat.MMMd().format(start)} – ${DateFormat.MMMd().format(end)}';
  return '$range · $days day${days == 1 ? '' : 's'}';
}

/// "Expires in 3 days", "Expires in 5h".
String offerExpiryLabel(DateTime expiresAt, {DateTime? now}) {
  final left = expiresAt.difference(now ?? DateTime.now());
  if (left.isNegative) return 'Expired';
  if (left.inDays >= 1) {
    return 'Expires in ${left.inDays} day${left.inDays == 1 ? '' : 's'}';
  }
  if (left.inHours >= 1) return 'Expires in ${left.inHours}h';
  return 'Expires soon';
}

/// What the proposal bar and a settled offer card say about [status].
({String label, String bar, Color color, Color background}) offerStatusStyle(
  OfferStatus status,
) => switch (status) {
  OfferStatus.pending => (
    label: 'Pending your response',
    bar: 'Pending your response',
    color: MessagesColors.pending,
    background: MessagesColors.goldTint,
  ),
  OfferStatus.countered => (
    label: 'Counter offer sent',
    bar: 'Counter offer sent',
    color: AppColors.brandBlue,
    background: AppColors.brandTint,
  ),
  OfferStatus.accepted => (
    label: 'Offer accepted',
    bar: 'Accepted',
    color: MessagesColors.online,
    background: AppColors.successTint,
  ),
  OfferStatus.declined => (
    label: 'Offer declined',
    bar: 'Declined',
    color: AppColors.danger,
    background: AppColors.dangerTint,
  ),
  OfferStatus.expired => (
    label: 'Offer expired',
    bar: 'Expired',
    color: AppColors.textSubtle,
    background: AppColors.closeButtonBg,
  ),
  OfferStatus.withdrawn => (
    label: 'Offer withdrawn',
    bar: 'Withdrawn',
    color: AppColors.textSubtle,
    background: AppColors.closeButtonBg,
  ),
};

/// The offer pinned above a Scout thread: "Proposal · Featured Dancer ·
/// ₦850,000", its status, and "View" for the original request.
class PinnedProposalBar extends StatelessWidget {
  const PinnedProposalBar({super.key, required this.proposal, this.onView});

  final PinnedProposal proposal;

  /// Opens the Scout request; hidden when null.
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final status = offerStatusStyle(proposal.status);
    final title = [
      'Proposal',
      if (proposal.title.isNotEmpty) proposal.title,
      proposal.amount.format(),
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MessagesColors.goldOutline),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [MessagesColors.cardShadow],
      ),
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MessagesColors.goldTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              MessagesIcons.briefcaseGold,
              width: 17,
              height: 17,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: messagesText(13, weight: FontWeight.w600),
                ),
                Text(
                  status.bar,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: messagesText(11, color: status.color),
                ),
              ],
            ),
          ),
          if (onView != null)
            Semantics(
              button: true,
              child: InkWell(
                onTap: onView,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'View',
                    style: messagesText(
                      13,
                      weight: FontWeight.w600,
                      color: AppColors.brandBlue,
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

/// A company's offer in the thread. Pending offers show Counter / Accept;
/// settled ones show their status instead.
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.mine,
    required this.onAccept,
    required this.onCounter,
    required this.onOpenAttachment,
  });

  final Offer offer;
  final bool mine;
  final VoidCallback onAccept;
  final VoidCallback onCounter;
  final ValueChanged<Attachment> onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final pending = offer.status == OfferStatus.pending;
    final status = offerStatusStyle(offer.status);
    final counter = offer.lastCounter;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Row(
              children: [
                const _OfferPill(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pending ? offerExpiryLabel(offer.expiresAt) : '',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: messagesText(11, color: AppColors.textSubtle),
                  ),
                ),
              ],
            ),
            Text(
              offer.amount.format(),
              style: messagesText(26, weight: FontWeight.w800),
            ),
            if (offer.role.isNotEmpty) _KeyValue('Role', offer.role),
            _KeyValue('Dates', offerDatesLabel(offer)),
            if (offer.usage.isNotEmpty) _KeyValue('Usage', offer.usage),
            for (final attachment in offer.attachments)
              AttachmentRow(
                attachment: attachment,
                onTap: () => onOpenAttachment(attachment),
              ),
            if (pending)
              Row(
                spacing: 8,
                children: [
                  _CounterButton(onTap: onCounter),
                  Expanded(child: _AcceptButton(onTap: onAccept)),
                ],
              )
            else
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: status.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  offer.status == OfferStatus.countered && counter != null
                      ? 'You countered · ${counter.amount.format()}'
                      : status.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: messagesText(
                    13,
                    weight: FontWeight.w600,
                    color: status.color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OfferPill extends StatelessWidget {
  const _OfferPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: MessagesColors.goldTint,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(
            MessagesIcons.briefcasePill,
            width: 11.7667,
            height: 11,
          ),
          Text(
            'OFFER',
            style: messagesText(
              11,
              weight: FontWeight.w600,
              color: AppColors.goldText,
            ).copyWith(letterSpacing: 0.44),
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Text(label, style: messagesText(12, color: AppColors.textSubtle)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: messagesText(12, weight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

const _buttonRadius = BorderRadius.all(Radius.circular(12));

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 40,
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: _buttonRadius,
          side: BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              'Counter',
              maxLines: 1,
              style: messagesText(
                13,
                weight: FontWeight.w600,
                color: AppColors.brandBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: _buttonRadius,
        boxShadow: [MessagesColors.buttonShadow],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: _buttonRadius,
          onTap: onTap,
          child: Center(
            child: Text(
              'Accept offer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: messagesText(
                13,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
