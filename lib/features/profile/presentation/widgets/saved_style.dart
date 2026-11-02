import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Inter's "normal" line height, so text boxes match the design.
const savedLeading = 1.21;

abstract final class SavedIcons {
  static const _dir = 'assets/vectors/profile';

  static const bookmark = '$_dir/saved_ic_bookmark.svg';
  static const grid = '$_dir/saved_ic_grid.svg';
  static const list = '$_dir/saved_ic_list.svg';
  static const play = 'assets/vectors/challenges/detail_ic_play_small.svg';
}

abstract final class SavedColors {
  /// rgba(7, 9, 13, 0) → 0.7: the scrim over a thumbnail's lower half.
  static const scrimStart = Color(0x0007090D);
  static const scrimEnd = Color(0xB307090D);
}

/// When a post was saved, as the list shows it after "saved": "this week",
/// "last week", "in October" ("in October 2025" for another year).
String formatSavedWhen(DateTime savedAt, {DateTime? now}) {
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final days = today.difference(DateUtils.dateOnly(savedAt)).inDays;
  if (days < 7) return 'this week';
  if (days < 14) return 'last week';
  final month = savedAt.year == today.year
      ? DateFormat('MMMM')
      : DateFormat('MMMM y');
  return 'in ${month.format(savedAt)}';
}
