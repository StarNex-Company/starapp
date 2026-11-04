import 'package:flutter/material.dart';

/// Text style for the Challenges hub. [lineHeight] is the design's line
/// height in px; without it Inter's "normal" leading is used. Leading is
/// split evenly above and below the glyphs, the way the design lays text out.
TextStyle hubText(
  double size,
  FontWeight weight,
  Color color, {
  double? lineHeight,
  double tracking = 0,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: lineHeight == null ? 1.21 : lineHeight / size,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: tracking,
  );
}

abstract final class HubIcons {
  static const _dir = 'assets/vectors/challenges';

  static const filters = 'assets/vectors/shared/ic_filters.svg';
  static const history = '$_dir/hub_ic_history.svg';
  static const myEntries = '$_dir/hub_ic_my_entries.svg';
  static const hallOfFame = '$_dir/hub_ic_hall_of_fame.svg';
  static const featured = '$_dir/hub_ic_featured.svg';
  static const timer = '$_dir/hub_ic_timer.svg';
  static const prize = '$_dir/hub_ic_prize.svg';
  static const group = '$_dir/hub_ic_group.svg';
  static const crown = '$_dir/hub_ic_crown.svg';
  static const starGold = '$_dir/hub_ic_star_gold.svg';
  static const starBlue = '$_dir/hub_ic_star_blue.svg';
  static const bolt = '$_dir/hub_ic_bolt.svg';
  static const leaderboard = '$_dir/hub_ic_leaderboard.svg';
  static const daysLeft = '$_dir/hub_ic_days_left.svg';
  static const starVote = '$_dir/hub_ic_star_vote.svg';
  static const arrowRight = '$_dir/hub_ic_arrow_right.svg';
  static const palette = '$_dir/hub_ic_palette.svg';
}
