import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_tile_row.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// Wallet — Transaction Detail, inside the Profile tab. One layout for every
/// type: the signed amount, then what it was for (challenge and prize
/// conversion, fans, Scout company, or destination account), date,
/// reference and status.
class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(transactionProvider(transactionId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Transaction',
        leading: StarIconButton.back(onPressed: () => context.pop()),
      ),
      body: StarAsyncView(
        value: transaction,
        onRetry: () => ref.invalidate(transactionProvider(transactionId)),
        builder: (t) => _TransactionDetail(transaction: t),
      ),
    );
  }
}

class _TransactionDetail extends ConsumerWidget {
  const _TransactionDetail({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = transaction;
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    final status = transactionStatusLabel(t);
    final rows = [
      ..._typeRows(t, ref),
      WalletTileRow(
        icon: WalletIcons.calendar,
        title: 'Date',
        value: DateFormat('MMM d, y · HH:mm').format(t.createdAt),
        chevron: false,
      ),
      WalletTileRow(
        icon: WalletIcons.fileNavy,
        title: 'Reference',
        value: t.reference,
        chevron: false,
      ),
      WalletTileRow(
        icon: WalletIcons.check,
        title: 'Status',
        value: status,
        chevron: false,
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatSignedAmount(t),
              style: TextStyle(
                fontSize: 36,
                height: 44 / 36,
                letterSpacing: 0,
                fontWeight: FontWeight.w800,
                color: t.isCredit ? WalletColors.credit : AppColors.ink,
              ),
            ),
          ),
          Text(
            '${transactionTypeLabel(t.type)} · ${status.toLowerCase()}',
            style: const TextStyle(
              fontSize: 14,
              height: 22 / 14,
              letterSpacing: 0,
              color: AppColors.authTextSecondary,
            ),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const WalletDivider(),
            rows[i],
          ],
        ],
      ),
    );
  }

  /// What the money was for, by type.
  List<Widget> _typeRows(WalletTransaction t, WidgetRef ref) {
    switch (t.type) {
      case TransactionType.challengePrize:
        final rank = t.rank;
        final original = t.originalAmount;
        final rate = t.fxRate;
        return [
          WalletTileRow(
            icon: WalletIcons.trophyNavy,
            title: 'Challenge',
            subtitle: t.challengeName,
            value: rank == null
                ? null
                : rank <= 10
                ? 'Top 10 · #$rank'
                : '#$rank',
            chevron: false,
          ),
          WalletTileRow(
            icon: WalletIcons.wallet,
            title: 'Prize',
            subtitle: original == null || rate == null
                ? null
                : '${formatAmount(original)} converted at '
                      '${currencySymbol(t.amount.currency.code)}'
                      '${formatGrouped(rate)}',
            value: formatAmount(t.amount),
            chevron: false,
          ),
        ];
      case TransactionType.fanTips:
        final fans = t.fanCount;
        return [
          WalletTileRow(
            icon: WalletIcons.heartNavy,
            title: 'Fan tips',
            subtitle: fans == null
                ? null
                : '${formatGrouped(fans)} ${fans == 1 ? 'fan' : 'fans'}',
            value: formatAmount(t.amount),
            chevron: false,
          ),
        ];
      case TransactionType.scoutDeal:
        return [
          WalletTileRow(
            icon: WalletIcons.briefcaseNavy,
            title: 'Scout deal',
            subtitle: t.companyName,
            value: formatAmount(t.amount),
            chevron: false,
          ),
        ];
      case TransactionType.withdrawal:
        final methods = ref.watch(payoutMethodsProvider).value ?? const [];
        PayoutMethod? destination;
        for (final m in methods) {
          if (m.id == t.payoutMethodId) destination = m;
        }
        return [
          WalletTileRow(
            icon: WalletIcons.bank,
            title: destination?.label ?? t.title,
            subtitle: destination?.accountName,
            value: formatAmount(t.amount),
            chevron: false,
          ),
        ];
      case TransactionType.adjustment:
        return [
          WalletTileRow(
            icon: WalletIcons.wallet,
            title: t.title,
            subtitle: t.subtitle,
            value: formatAmount(t.amount),
            chevron: false,
          ),
        ];
    }
  }
}
