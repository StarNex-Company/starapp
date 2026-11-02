/// Display text for the create flow's values. Models carry dates, durations
/// and byte counts; the create screens format them here.
library;

import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/create/data/models/challenge_summary.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';

/// Time left until [endsAt]: "4d 18h", "12d", then "5h 12m" on the last day.
String formatTimeLeft(DateTime endsAt, {DateTime? now}) {
  var left = endsAt.difference(now ?? DateTime.now());
  if (left.isNegative) left = Duration.zero;
  final hours = left.inHours.remainder(24);
  if (left.inDays > 0) {
    return hours == 0 ? '${left.inDays}d' : '${left.inDays}d ${hours}h';
  }
  return '${left.inHours}h ${left.inMinutes.remainder(60)}m';
}

/// "ends in 4d 18h", or why the entry can't go in.
String challengeStatus(ChallengeSummary challenge) => challenge.isEligible
    ? 'ends in ${formatTimeLeft(challenge.endsAt)}'
    : challenge.ineligibleReason ?? 'not open to this entry';

/// The kept part of a clip: "0:04 – 0:48 · 44s".
String formatTrim(ClipTrim trim) =>
    '${formatDuration(trim.start)} – ${formatDuration(trim.end)} · '
    '${trim.length.inSeconds}s';

/// [bytes] in megabytes: "59.6 MB", "112 MB".
double megabytes(int bytes) => bytes / 1000000;
