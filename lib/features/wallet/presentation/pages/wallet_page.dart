import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/balance_card.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_cards.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// Wallet — Earnings & Payouts, inside the Profile tab: balance, earnings
/// by source, the default payout account and recent activity.
class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(walletSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Wallet',
        leading: StarIconButton.back(onPressed: () => _back(context)),
      ),
      body: StarAsyncView(
        value: summary,
        onRetry: () => ref.invalidate(walletSummaryProvider),
        builder: (summary) => _WalletBody(summary: summary),
      ),
    );
  }
}

class _WalletBody extends StatelessWidget {
  const _WalletBody({required this.summary});

  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    final method = summary.defaultPayoutMethod;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          BalanceCard(
            summary: summary,
            onWithdraw: summary.available.amountMinor > 0
                ? () => context.push(AppRoutes.walletWithdraw)
                : null,
            onStatements: () => context.push(AppRoutes.walletStatements),
          ),
          EarningsRow(summary: summary),
          if (method == null)
            PayoutAccountCard(
              method: null,
              subtitle: 'Bank account',
              actionLabel: 'Add',
              onTap: () => context.push(AppRoutes.payoutMethodNew),
            )
          else
            PayoutAccountCard(
              method: method,
              subtitle: 'Default payout account',
              actionLabel: 'Change',
              onTap: () => context.push(AppRoutes.payouts),
            ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent activity',
                  style: TextStyle(
                    fontSize: 16,
                    height: walletLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
              if (summary.recent.isNotEmpty)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.push(AppRoutes.walletActivity),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        height: walletLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          RecentActivityCard(
            transactions: summary.recent,
            onOpen: (t) => context.push(AppRoutes.walletTransaction(t.id)),
          ),
        ],
      ),
    );
  }
}
