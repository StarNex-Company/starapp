import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _pillGradient = LinearGradient(
  // CSS 168.69deg across the 24px-high pill.
  begin: Alignment(-0.08, -1.87),
  end: Alignment(0.08, 1.87),
  colors: [AppColors.goldLight, Color(0xFFF5C451), AppColors.goldDeep],
  stops: [0, 0.45, 1],
);

const _trophyIcon = 'assets/vectors/create/uploading_ic_trophy.svg';

/// White 16px-radius card with a faint drop shadow, shared by the upload
/// card and the steps list.
class UploadingPanel extends StatelessWidget {
  const UploadingPanel({super.key, required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.borderField)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0B1020),
            offset: Offset(0, 4),
            blurRadius: 9,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// The entry being uploaded: thumbnail, title, challenge and a progress bar
/// with its percentage and status line.
class UploadingCard extends StatelessWidget {
  const UploadingCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.challenge,
    required this.progress,
    required this.statusText,
  });

  final String? thumbnail;
  final String title;
  final String challenge;

  /// 0–1.
  final double progress;

  /// e.g. "Compressing · 59.6 MB".
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);

    return UploadingPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          _Thumbnail(thumbnail),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text(
                challenge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSubtle,
                ),
              ),
            ],
          ),
          _ProgressBar(value),
          Row(
            spacing: 12,
            children: [
              Text(
                '${(value * 100).round()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
              Expanded(
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSubtle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail(this.asset);

  final String? asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StarImage(asset),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 90,
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
            const Positioned(left: 10, top: 10, child: _ChallengeEntryPill()),
          ],
        ),
      ),
    );
  }
}

class _ChallengeEntryPill extends StatelessWidget {
  const _ChallengeEntryPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        gradient: _pillGradient,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          // The exported icon bleeds slightly past its 11px slot.
          SizedBox.square(
            dimension: 11,
            child: OverflowBox(
              maxWidth: 12,
              maxHeight: 12,
              child: SvgPicture.asset(_trophyIcon),
            ),
          ),
          const Text(
            'Challenge entry',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.inkDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar(this.value);

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.track,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: FractionallySizedBox(
        widthFactor: value,
        heightFactor: 1,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
      ),
    );
  }
}
