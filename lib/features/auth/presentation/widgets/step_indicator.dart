import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Registration progress bar (Figma "Progress"): [totalSteps] bars, 4 high,
/// radius 50, 7px apart, sharing the width (81 each at 345). Bars up to and
/// including [currentStep] are #00993B, the rest #00993B @ 25%.
///
/// [currentStep] is **0-based** (`0` = step 1 of 4). `AuthScaffold(step: n)`
/// takes a 1-based step and adds the 24px side padding for you.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < totalSteps; i++) {
      if (i > 0) children.add(const SizedBox(width: 7));
      children.add(
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 4,
            decoration: BoxDecoration(
              color: i <= currentStep
                  ? AppColors.authStepActive
                  : AppColors.authStepInactive,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: 'Step ${currentStep + 1} of $totalSteps',
      child: Row(children: children),
    );
  }
}
