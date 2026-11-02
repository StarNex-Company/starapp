import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/search/data/models/search_models.dart';
import 'package:starapp/features/search/presentation/widgets/search_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _subtitleStyle = TextStyle(
  fontSize: 12,
  height: searchLeading,
  letterSpacing: 0,
  color: AppColors.textSubtle,
);

/// Creator result: ringed avatar, name, "@handle · tier" and a Follow toggle.
class SearchCreatorRow extends StatelessWidget {
  const SearchCreatorRow({
    super.key,
    required this.creator,
    required this.following,
    required this.onTap,
    required this.onFollowTap,
  });

  final CreatorSummary creator;
  final bool following;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final tier = creator.tier;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              _RingedAvatar(imageUrl: creator.avatarUrl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      creator.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: searchLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      tier == null
                          ? '@${creator.handle}'
                          : '@${creator.handle} · ${tier.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _subtitleStyle,
                    ),
                  ],
                ),
              ),
              _FollowButton(following: following, onTap: onFollowTap),
            ],
          ),
        ),
      ),
    );
  }
}

/// 48px avatar: light-blue ring, 2px white gap, 40px photo.
class _RingedAvatar extends StatelessWidget {
  const _RingedAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(SearchIcons.ring, width: 48, height: 48),
          SvgPicture.asset(SearchIcons.ringGap, width: 44, height: 44),
          StarAvatar(imageUrl, size: 40),
        ],
      ),
    );
  }
}

/// "Toggle Follow" component: navy gradient "Follow", outlined "Following".
class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.following, required this.onTap});

  final bool following;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: following,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 86,
        height: 34,
        decoration: BoxDecoration(
          gradient: following ? null : AppColors.brandGradient,
          color: following ? Colors.white : null,
          borderRadius: _radius,
          border: following
              ? Border.all(color: AppColors.brandBlue, width: 1.5)
              : null,
          boxShadow: following
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x2E032886),
                    offset: Offset(0, 6),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: _radius,
            child: Center(
              child: Text(
                following ? 'Following' : 'Follow',
                style: TextStyle(
                  fontSize: 13,
                  height: searchLeading,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: following ? AppColors.brandBlue : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "890 entries · ends in 4d 18h", "412 entries · starts in 3d" or
/// "Sep 2026 · winners announced".
String _statusLine(SearchChallenge challenge) {
  final entries = '${formatCompact(challenge.entries)} entries';
  final now = DateTime.now();
  return switch (challenge.status) {
    SearchChallengeStatus.upcoming => switch (challenge.startsAt) {
      final starts? => '$entries · starts in ${_countdown(starts, now)}',
      null => '$entries · starting soon',
    },
    SearchChallengeStatus.live => switch (challenge.endsAt) {
      final ends? => '$entries · ends in ${_countdown(ends, now)}',
      null => entries,
    },
    SearchChallengeStatus.ended => switch (challenge.endsAt) {
      final ended? =>
        '${DateFormat('MMM y').format(ended)} · winners announced',
      null => 'Winners announced',
    },
  };
}

/// Time until [moment], rounded up: "4d 18h", "3d", "6h 5m", "12m".
String _countdown(DateTime moment, DateTime now) {
  final minutes = (moment.difference(now).inSeconds / 60).ceil();
  if (minutes < 60 * 24) {
    final h = minutes ~/ 60, m = minutes % 60;
    if (h == 0) return '${m < 1 ? 1 : m}m';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
  final hours = (minutes / 60).ceil();
  final d = hours ~/ 24, h = hours % 24;
  return h == 0 ? '${d}d' : '${d}d ${h}h';
}

/// Challenge result: trophy tile, title, status line and a chevron.
class SearchChallengeRow extends StatelessWidget {
  const SearchChallengeRow({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  final SearchChallenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  SearchIcons.trophy,
                  width: 20,
                  height: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      challenge.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: searchLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      _statusLine(challenge),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _subtitleStyle,
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(SearchIcons.chevron, width: 18, height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
