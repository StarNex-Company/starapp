import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/messages/data/models/conversation.dart';
import 'package:starapp/features/messages/data/models/participant.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_form_fields.dart';

/// A row in a sheet: icon tile, label (and optional detail), chevron.
class SheetActionRow extends StatelessWidget {
  const SheetActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.detail,
    this.danger = false,
  });

  final String icon;
  final String label;
  final String? detail;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: danger ? AppColors.dangerTint : AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(icon, width: 20, height: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: messagesText(
                        15,
                        weight: FontWeight.w500,
                        color: danger ? AppColors.danger : AppColors.ink,
                      ),
                    ),
                    if (detail != null)
                      Text(
                        detail!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: messagesText(12, color: AppColors.textSubtle),
                      ),
                  ],
                ),
              ),
              SvgPicture.asset(
                danger ? MessagesIcons.chevronDanger : MessagesIcons.chevron,
                width: 18,
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ConversationMenuAction { profile, mute, report }

/// The ⋯ menu: the counterpart's profile, mute and report. Voice and video
/// calls are designed but not built yet, so they're left out.
Future<ConversationMenuAction?> showConversationMenu(
  BuildContext context,
  Conversation conversation,
) {
  final p = conversation.counterpart;
  return showStarSheet<ConversationMenuAction>(
    context: context,
    builder: (sheet) {
      void pick(ConversationMenuAction action) =>
          Navigator.of(sheet).pop(action);
      return StarSheet(
        title: p.displayName,
        subtitle: switch (p.kind) {
          ParticipantKind.company =>
            p.isVerified ? 'Verified company' : (p.roleLabel ?? 'Company'),
          ParticipantKind.creator => p.handle == null ? null : '@${p.handle}',
          ParticipantKind.system => p.roleLabel,
        },
        children: [
          if (p.kind != ParticipantKind.system)
            SheetActionRow(
              icon: MessagesIcons.briefcase,
              label: p.kind == ParticipantKind.company
                  ? 'View company profile'
                  : 'View profile',
              onTap: () => pick(ConversationMenuAction.profile),
            ),
          SheetActionRow(
            icon: MessagesIcons.slash,
            label: conversation.isMuted
                ? 'Unmute conversation'
                : 'Mute conversation',
            onTap: () => pick(ConversationMenuAction.mute),
          ),
          SheetActionRow(
            icon: MessagesIcons.flag,
            label: 'Report',
            danger: true,
            onTap: () => pick(ConversationMenuAction.report),
          ),
        ],
      );
    },
  );
}

enum AttachOption { media, document, talentPassport }

/// "+" in the composer: photo or video, document, or the Talent Passport.
Future<AttachOption?> showAttachSheet(BuildContext context) {
  return showStarSheet<AttachOption>(
    context: context,
    builder: (sheet) {
      void pick(AttachOption option) => Navigator.of(sheet).pop(option);
      return StarSheet(
        title: 'Attach',
        children: [
          SheetActionRow(
            icon: MessagesIcons.image,
            label: 'Photo or video',
            detail: 'From your gallery',
            onTap: () => pick(AttachOption.media),
          ),
          SheetActionRow(
            icon: MessagesIcons.file,
            label: 'Document',
            detail: 'PDF, up to 20 MB',
            onTap: () => pick(AttachOption.document),
          ),
          SheetActionRow(
            icon: MessagesIcons.idCard,
            label: 'Talent Passport',
            detail: 'Share your portfolio link',
            onTap: () => pick(AttachOption.talentPassport),
          ),
        ],
      );
    },
  );
}

/// The user's counter to an offer: their rate and a note.
typedef CounterOfferInput = ({Money amount, String note});

Future<CounterOfferInput?> showCounterOfferSheet(
  BuildContext context, {
  required String subtitle,
  required String recipient,
  required Money current,
}) {
  return showStarSheet<CounterOfferInput>(
    context: context,
    builder: (sheet) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom),
      child: _CounterOfferSheet(
        subtitle: subtitle,
        recipient: recipient,
        current: current,
      ),
    ),
  );
}

class _CounterOfferSheet extends StatefulWidget {
  const _CounterOfferSheet({
    required this.subtitle,
    required this.recipient,
    required this.current,
  });

  final String subtitle;
  final String recipient;
  final Money current;

  @override
  State<_CounterOfferSheet> createState() => _CounterOfferSheetState();
}

class _CounterOfferSheetState extends State<_CounterOfferSheet> {
  final _rate = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _rate.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _major => int.tryParse(_rate.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final symbol = currencySymbol(widget.current.currency.code);

    return StarSheet(
      title: 'Counter offer',
      subtitle: widget.subtitle,
      children: [
        _Field(
          label: 'Your rate',
          child: TextField(
            controller: _rate,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
              _GroupedDigitsFormatter(),
            ],
            onChanged: (_) => setState(() {}),
            style: _fieldText,
            decoration: _decoration(
              hint: formatGrouped(widget.current.major.round()),
              prefix: symbol,
              minHeight: 52,
            ),
          ),
        ),
        _Field(
          label: 'Note to ${widget.recipient}',
          child: TextField(
            controller: _note,
            minLines: 3,
            maxLines: 5,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            style: _fieldText,
            decoration: _decoration(
              hint: 'Say what the rate covers',
              minHeight: 90,
            ).copyWith(counterText: ''),
          ),
        ),
        StarPrimaryButton(
          label: 'Send counter offer',
          onPressed: _major <= 0
              ? null
              : () => Navigator.of(context).pop<CounterOfferInput>((
                  amount: Money.major(_major, widget.current.currency),
                  note: _note.text.trim(),
                )),
        ),
      ],
    );
  }

  static final _fieldText = messagesText(15, height: 22 / 15);

  static InputDecoration _decoration({
    required String hint,
    required double minHeight,
    String? prefix,
  }) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.borderField),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: messagesText(15, height: 22 / 15, color: AppColors.textFaint),
      prefixText: prefix,
      prefixStyle: _fieldText,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      constraints: BoxConstraints(minHeight: minHeight),
      contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      enabledBorder: border,
      border: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.brandBlue, width: 1.5),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [StarSectionLabel(label), child],
    );
  }
}

/// 1100000 → "1,100,000" as the user types.
class _GroupedDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = formatGrouped(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
