import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';

/// Inter's "normal" line height, so text boxes match the design.
const walletLeading = 1.21;

abstract final class WalletIcons {
  static const _dir = 'assets/vectors/wallet';

  static const balanceGlow = '$_dir/balance_glow.svg';
  static const balanceLogo = '$_dir/balance_logo.svg';
  static const arrowUpRightInk = '$_dir/ic_arrow_up_right_ink.svg';
  static const arrowUpRightWhite = '$_dir/ic_arrow_up_right_white.svg';
  static const arrowUpRightRed = '$_dir/ic_arrow_up_right_red.svg';
  static const arrowUpRightNavy = '$_dir/ic_arrow_up_right_navy.svg';
  static const arrowDownLeftGreen = '$_dir/ic_arrow_down_left_green.svg';
  static const fileWhite = '$_dir/ic_file_white.svg';
  static const fileNavy = '$_dir/ic_file_navy.svg';
  static const trophyGold = '$_dir/ic_trophy_gold.svg';
  static const heartPink = '$_dir/ic_heart_pink.svg';
  static const heartNavy = '$_dir/ic_heart_navy.svg';
  static const briefcaseSmall = '$_dir/ic_briefcase_small.svg';
  static const bank = '$_dir/ic_bank.svg';
  static const backspace = '$_dir/ic_backspace.svg';
  static const wallet = '$_dir/ic_wallet.svg';
  static const check = '$_dir/ic_check.svg';
  static const plus = '$_dir/ic_plus.svg';
  static const globe = '$_dir/ic_globe.svg';
  static const sentArrow = '$_dir/sent_arrow.svg';

  // Identical art already bundled elsewhere in the app.
  static const trophyNavy = 'assets/vectors/challenges/rules_ic_trophy.svg';
  static const briefcaseNavy =
      'assets/vectors/settings/privacy_ic_briefcase.svg';
  static const calendar = 'assets/vectors/challenges/rules_ic_calendar.svg';
  static const clock = 'assets/vectors/moderation/appeal_ic_clock.svg';
  static const zap = 'assets/vectors/challenges/upcoming_ic_zap.svg';
  static const fileSmall =
      'assets/vectors/moderation/appeal_submitted_file.svg';
  static const chevron = 'assets/vectors/shared/share_chevron.svg';
  static const chevronMuted =
      'assets/vectors/create/sheet_ic_chevron_muted.svg';
}

/// Wallet colours that have no [AppColors] token.
abstract final class WalletColors {
  static const balanceLabel = Color(0xFFAFC0F5);
  static const credit = Color(0xFF15803D);
  static const processing = Color(0xFFB45309);
  static const goldTint = Color(0xFFFFF3CC);
  static const pinkTint = Color(0xFFFDE7F3);
  static const sentDiscStart = Color(0xFF16A34A);
  static const sentGlow = Color(0xFF22C55E);
}

/// The exact amount, with kobo / cents only when there are any:
/// "₦900,000", "₦12,500.50".
String formatAmount(Money money) =>
    money.format(decimals: money.amountMinor.abs() % 100 != 0);

/// Totals at a glance: "₦950K", "₦168.5K", "₦5M". Rounded down to one
/// decimal, so a total is never overstated.
String formatCompactAmount(Money money) {
  final major = money.amountMinor.abs() ~/ 100;
  final (divisor, suffix) = switch (major) {
    >= 1000000000 => (1000000000, 'B'),
    >= 1000000 => (1000000, 'M'),
    >= 1000 => (1000, 'K'),
    _ => (1, ''),
  };
  final tenths = major * 10 ~/ divisor;
  final value = tenths % 10 == 0
      ? formatGrouped(tenths ~/ 10)
      : '${formatGrouped(tenths ~/ 10)}.${tenths % 10}';
  final sign = money.amountMinor < 0 ? '-' : '';
  return '$sign${currencySymbol(money.currency.code)}$value$suffix';
}

/// "+₦900,000" for money in, "−₦150,000" for money out.
String formatSignedAmount(WalletTransaction t) =>
    '${t.isCredit ? '+' : '−'}${formatAmount(t.amount)}';

/// "Oct 2", or "Oct 2, 2025" outside the current year.
String formatShortDate(DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();
  return time.year == current.year
      ? DateFormat('MMM d').format(time)
      : DateFormat('MMM d, y').format(time);
}

String transactionTypeLabel(TransactionType type) => switch (type) {
  TransactionType.challengePrize => 'Challenge prize',
  TransactionType.fanTips => 'Fan tips',
  TransactionType.scoutDeal => 'Scout deal',
  TransactionType.withdrawal => 'Withdrawal',
  TransactionType.adjustment => 'Adjustment',
};

/// A withdrawal the bank hasn't confirmed reads "Processing" whether the
/// server says pending or processing.
String transactionStatusLabel(WalletTransaction t) => switch (t.status) {
  TransactionStatus.pending when t.type == TransactionType.withdrawal =>
    'Processing',
  TransactionStatus.pending => 'Pending',
  TransactionStatus.processing => 'Processing',
  TransactionStatus.paid => 'Paid',
  TransactionStatus.completed => 'Completed',
  TransactionStatus.failed => 'Failed',
  TransactionStatus.reversed => 'Reversed',
};

Color transactionStatusColor(WalletTransaction t) => switch (t.status) {
  TransactionStatus.pending ||
  TransactionStatus.processing => WalletColors.processing,
  TransactionStatus.failed || TransactionStatus.reversed => AppColors.danger,
  _ => AppColors.textSubtle,
};

/// The navy icon for a transaction's tile.
String transactionIcon(TransactionType type) => switch (type) {
  TransactionType.challengePrize => WalletIcons.trophyNavy,
  TransactionType.fanTips => WalletIcons.heartNavy,
  TransactionType.scoutDeal => WalletIcons.briefcaseNavy,
  TransactionType.withdrawal => WalletIcons.arrowUpRightNavy,
  TransactionType.adjustment => WalletIcons.wallet,
};
