import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/models/budget_range.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';
import 'package:starapp/features/scout/data/models/talent_category.dart';

/// Inter's "normal" line height, so text boxes match the design.
const scoutLeading = 1.21;

abstract final class ScoutIcons {
  static const _dir = 'assets/vectors/scout';

  // Identical files other screens already ship.
  static const chevron = 'assets/vectors/challenges/rules_ic_chevron.svg';
  static const search = 'assets/vectors/profile/connections_ic_search.svg';
  static const sliders = 'assets/vectors/challenges/board_ic_sliders.svg';
  static const shield = 'assets/vectors/create/ic_shield.svg';
  static const calendar = 'assets/vectors/challenges/rules_ic_calendar.svg';
  static const briefcase = 'assets/vectors/settings/privacy_ic_briefcase.svg';
  static const music = 'assets/vectors/challenges/rules_ic_music.svg';
  static const zap = 'assets/vectors/challenges/upcoming_ic_zap.svg';
  static const video = 'assets/vectors/settings/settings_ic_video.svg';
  static const star = 'assets/vectors/challenges/entries_ic_star.svg';
  static const lock = 'assets/vectors/settings/privacy_ic_lock.svg';
  static const message = 'assets/vectors/create/preview_ic_message.svg';
  static const fileRed = 'assets/vectors/moderation/appeal_ic_file.svg';

  static const briefcaseSmall = '$_dir/scout_ic_briefcase_14.svg';
  static const calendar13 = '$_dir/scout_ic_calendar_13.svg';
  static const calendar14 = '$_dir/scout_ic_calendar_14.svg';
  static const checkApplied = '$_dir/scout_ic_check_applied.svg';
  static const check = '$_dir/scout_ic_check.svg';
  static const download = '$_dir/scout_ic_download.svg';
  static const file14 = '$_dir/scout_ic_file_14.svg';
  static const flag = '$_dir/scout_ic_flag.svg';
  static const glow = '$_dir/scout_featured_glow.svg';
  static const pin13 = '$_dir/scout_ic_pin_13.svg';
  static const pin14 = '$_dir/scout_ic_pin_14.svg';
  static const pin20 = '$_dir/scout_ic_pin_20.svg';
  static const pinWhite = '$_dir/scout_ic_pin_white.svg';
  static const send = '$_dir/scout_ic_send.svg';
  static const shieldAmber = '$_dir/scout_ic_shield_amber.svg';
  static const shieldCheck = '$_dir/scout_ic_shield_check.svg';
  static const sparkle = '$_dir/scout_ic_sparkle.svg';
  static const starSmall = '$_dir/scout_ic_star_11.svg';
  static const bannerLogo = '$_dir/scout_banner_logo.svg';
  static const users = '$_dir/scout_ic_users.svg';
  static const verified13 = '$_dir/scout_ic_verified_13.svg';
  static const verified14 = '$_dir/scout_ic_verified_14.svg';
  static const verified18 = '$_dir/scout_ic_verified_18.svg';
  static const wallet13 = '$_dir/scout_ic_wallet_13.svg';
  static const wallet14 = '$_dir/scout_ic_wallet_14.svg';
  static const wallet20 = '$_dir/scout_ic_wallet_20.svg';

  /// The 20px tile icon for a category.
  static String category(TalentCategory? category) => switch (category) {
    TalentCategory.music => music,
    TalentCategory.dance => zap,
    TalentCategory.acting => video,
    TalentCategory.comedy || TalentCategory.visualArts || null => briefcase,
  };
}

/// Scout colours that aren't app-wide tokens.
abstract final class ScoutColors {
  /// surface/muted/eef0f5: the segmented control track.
  static const segmentTrack = Color(0xFFEEF0F5);

  /// surface/muted/e2e5ec: count pill.
  static const countPill = Color(0xFFE2E5EC);

  /// surface/tint/fff7e6 and its text: "In review", "Stay safe".
  static const amberTint = Color(0xFFFFF7E6);
  static const amberText = Color(0xFFB45309);

  /// surface/tint/fff8e1: the Stars bonus notice.
  static const starsTint = Color(0xFFFFF8E1);

  /// Green text on [AppColors.successTint].
  static const successText = Color(0xFF15803D);

  /// text/body/3a4255: the call description.
  static const bodyAlt = Color(0xFF3A4255);

  /// Featured card subtitles.
  static const featuredMuted = Color(0xFFAFC0F5);
  static const onDarkPill = Color(0x24FFFFFF);
  static const onDarkBorder = Color(0x59FFFFFF);

  /// toggle-off knob.
  static const knobOff = Color(0xFFC2C2C2);

  static const cardShadow = BoxShadow(
    color: Color(0x0F0B1020),
    offset: Offset(0, 4),
    blurRadius: 9,
  );

  /// Featured card fill (CSS 140.8deg over the 345×281 card).
  static final featuredGradient = cssLinearGradient(
    140.84,
    const Size(345, 281),
    const [AppColors.navyLight, AppColors.brandGradStart, AppColors.navyDeep],
    stops: const [0, 0.6, 1],
  );

  /// Gold fill of the featured "Apply now" button and pill.
  static LinearGradient gold(double degrees, Size size) => cssLinearGradient(
    degrees,
    size,
    const [AppColors.goldLight, AppColors.gold, AppColors.goldDeep],
    stops: const [0, 0.45, 1],
  );

