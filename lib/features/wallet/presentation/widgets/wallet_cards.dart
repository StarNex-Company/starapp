import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';

const _cardBorder = Border.fromBorderSide(
  BorderSide(color: AppColors.borderField),
);

/// Lifetime earnings by source: Prizes, Fan tips, Scout deals.
class EarningsRow extends StatelessWidget {
  const EarningsRow({super.key, required this.summary});

  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Expanded(
            child: _EarningTile(
              icon: WalletIcons.trophyGold,
              tint: WalletColors.goldTint,
              total: summary.prizesTotal,
              label: 'Prizes',
            ),
          ),
          Expanded(
            child: _EarningTile(
              icon: WalletIcons.heartPink,
              tint: WalletColors.pinkTint,
              total: summary.fanTipsTotal,
              label: 'Fan tips',
            ),
          ),
          Expanded(
            child: _EarningTile(
              icon: WalletIcons.briefcaseSmall,
              tint: AppColors.brandTint,
              total: summary.scoutDealsTotal,
              label: 'Scout deals',
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningTile extends StatelessWidget {
  const _EarningTile({
    required this.icon,
    required this.tint,
    required this.total,
    required this.label,
  });

  final String icon;
  final Color tint;
  final Money total;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        border: _cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: SvgPicture.asset(icon),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCompactAmount(total),
              style: const TextStyle(
                fontSize: 16,
                height: walletLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: walletLeading,
              letterSpacing: 0,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

/// White bordered card for a payout account: the default account on the
/// Wallet ("Change"), the destination on Withdraw (chevron), or "Add payout
/// method" when there is none.
class PayoutAccountCard extends StatelessWidget {
  const PayoutAccountCard({
    super.key,
    required this.method,
    required this.subtitle,
    required this.onTap,
    this.actionLabel,
  });

  /// Null shows the "Add payout method" prompt.
  final PayoutMethod? method;
  final String subtitle;
  final VoidCallback onTap;

  /// Brand text at the end ("Change", "Add"); a grey chevron when null.
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final method = this.method;
    return Material(
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: AppColors.borderField),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  method == null ? WalletIcons.plus : WalletIcons.bank,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      method?.label ?? 'Add payout method',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: walletLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: walletLeading,
                        letterSpacing: 0,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionLabel != null)
                Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: walletLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                )
              else
                SvgPicture.asset(WalletIcons.chevronMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Wallet's recent activity: rows in a white card with hairlines.
class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.transactions,
    required this.onOpen,
  });

  final List<WalletTransaction> transactions;
  final ValueChanged<WalletTransaction> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: _cardBorder,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0B1020),
            offset: Offset(0, 4),
            blurRadius: 9,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Prizes, tips and Scout payments will show up here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    letterSpacing: 0,
                    color: AppColors.textSubtle,
                  ),
                ),
              ),
            for (var i = 0; i < transactions.length; i++) ...[
              if (i > 0)
                const ColoredBox(
                  color: AppColors.borderField,
                  child: SizedBox(height: 1),
                ),
              _RecentRow(
                transaction: transactions[i],
                onTap: () => onOpen(transactions[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.transaction, required this.onTap});

  final WalletTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final date = formatShortDate(t.createdAt);
    final subtitle = t.subtitle.isEmpty ? date : '${t.subtitle} · $date';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.isCredit
                    ? AppColors.successTint
                    : AppColors.dangerTint,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                t.isCredit
                    ? WalletIcons.arrowDownLeftGreen
                    : WalletIcons.arrowUpRightRed,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: walletLeading,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: walletLeading,
                      letterSpacing: 0,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 3,
              children: [
                Text(
                  formatSignedAmount(t),
                  style: TextStyle(
                    fontSize: 14,
                    height: walletLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    color: t.isCredit ? WalletColors.credit : AppColors.ink,
                  ),
                ),
                Text(
                  transactionStatusLabel(t),
                  style: TextStyle(
                    fontSize: 11,
                    height: walletLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    color: transactionStatusColor(t),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
