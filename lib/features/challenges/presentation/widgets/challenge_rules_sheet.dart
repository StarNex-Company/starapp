import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/provider/challenges_providers.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_list_tile.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Slides a challenge's rules up over the current screen.
///
/// Rule details aren't built yet: tapping a rule closes the sheet and says
/// so on the screen underneath (a toast would be hidden behind the sheet).
Future<void> showChallengeRulesSheet(
  BuildContext context, {
  required String challengeId,
  required String challengeTitle,
}) async {
  final openedRule = await showStarSheet<ChallengeRule>(
    context: context,
    builder: (sheetContext) => _ChallengeRulesSheetLoader(
      challengeId: challengeId,
      challengeTitle: challengeTitle,
      onRule: (rule) => Navigator.pop(sheetContext, rule),
    ),
  );
  if (openedRule == null || !context.mounted) return;

  showStarToast(context, 'Coming soon');
}

/// Reads the rules from `challengeRulesProvider`; the sheet keeps its frame
/// while they load.
class _ChallengeRulesSheetLoader extends ConsumerWidget {
  const _ChallengeRulesSheetLoader({
    required this.challengeId,
    required this.challengeTitle,
    required this.onRule,
  });

  final String challengeId;
  final String challengeTitle;
  final ValueChanged<ChallengeRule> onRule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = challengeRulesProvider(challengeId);
    final rules = ref.watch(provider);
    if (rules.value case final loaded?) {
      return ChallengeRulesSheet(
        challengeTitle: challengeTitle,
        rules: loaded,
        onRule: onRule,
      );
    }
    return StarSheet(
      title: 'Challenge rules',
      children: [
        SizedBox(
          height: 160,
          child: StarAsyncView(
            value: rules,
            onRetry: () => ref.invalidate(provider),
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// "Challenge rules" sheet: one row per rule and a "Got it" button.
class ChallengeRulesSheet extends StatelessWidget {
  const ChallengeRulesSheet({
    super.key,
    required this.challengeTitle,
    required this.rules,
    required this.onRule,
  });

  final String challengeTitle;
  final List<ChallengeRule> rules;
  final ValueChanged<ChallengeRule> onRule;

  @override
  Widget build(BuildContext context) {
    return StarSheet(
      title: 'Challenge rules',
      subtitle: challengeTitle,
      children: [
        for (final rule in rules)
          ChallengeListTile(
            icon: ChallengeListIcons.of(rule.icon),
            title: rule.title,
            subtitle: rule.subtitle,
            onTap: () => onRule(rule),
          ),
        StarPrimaryButton(
          label: 'Got it',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
