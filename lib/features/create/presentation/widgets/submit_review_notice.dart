import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/submit_icons.dart';

/// Tinted note: entries are reviewed before going live.
class SubmitReviewNotice extends StatelessWidget {
  const SubmitReviewNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SvgPicture.asset(SubmitIcons.shield, width: 20, height: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  'Reviewed before it goes live',
                  style: TextStyle(
                    height: 1.2,
                    letterSpacing: 0,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
                Text(
                  "Our team checks every entry, usually in under 2 hours. We'll let "
                  'you know as soon as yours is on the leaderboard.',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 12.5,
                    height: 18 / 12.5,
                    color: AppColors.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
