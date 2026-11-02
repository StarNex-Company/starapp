import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/preview_icons.dart';
import 'package:starapp/features/create/presentation/widgets/preview_settings_card.dart';

const _goldTint = Color(0xFFFFF8E1); // surface/tint/fff8e1

/// Gold card that opts the post into the monthly challenge.
class PreviewChallengeToggle extends StatelessWidget {
  const PreviewChallengeToggle({
    super.key,
    required this.challenge,
    required this.value,
    required this.onChanged,
  });

  /// e.g. "Afro-Beats Producer & Vocal Clash · ends in 4d 18h".
  final String challenge;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _goldTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.goldLight,
                  AppColors.gold,
                  AppColors.goldDeep,
                ],
                stops: [0, 0.45, 1],
              ),
            ),
            child: SvgPicture.asset(PreviewIcons.trophy, width: 20, height: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                const Text(
                  'Submit to monthly challenge',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.2,
                    letterSpacing: 0,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  challenge,
                  style: const TextStyle(
                    letterSpacing: 0,
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.goldText,
                  ),
                ),
              ],
            ),
          ),
          PreviewToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
