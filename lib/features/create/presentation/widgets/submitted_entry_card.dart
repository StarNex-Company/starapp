import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _reviewTint = Color(0xFFFFF7E6); // surface/tint/fff7e6
const _reviewText = Color(0xFFB45309);
const _reviewDot = 'assets/vectors/create/submitted_dot.svg';

/// Card summarising the entry that was just sent: thumbnail, title, when it
/// was submitted and an "In review" status pill.
class SubmittedEntryCard extends StatelessWidget {
  const SubmittedEntryCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.submittedLabel,
  });

  final String? thumbnail;
  final String title;

  /// e.g. "Submitted just now".
  final String submittedLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: submittedCardDecoration,
      child: Row(
        spacing: 12,
        children: [
          _Thumbnail(thumbnail),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  submittedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    letterSpacing: 0,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          const _InReviewPill(),
        ],
      ),
    );
  }
}

/// White 16px-radius card with the faint drop shadow used on this screen.
const submittedCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  border: Border.fromBorderSide(BorderSide(color: AppColors.borderField)),
  boxShadow: [
    BoxShadow(color: Color(0x0F0B1020), offset: Offset(0, 4), blurRadius: 9),
  ],
);

class _Thumbnail extends StatelessWidget {
  const _Thumbnail(this.asset);

  final String? asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: 56,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StarImage(asset),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 28,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x0007090D), Color(0xB307090D)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InReviewPill extends StatelessWidget {
  const _InReviewPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: _reviewTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(_reviewDot, width: 6, height: 6),
          const Text(
            'In review',
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: _reviewText,
            ),
          ),
        ],
      ),
    );
  }
}
