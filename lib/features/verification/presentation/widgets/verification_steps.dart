import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/verification/data/models/verification.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_style.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// The requirements checklist in a bordered card: a status rail down the
/// left, each step's title and detail beside it. [currentStepBody] (the ID
/// chips and upload box) sits under the step in progress.
class VerificationSteps extends StatelessWidget {
  const VerificationSteps({
    super.key,
    required this.steps,
    this.currentStepBody,
  });

  final List<VerificationStep> steps;
  final Widget? currentStepBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: StarDividedCard.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              step: steps[i],
              number: i + 1,
              last: i == steps.length - 1,
              body: steps[i].status == VerificationStepStatus.current
                  ? currentStepBody
                  : null,
            ),
        ],
      ),
    );
  }
}

/// The progress or hint line under a step's title, e.g. "64 / 50
/// followers", "Accepted · Oct 2".
String _detail(VerificationStep step) {
  final (progress, target, completedAt) = (
    step.progress,
    step.target,
    step.completedAt,
  );
  if (progress != null && target != null) {
    return switch (step.requirement) {
      VerificationRequirement.posts => '$progress / $target posted',
      VerificationRequirement.followers => '$progress / $target followers',
      _ => '$progress / $target',
    };
  }
  return switch (step.status) {
    VerificationStepStatus.done => [
      step.requirement == VerificationRequirement.conduct ? 'Accepted' : 'Done',
      if (completedAt != null) DateFormat('MMM d').format(completedAt),
    ].join(' · '),
    VerificationStepStatus.current =>
      step.requirement == VerificationRequirement.identity
          ? 'Choose a document type'
          : 'In progress',
    VerificationStepStatus.locked =>
      step.requirement == VerificationRequirement.selfie
          ? 'Unlocks after your ID upload'
          : 'Unlocks after the steps above',
  };
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.number,
    required this.last,
    this.body,
  });

  final VerificationStep step;
  final int number;
  final bool last;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final status = step.status;
    final locked = status == VerificationStepStatus.locked;
    final titleColor = locked ? AppColors.textSubtle : AppColors.ink;
    final detailColor = switch (status) {
      VerificationStepStatus.done => VerificationColors.successText,
      _ => AppColors.textSubtle,
    };

    return Semantics(
      container: true,
      label: switch (status) {
        VerificationStepStatus.done => 'Done',
        VerificationStepStatus.current => 'Step $number, in progress',
        VerificationStepStatus.locked => 'Locked',
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 15,
                    height: verificationLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                Text(
                  _detail(step),
                  style: TextStyle(
                    fontSize: 12,
                    height: verificationLeading,
                    letterSpacing: 0,
                    color: detailColor,
                  ),
                ),
                if (body != null) ...[
                  // The design's 4px spacer between the hint and the chips.
                  const SizedBox(height: 4),
                  body!,
                ],
              ],
            ),
          ),
          Positioned(left: 0, top: 0, child: _StatusDot(status, number)),
          if (!last)
            Positioned(
              left: 13,
              top: 28,
              width: 2,
              // The open step's line stops just short of the next dot.
              bottom: status == VerificationStepStatus.done ? 0 : 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: status == VerificationStepStatus.done
                      ? AppColors.success
                      : AppColors.borderField,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot(this.status, this.number);

  final VerificationStepStatus status;
  final int number;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      VerificationStepStatus.done => _dot(
        color: AppColors.success,
        child: SvgPicture.asset(VerificationIcons.check, width: 15, height: 15),
      ),
      VerificationStepStatus.current => _dot(
        color: AppColors.brandBlue,
        border: Border.all(color: VerificationColors.currentRing, width: 3),
        child: Text(
          '$number',
          maxLines: 1,
          style: const TextStyle(
            fontSize: 13,
            height: verificationLeading,
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      VerificationStepStatus.locked => _dot(
        color: AppColors.closeButtonBg,
        child: SvgPicture.asset(VerificationIcons.lock, width: 13, height: 13),
      ),
    };
  }

  Widget _dot({required Color color, required Widget child, Border? border}) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border,
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: child),
    );
  }
}
