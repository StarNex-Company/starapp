import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_style.dart';

/// The design's 151° navy sweep (#0b2a8f → #011a5e → #020c33), with the CSS
/// angle's end points worked out for the 345×189 card.
const _heroGradient = LinearGradient(
  begin: Alignment(-0.4615, -1.5390),
  end: Alignment(0.4615, 1.5390),
  colors: [AppColors.navyLight, AppColors.brandGradStart, AppColors.navyDeep],
  stops: [0, 0.6, 1],
);

const _radius = BorderRadius.all(Radius.circular(20));

/// "Become a Star Creator" card: shield badge, title and pitch on navy, with
/// the faint StarApp mark in the corner.
class VerificationHero extends StatelessWidget {
  const VerificationHero({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: _radius,
        gradient: _heroGradient,
        boxShadow: [
          BoxShadow(
            color: VerificationColors.heroShadow,
            offset: Offset(0, 10),
            blurRadius: 26,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      VerificationIcons.shieldCheck,
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const Text(
                    'Become a Star Creator',
                    style: TextStyle(
                      fontSize: 20,
                      height: verificationLeading,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Verified creators can enter monthly challenges, receive '
                    'Scout Requests and wear the verified badge.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 19 / 13,
                      letterSpacing: 0,
                      color: AppColors.onBrandSubtle,
                    ),
                  ),
                ],
              ),
            ),
            // 150×132 mark at 6% opacity, hanging 20px past the right edge.
            Positioned(
              top: 10,
              right: -20,
              child: IgnorePointer(
                child: SvgPicture.asset(
                  VerificationIcons.logoWatermark,
                  width: 150,
                  height: 132,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
