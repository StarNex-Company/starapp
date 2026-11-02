import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/challenges/presentation/widgets/tier_celebration_style.dart';

const _radius = BorderRadius.all(Radius.circular(12));

/// 48px gold call-to-action of the celebration screens, e.g. "Share".
/// Fills the available width; inside a Row wrap it in Expanded.
class TierGoldButton extends StatelessWidget {
  const TierGoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Optional leading SVG asset, drawn at 18px.
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: const BoxDecoration(
        gradient: celebrationGold,
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: CelebrationColors.goldGlow,
            offset: Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: _radius,
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              if (icon != null) SvgPicture.asset(icon!, width: 18, height: 18),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.21,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkDeep,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
