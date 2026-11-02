import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

const _leading = 1.21;

/// How each choice reads in the sheet and on the Privacy & Security row.
extension WhoCanMessageText on WhoCanMessage {
  String get label => switch (this) {
    WhoCanMessage.everyone => 'Everyone',
    WhoCanMessage.following => 'People you follow',
    WhoCanMessage.verifiedCompanies => 'Verified companies only',
    WhoCanMessage.noOne => 'No one',
  };

  /// The short form on the Privacy & Security row, where the full label
  /// would crowd out the row's title.
  String get shortLabel => switch (this) {
    WhoCanMessage.everyone => 'Everyone',
    WhoCanMessage.following => 'Following',
    WhoCanMessage.verifiedCompanies => 'Verified',
    WhoCanMessage.noOne => 'No one',
  };

  String? get caption => switch (this) {
    WhoCanMessage.everyone => 'Anyone on Star App',
    WhoCanMessage.verifiedCompanies => 'Scouts with a verified badge',
    WhoCanMessage.following || WhoCanMessage.noOne => null,
  };
}

/// Figma "Sheet — Who Can Message Me" (`1589:6715`). Completes with the
/// picked option, or null when closed without a change.
Future<WhoCanMessage?> showWhoCanMessageSheet(
  BuildContext context, {
  required WhoCanMessage current,
}) {
  return showStarSheet<WhoCanMessage>(
    context: context,
    builder: (_) => WhoCanMessageSheet(current: current),
  );
}

class WhoCanMessageSheet extends StatelessWidget {
  const WhoCanMessageSheet({super.key, required this.current});

  final WhoCanMessage current;

  @override
  Widget build(BuildContext context) {
    return StarSheet(
      title: 'Who can message you?',
      subtitle: 'Applies to new conversations only',
      children: [
        for (final option in WhoCanMessage.values)
          _OptionRow(
            option: option,
            selected: option == current,
            onTap: () =>
                Navigator.of(context).pop(option == current ? null : option),
          ),
      ],
    );
  }
}

/// Radio, label and optional caption, 12px above and below.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final WhoCanMessage option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final caption = option.caption;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              spacing: 12,
              children: [
                StarRadioDot(selected: selected),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: _leading,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      if (caption != null)
                        Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: _leading,
                            letterSpacing: 0,
                            color: AppColors.textSubtle,
                          ),
                        ),
                    ],
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
