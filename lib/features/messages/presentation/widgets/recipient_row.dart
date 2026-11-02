import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/messages/data/models/participant.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_avatar.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';

/// "@tunde_beats · Producer", "Verified company".
String recipientSubtitle(Participant p) => switch (p.kind) {
  ParticipantKind.company =>
    p.isVerified ? 'Verified company' : (p.roleLabel ?? 'Company'),
  _ => [if (p.handle != null) '@${p.handle}', ?p.roleLabel].join(' · '),
};

/// A person or company to message, with a "Message" button that shows
/// progress while their thread opens.
class RecipientRow extends StatelessWidget {
  const RecipientRow({
    super.key,
    required this.participant,
    required this.onMessage,
    this.busy = false,
  });

  final Participant participant;
  final VoidCallback? onMessage;
  final bool busy;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final subtitle = recipientSubtitle(participant);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        spacing: 12,
        children: [
          RingedAvatar(participant: participant),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  participant.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: messagesText(15, weight: FontWeight.w600),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: messagesText(12, color: AppColors.textSubtle),
                  ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Message ${participant.displayName}',
            excludeSemantics: true,
            child: Opacity(
              opacity: onMessage == null && !busy ? 0.5 : 1,
              child: Container(
                width: 86,
                height: 34,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: _radius,
                  boxShadow: [MessagesColors.buttonShadow],
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: _radius,
                    onTap: busy ? null : onMessage,
                    child: Center(
                      child: busy
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Message',
                              maxLines: 1,
                              style: messagesText(
                                13,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
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