  /// Logo placeholders: companies without a logo get one, picked by id.
  static const _logoGradients = [
    [Color(0xFF7C5CFF), Color(0xFF3BA7FF)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF14B8A6), Color(0xFF3BA7FF)],
    [Color(0xFFEC4899), Color(0xFF7C5CFF)],
    [Color(0xFF22C55E), Color(0xFF14B8A6)],
  ];

  /// The placeholder colours for [companyId]: 135deg on a square logo,
  /// or pass [degrees] and [size] for a banner.
  static LinearGradient logoGradient(
    String companyId, {
    double degrees = 135,
    Size size = const Size.square(1),
  }) {
    final hash = companyId.codeUnits.fold(0, (h, c) => (h * 31 + c) & 0xFFFF);
    return cssLinearGradient(
      degrees,
      size,
      _logoGradients[hash % _logoGradients.length],
    );
  }
}

/// A CSS `linear-gradient(<degrees>deg, …)` on a box of [size]: the
/// gradient line runs through the centre and reaches the far corners, as in
/// the browser (and Figma's export).
LinearGradient cssLinearGradient(
  double degrees,
  Size size,
  List<Color> colors, {
  List<double>? stops,
}) {
  final radians = degrees * math.pi / 180;
  final dx = math.sin(radians);
  final dy = -math.cos(radians);
  final half = (size.width * dx.abs() + size.height * dy.abs()) / 2;
  final end = Alignment(
    dx * half / (size.width / 2),
    dy * half / (size.height / 2),
  );
  return LinearGradient(begin: -end, end: end, colors: colors, stops: stops);
}

/// [TextStyle] with the design's line height and no tracking.
TextStyle scoutText(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.ink,
  double height = scoutLeading,
}) => TextStyle(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: 0,
);

/// Draws an SVG at its own size, centred in a [box]-sized square. Some
/// icons are a fraction of a pixel larger than their slot, as in Figma.
class ScoutSvg extends StatelessWidget {
  const ScoutSvg(this.asset, {super.key, required this.box});

  final String asset;
  final double box;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: box,
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: SvgPicture.asset(asset),
      ),
    );
  }
}

// --- Display formatting ----------------------------------------------------

/// "₦2.5M" for big amounts, "$1,200" below 100,000.
String formatScoutMoney(Money money) => money.major >= 100000
    ? '${currencySymbol(money.currency.code)}${formatCompact(money.major)}'
    : money.format();

/// "₦2.5M – ₦4M"; with [withUnit], "₦180K / day".
String formatBudget(BudgetRange budget, {bool withUnit = false}) {
  final max = budget.max;
  final amount = max == null
      ? formatScoutMoney(budget.min)
      : '${formatScoutMoney(budget.min)} – ${formatScoutMoney(max)}';
  if (!withUnit) return amount;
  return switch (budget.unit) {
    BudgetUnit.flat => amount,
    BudgetUnit.perShow => '$amount / show',
    BudgetUnit.perDay => '$amount / day',
    BudgetUnit.perEpisode => '$amount / episode',
  };
}

String budgetUnitLabel(BudgetUnit unit) => switch (unit) {
  BudgetUnit.flat => 'Flat fee',
  BudgetUnit.perShow => 'Paid per show',
  BudgetUnit.perDay => 'Paid per day',
  BudgetUnit.perEpisode => 'Paid per episode',
};

/// "Nov 14 – 16", "Nov 30 – Dec 2", or months for long runs: "Jun – Aug 2027".
String formatDateRange(DateTime start, DateTime? end) {
  final day = DateFormat('MMM d');
  if (end == null) return day.format(start);
  if (start.year == end.year && start.month == end.month) {
    return start.day == end.day
        ? day.format(start)
        : '${day.format(start)} – ${end.day}';
  }
  if (end.difference(start).inDays > 31) {
    final month = DateFormat('MMM');
    return start.year == end.year
        ? '${month.format(start)} – ${month.format(end)} ${end.year}'
        : '${DateFormat('MMM y').format(start)} – '
              '${DateFormat('MMM y').format(end)}';
  }
  return '${day.format(start)} – ${day.format(end)}';
}

/// Whole days until [time], rounded up: "6 days", "1 day", "today".
String formatDaysLeft(DateTime time, {DateTime? now}) {
  final hours = time.difference(now ?? DateTime.now()).inHours;
  final days = (hours / 24).ceil();
  if (days <= 0) return 'today';
  return days == 1 ? '1 day' : '$days days';
}

/// "Closes Nov 20".
String formatCloses(DateTime closesAt) =>
    'Closes ${DateFormat('MMM d').format(closesAt)}';

/// "Lagos", "Remote / Nairobi", "Lagos + 6 cities".
String callLocation(OpenCallSummary call) {
  final cities = call.cities;
  if (cities.isEmpty) return call.isRemote ? 'Remote' : '';
  if (cities.length > 1) {
    final more = cities.length - 1;
    return '${cities.first} + $more ${more == 1 ? 'city' : 'cities'}';
  }
  return call.isRemote ? 'Remote / ${cities.first}' : cities.first;
}

String applicationStatusLabel(ApplicationStatus status) => switch (status) {
  ApplicationStatus.sent => 'Sent',
  ApplicationStatus.inReview => 'In review',
  ApplicationStatus.shortlisted => 'Shortlisted',
  ApplicationStatus.offer => 'Offer',
  ApplicationStatus.declined => 'Declined',
  ApplicationStatus.withdrawn => 'Withdrawn',
  ApplicationStatus.expired => 'Expired',
  ApplicationStatus.completed => 'Completed',
};

/// The applied button's label: a fresh application reads as in review.
String appliedLabel(ApplicationStatus status) => switch (status) {
  ApplicationStatus.sent || ApplicationStatus.inReview => 'Applied · In review',
  final other => 'Applied · ${applicationStatusLabel(other)}',
};
