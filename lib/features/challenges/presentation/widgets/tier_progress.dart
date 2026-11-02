import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_celebration_style.dart';

/// "Next: Super Nova" style heading with the Star count and an 8px
/// violet → gold progress bar.
class TierNextProgress extends StatelessWidget {
  const TierNextProgress({
    super.key,
    required this.nextTier,
    required this.countLabel,
    required this.progress,
  });

  final String nextTier;

  /// e.g. "2,050 / 10,001".
  final String countLabel;

  /// 0..1 through the current tier.
  final double progress;

  // The fill never shrinks below a readable stub.
  static const _minFill = 14.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: Text(
                'Next: $nextTier',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.21,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            Text(
              countLabel,
              style: const TextStyle(
                fontSize: 12,
                height: 1.21,
                letterSpacing: 0,
                color: CelebrationColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          height: 8,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            color: CelebrationColors.brandWash,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Container(
                width: (progress.clamp(0.0, 1.0) * width).clamp(
                  _minFill,
                  width,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  gradient: LinearGradient(
                    colors: [CelebrationColors.violet, AppColors.gold],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
