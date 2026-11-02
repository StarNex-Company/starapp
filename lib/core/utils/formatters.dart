/// Display formatting for the raw values models carry. Models hold numbers
/// and dates; widgets call these.
library;

import 'package:intl/intl.dart';

final _compact = NumberFormat.compact(locale: 'en_US');
final _grouped = NumberFormat.decimalPattern('en_US');

/// 950 → "950", 48200 → "48.2K", 1200000 → "1.2M".
String formatCompact(num value) => _compact.format(value);

/// 1940 → "1,940".
String formatGrouped(num value) => _grouped.format(value);

/// 24 → "+24%", -3 → "-3%", 0 → "0%".
String formatChange(num percent) {
  final rounded = percent % 1 == 0 ? percent.toInt() : percent;
  return percent > 0 ? '+$rounded%' : '$rounded%';
}

/// 0.519 → "52%".
String formatRatio(double ratio) => '${(ratio * 100).round()}%';

/// Money in its currency, e.g. ("NGN", 1240500) → "₦1,240,500".
/// Pass [fromMinorUnits] when [amount] is in kobo / cents, the usual API
/// shape for money.
String formatMoney(
  num amount, {
  String currency = 'NGN',
  bool fromMinorUnits = false,
  bool showDecimals = false,
}) {
  final value = fromMinorUnits ? amount / 100 : amount;
  return NumberFormat.currency(
    locale: 'en_US',
    name: currency,
    symbol: currencySymbol(currency),
    decimalDigits: showDecimals ? 2 : 0,
  ).format(value);
}

String currencySymbol(String currency) => switch (currency) {
  'NGN' => '₦',
  'USD' => r'$',
  'GBP' => '£',
  'EUR' => '€',
  'GHS' => 'GH₵',
  'KES' => 'KSh',
  _ => '$currency ',
};

/// How long ago, as the feeds show it: "now", "5m", "2h", "3d", "4w",
/// then the date ("Sep 14", or "Sep 14, 2025" in another year).
String formatAge(DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(time);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 28) return '${diff.inDays ~/ 7}w';
  return time.year == current.year
      ? DateFormat('MMM d').format(time)
      : DateFormat('MMM d, y').format(time);
}

/// "5m ago", "2h ago"; "Just now" under a minute.
String formatAgo(DateTime time, {DateTime? now}) {
  final age = formatAge(time, now: now);
  if (age == 'now') return 'Just now';
  return RegExp(r'^\d+[mhdw]$').hasMatch(age) ? '$age ago' : age;
}

/// 75 → "1:15", 3725 → "1:02:05".
String formatDuration(Duration duration) {
  final h = duration.inHours;
  final m = duration.inMinutes.remainder(60);
  final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}
