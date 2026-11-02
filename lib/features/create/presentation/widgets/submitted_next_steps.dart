import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/submitted_entry_card.dart';

/// "What happens next" card listing numbered [steps].
class SubmittedNextSteps extends StatelessWidget {
  const SubmittedNextSteps({
    super.key,
    this.title = 'What happens next',
    required this.steps,
  });

  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: submittedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              height: 1.2,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
          for (var i = 0; i < steps.length; i++)
            _Step(number: i + 1, text: steps[i]),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.brandTint,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 11,
              height: 1.2,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              color: AppColors.brandBlue,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0,
              color: AppColors.textBody,
            ),
          ),
        ),
      ],
    );
  }
}
