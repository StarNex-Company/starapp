import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';

const _shieldIcon = 'assets/vectors/create/ic_shield.svg';

/// Tinted note explaining that entries are reviewed before going live.
class UploadingReviewNotice extends StatelessWidget {
  const UploadingReviewNotice({super.key});

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
          SvgPicture.asset(_shieldIcon, width: 20, height: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  'Your content is being reviewed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
                Text(
                  'We check every entry before it goes on the leaderboard. '
                  'Feel free to keep exploring while we finish up.',
                  style: TextStyle(
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
