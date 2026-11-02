/// Display text for challenge values. Models carry dates, money and
/// counts; the challenge screens format them here.
library;

import 'package:intl/intl.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';

/// Time left until [endsAt]: "4d 18h", then "5h 12m" on the last day.
String formatTimeLeft(DateTime endsAt, {DateTime? now}) {
  final left = _left(endsAt, now);
  return left.inDays > 0
      ? '${left.inDays}d ${left.inHours.remainder(24)}h'
      : '${left.inHours}h ${left.inMinutes.remainder(60)}m';
}

/// Whole days left until [endsAt], as arena cards put it: "12 Days Left",
/// "1 Day Left", then "5h Left".
String formatDaysLeft(DateTime endsAt, {DateTime? now}) {
  final left = _left(endsAt, now);
  final days = left.inDays;
  if (days > 1) return '$days Days Left';
  if (days == 1) return '1 Day Left';
  return '${left.inHours}h Left';
}

/// Time left as a non-negative [Duration].
Duration timeLeft(DateTime endsAt, {DateTime? now}) => _left(endsAt, now);

Duration _left(DateTime endsAt, DateTime? now) {
  final left = endsAt.difference(now ?? DateTime.now());
  return left.isNegative ? Duration.zero : left;
}

/// "Oct 31 · 23:59 WAT"; the zone shows only when it has a short name.
String formatDeadline(DateTime at) {
  final zone = at.timeZoneName;
  final time = DateFormat('MMM d · HH:mm').format(at);
  return zone.length <= 5 ? '$time $zone' : time;
}

/// "Sep 2026".
String formatMonth(DateTime at) => DateFormat('MMM y').format(at);

/// "September 2026".
String formatLongMonth(DateTime at) => DateFormat('MMMM y').format(at);

/// "Nov 12".
String formatDay(DateTime at) => DateFormat('MMM d').format(at);

/// "$10,000 Grand Prize".
String prizeTitle(ChallengePrize prize) =>
    '${prize.amount.format()} ${prize.kind.label}';

/// The non-empty [parts] joined with a middle dot: "Lagos, NG · Lamba Groove".
String joinDetails(Iterable<String?> parts, {String separator = ' · '}) => [
  for (final part in parts)
    if (part != null && part.isNotEmpty) part,
].join(separator);
