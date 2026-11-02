import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_style.dart';

/// Tinted "Private and encrypted" reassurance under the checklist.
class VerificationNotice extends StatelessWidget {
  const VerificationNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SvgPicture.asset(
            VerificationIcons.privacyLock,
            width: 20,
            height: 20,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  'Private and encrypted',
                  style: TextStyle(
                    fontSize: 14,
                    height: verificationLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
                Text(
                  "Your ID is only used to confirm it's you. It's never shown "
                  'on your profile or shared with companies.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 18 / 12.5,
                    letterSpacing: 0,
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
