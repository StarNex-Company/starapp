import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';

/// "Entered Oct 9 · currently #14 · 331 Stars",
/// "Sep 2026 · finished #7 of 1,248", "Mar 2026 · completed · +50 Stars".
String _summary(ChallengeHistoryEntry e) {
  final month = DateFormat('MMM y').format(e.endedAt ?? e.enteredAt);
  final rank = e.rank;
  final entrants = e.entrants;
  final stars = e.stars;
  return switch (e.standing) {
    ChallengeStanding.live => [
      'Entered ${DateFormat('MMM d').format(e.enteredAt)}',
      if (rank != null) 'currently #$rank',
      if (stars != null) '${formatGrouped(stars)} Stars',
    ],
    ChallengeStanding.placed => [
      month,
      if (rank != null)
        entrants == null
            ? 'finished #$rank'
            : 'finished #$rank of ${formatGrouped(entrants)}',
    ],
    ChallengeStanding.completed => [
      month,
      'completed',
      if (stars != null) '+${formatGrouped(stars)} Stars',
    ],
  }.join(' · ');
}

/// The status pill: "Live", "Top 10" (or "#23" further down), "Done".
String _badge(ChallengeHistoryEntry e) => switch ((e.standing, e.rank)) {
  (ChallengeStanding.live, _) => 'Live',
  (ChallengeStanding.placed, final rank?) when rank > 10 => '#$rank',
  (ChallengeStanding.placed, _) => 'Top 10',
  (ChallengeStanding.completed, _) => 'Done',
};

/// A challenge the creator entered: icon tile, title, summary and a status
/// pill ("Live", "Top 10", "Done"). Tappable when [onTap] is set.
class MyProfileChallengeRow extends StatelessWidget {
  const MyProfileChallengeRow({super.key, required this.entry, this.onTap});

  final ChallengeHistoryEntry entry;
  final VoidCallback? onTap;

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    // A running challenge shows its music note; finished ones a trophy.
    final (icon, tint) = entry.standing == ChallengeStanding.live
        ? (MyProfileIcons.music, AppColors.brandTint)
        : (MyProfileIcons.trophy, MyProfileColors.trophyTint);

    return Semantics(
      button: onTap != null,
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(color: AppColors.borderField),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            // The design's 14/12 padding inside the 1px border.
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(icon, width: 20, height: 20),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: myProfileLeading,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        _summary(entry),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: myProfileLeading,
                          letterSpacing: 0,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(standing: entry.standing, label: _badge(entry)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.standing, required this.label});

  final ChallengeStanding standing;
  final String label;

  @override
  Widget build(BuildContext context) {
    final live = standing == ChallengeStanding.live;
    return Container(
      constraints: const BoxConstraints(minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: live ? AppColors.danger : MyProfileColors.trophyTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (live)
            SvgPicture.asset(MyProfileIcons.liveDot, width: 6, height: 6),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 10,
              height: myProfileLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: live ? Colors.white : AppColors.goldText,
            ),
          ),
        ],
      ),
    );
  }
}
