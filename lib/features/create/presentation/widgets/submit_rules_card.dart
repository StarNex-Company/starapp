import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/submit_icons.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// Challenge rules with a confirmation checkbox underneath.
class SubmitRulesCard extends StatelessWidget {
  const SubmitRulesCard({
    super.key,
    required this.rules,
    required this.confirmed,
    required this.onConfirmedChanged,
  });

  final List<String> rules;
  final bool confirmed;
  final ValueChanged<bool> onConfirmedChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: StarDividedCard.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          SubmitRuleList(rules: rules),
          const ColoredBox(
            color: AppColors.borderField,
            child: SizedBox(height: 1),
          ),
          Semantics(
            checked: confirmed,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onConfirmedChanged(!confirmed),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  spacing: 10,
                  children: [
                    _Checkbox(checked: confirmed),
                    const Expanded(
                      child: Text(
                        'I confirm my entry follows the rules',
                        style: TextStyle(
                          height: 1.2,
                          letterSpacing: 0,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rules as green-check bullets.
class SubmitRuleList extends StatelessWidget {
  const SubmitRuleList({super.key, required this.rules});

  final List<String> rules;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        for (final rule in rules)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.successTint,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  SubmitIcons.ruleCheck,
                  width: 13,
                  height: 13,
                ),
              ),
              Expanded(
                child: Text(
                  rule,
                  style: const TextStyle(
                    letterSpacing: 0,
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? AppColors.brandBlue : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: checked
            ? null
            : Border.all(color: AppColors.borderControl, width: 1.5),
      ),
      child: checked
          ? SvgPicture.asset(SubmitIcons.check, width: 14.3, height: 14.3)
          : null,
    );
  }
}
