import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

abstract final class PassportIcons {
  static const _dir = 'assets/vectors/profile';

  static const glow = '$_dir/passport_glow.svg';
  static const watermark = '$_dir/passport_logo_watermark.svg';
  static const logo = '$_dir/passport_logo.svg';
  static const play = '$_dir/passport_ic_play.svg';
  static const starWhite = '$_dir/passport_ic_star_white.svg';
  static const starViolet = '$_dir/passport_ic_star_violet.svg';
  static const briefcase = '$_dir/passport_ic_briefcase.svg';
  static const link = '$_dir/passport_ic_link.svg';
  static const copy = '$_dir/passport_ic_copy.svg';

  // Identical files already in the app.
  static const share = 'assets/vectors/challenges/board_ic_share.svg';
  static const shareWhite = 'assets/vectors/challenges/detail_ic_share.svg';
  static const playSmall = 'assets/vectors/challenges/detail_ic_play_small.svg';
  static const starGold = 'assets/vectors/challenges/ic_star.svg';
  static const liveDot = 'assets/vectors/create/camera_rec_dot.svg';
  static const trophy = 'assets/vectors/shared/ic_trophy_tile.svg';
  static const music = '$_dir/me_ic_music.svg';
}

/// The dark Talent Passport card: brand, photo, name, tier, passport ID and
/// the AI score ring.
class PassportCard extends StatelessWidget {
  const PassportCard({
    super.key,
    required this.name,
    required this.handleLine,
    required this.avatarUrl,
    required this.tier,
    required this.passportId,
    required this.aiScore,
  });

  final String name;

  /// "@emmanuel · Lagos, Nigeria".
  final String handleLine;

  /// The photo; null shows the placeholder glyph.
  final String? avatarUrl;
  final String tier;
  final String passportId;
  final int aiScore;

  static const _caption = TextStyle(
    fontSize: 9,
    height: insightsLeading,
    letterSpacing: 1.08,
    fontWeight: FontWeight.w700,
    color: AppColors.textFaint,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 214,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.inkDeep,
            InsightsColors.passportMid,
            InsightsColors.passportEnd,
          ],
          stops: [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: InsightsColors.passportShadow,
            offset: Offset(0, 14),
            blurRadius: 34,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 150,
            top: -60,
            child: SvgPicture.asset(
              PassportIcons.glow,
              width: 260,
              height: 260,
            ),
          ),
          Positioned(
            left: 150,
            top: 30,
            child: SvgPicture.asset(
              PassportIcons.watermark,
              width: 230,
              height: 202,
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            top: 16,
            height: 23,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      SvgPicture.asset(
                        PassportIcons.logo,
                        width: 26,
                        height: 23,
                      ),
                      const Flexible(
                        child: Text(
                          'STAR APP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: insightsLeading,
                            letterSpacing: 1.56,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Flexible(
                  child: Text(
                    'TALENT PASSPORT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: insightsLeading,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(left: 18, top: 62, child: _Avatar(image: avatarUrl)),
          Positioned(
            left: 98,
            right: 18,
            top: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    height: insightsLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  handleLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: insightsLeading,
                    letterSpacing: 0,
                    color: AppColors.textFaint,
                  ),
                ),
                InsightsPill.tier(label: tier),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 160,
            top: 162,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                const Text('PASSPORT ID', maxLines: 1, style: _caption),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    passportId,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      height: insightsLeading,
                      letterSpacing: 0.56,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 18,
            top: 142,
            child: Row(
              spacing: 8,
              children: [
                const Text('AI SCORE', maxLines: 1, style: _caption),
                PassportScoreRing(score: aiScore),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    // Gold ring, a 3px dark gap, then the photo.
    return Container(
      width: 66,
      height: 66,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: InsightsColors.passportMid,
          shape: BoxShape.circle,
        ),
        child: StarAvatar(image, size: 56),
      ),
    );
  }
}

/// 58px ring filled clockwise from the top by [score] out of 100, in gold.
class PassportScoreRing extends StatelessWidget {
  const PassportScoreRing({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'AI score $score out of 100',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 58,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: score.clamp(0, 100) / 100),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) =>
              CustomPaint(painter: _ScorePainter(value), child: child),
          child: Center(
            child: Text(
              '$score',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 17,
                height: insightsLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePainter extends CustomPainter {
  _ScorePainter(this.fraction);

  final double fraction;

  /// 9% of the ring's size, as designed.
  static const _thicknessRatio = 0.09;

  @override
  void paint(Canvas canvas, Size size) {
    final thickness = size.shortestSide * _thicknessRatio;
    final rect = Offset.zero & size;
    final ring = rect.deflate(thickness / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = InsightsColors.scoreTrack;
    canvas.drawOval(ring, track);
    if (fraction <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDeep],
        stops: [0, 0.45, 1],
      ).createShader(rect);
    canvas.drawArc(ring, -math.pi / 2, 2 * math.pi * fraction, false, arc);
  }

  @override
  bool shouldRepaint(_ScorePainter old) => old.fraction != fraction;
}
