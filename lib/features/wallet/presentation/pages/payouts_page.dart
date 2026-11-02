import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/payout_settings.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/payout_currency_sheet.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_form.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_tile_row.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Settings — Payments & Payouts, inside the Profile tab (and full screen
/// from Withdraw via its mirror). Tapping a payout method makes it the
/// default; the currency and auto-payout switch apply at once and roll back
/// if the server rejects them.
class PayoutsPage extends ConsumerWidget {
  const PayoutsPage({super.key});

  /// Runs a change that has already rolled back if it failed.
  static Future<void> _apply(
    BuildContext context,
    Future<void> Function() change,
  ) async {
    try {
      await change();
    } catch (e) {
      if (context.mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(payoutMethodsProvider);
    final settings = ref.watch(payoutSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Payments & payouts',
        leading: StarIconButton.back(onPressed: () => context.pop()),
      ),
      body: StarAsyncView(
        value: methods,
        onRetry: () => ref.invalidate(payoutMethodsProvider),
        builder: (methods) => StarAsyncView(
          value: settings,
          onRetry: () => ref.invalidate(payoutSettingsProvider),
          builder: (settings) =>
              _PayoutsBody(methods: methods, settings: settings),
        ),
      ),
    );
  }
}

class _PayoutsBody extends ConsumerWidget {
  const _PayoutsBody({required this.methods, required this.settings});

  final List<PayoutMethod> methods;
  final PayoutSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    final available = ref.watch(walletSummaryProvider).value?.available;
    final settingsNotifier = ref.read(payoutSettingsProvider.notifier);
    final threshold = settings.taxThreshold;
    final currency = settings.payoutCurrency;

    Future<void> pickCurrency() async {
      final picked = await showPayoutCurrencySheet(context, selected: currency);
      if (picked == null || picked == currency || !context.mounted) return;
      await PayoutsPage._apply(
        context,
        () => settingsNotifier.setPayoutCurrency(picked),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
      children: _spaced([
        const WalletSectionTitle('Payout methods'),
        for (final method in methods) ...[
          WalletTileRow(
            icon: WalletIcons.bank,
            title: method.label,
            subtitle: method.isDefault
                ? '${method.accountName} · Default'
                : method.accountName,
            value: method.isDefault ? 'Default' : null,
            onTap: method.isDefault
                ? null
                : () => PayoutsPage._apply(
                    context,
                    () => ref
                        .read(payoutMethodsProvider.notifier)
                        .setDefault(method.id),
                  ),
          ),
          const WalletDivider(),
        ],
        WalletTileRow(
          icon: WalletIcons.plus,
          title: 'Add payout method',
          subtitle: 'Bank account',
          onTap: () => context.pushInTab(AppRoutes.payoutMethodNew),
        ),
        const WalletSectionTitle('Preferences'),
        WalletTileRow(
          icon: WalletIcons.globe,
          title: 'Payout currency',
          value: '${currency.code} ${currencySymbol(currency.code).trim()}',
          onTap: pickCurrency,
        ),
        const WalletDivider(),
        WalletTileRow(
          icon: WalletIcons.clock,
          title: 'Automatic monthly payout',
          subtitle: 'Paid on the 1st of each month',
          onTap: () => PayoutsPage._apply(
            context,
            () => settingsNotifier.setAutoMonthlyPayout(
              !settings.autoMonthlyPayout,
            ),
          ),
          trailing: WalletToggle(
            value: settings.autoMonthlyPayout,
            semanticLabel: 'Automatic monthly payout',
            onChanged: (on) => PayoutsPage._apply(
              context,
              () => settingsNotifier.setAutoMonthlyPayout(on),
            ),
          ),
        ),
        const WalletDivider(),
        WalletTileRow(
          icon: WalletIcons.fileNavy,
          title: 'Tax information',
          subtitle:
              'Needed for payouts over ${formatCompactAmount(threshold)} a year',
          value: settings.taxInfo != null ? 'Added' : null,
          onTap: () => context.pushInTab(AppRoutes.payoutTax),
        ),
        const WalletSectionTitle('Activity'),
        WalletTileRow(
          icon: WalletIcons.zap,
          title: 'Wallet & earnings',
          subtitle: available == null
              ? null
              : '${formatAmount(available)} available',
          onTap: () => context.go(AppRoutes.wallet),
        ),
      ]),
    );
  }

  /// The design's 12px between rows, headings and dividers.
  static List<Widget> _spaced(List<Widget> children) => [
    for (var i = 0; i < children.length; i++) ...[
      if (i > 0) const SizedBox(height: 12),
      children[i],
    ],
  ];
}
