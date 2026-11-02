import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_style.dart';

/// "3 of 5 steps complete · 60%" over an 8px bar that fills in on open.
class VerificationProgress extends StatelessWidget {
  const VerificationProgress({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: '$completed of $total steps complete',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: Text(
                  '$completed of $total steps complete',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: verificationLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  height: verificationLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
            ],
          ),
          Container(
            height: 8,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.track,
              borderRadius: BorderRadius.circular(4),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: animate ? 0 : progress, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
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
