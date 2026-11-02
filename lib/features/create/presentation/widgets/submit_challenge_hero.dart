import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/submit_icons.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _pillBg = Color(0x2EFFFFFF); // white @ 18%
const _metaText = Color(0xFFD1D5DB);

/// Banner for the challenge being entered: category, title, prize, entries.
class SubmitChallengeHero extends StatelessWidget {
  const SubmitChallengeHero({
    super.key,
    required this.image,
    required this.category,
    required this.title,
    required this.prize,
    required this.entries,
  });

  final String? image;
  final String category;
  final String title;

  /// e.g. "$10,000 Grand Prize".
  final String prize;

  /// e.g. "890 / 1,000 entries".
  final String entries;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 156),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Positioned.fill(child: StarImage(image)),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x1A07090D), Color(0xE607090D)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      color: _pillBg,
                      borderRadius: BorderRadius.all(Radius.circular(11)),
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          height: 1.2,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1.2,
                      letterSpacing: 0,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      SvgPicture.asset(
                        SubmitIcons.trophy,
                        width: 14,
                        height: 14,
                      ),
                      Flexible(
                        child: Text(
                          prize,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.2,
                            letterSpacing: 0,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '· $entries',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.2,
                            letterSpacing: 0,
                            fontSize: 12,
                            color: _metaText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
