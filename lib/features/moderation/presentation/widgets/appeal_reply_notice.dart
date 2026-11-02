import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/moderation/presentation/widgets/appeal_icons.dart';

/// Tinted note on how long an appeal review takes.
class AppealReplyNotice extends StatelessWidget {
  const AppealReplyNotice({super.key});

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
          SvgPicture.asset(AppealIcons.clock, width: 20, height: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  'We reply within 48 hours',
                  style: TextStyle(
                    height: 1.2,
                    letterSpacing: 0,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
                Text(
                  "Your post stays paused while we review. You'll get a notification "
                  'with the decision.',
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
