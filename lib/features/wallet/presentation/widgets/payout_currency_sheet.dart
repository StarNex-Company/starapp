import 'package:flutter/material.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_form.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';

/// The currencies payouts can be made in, as the sheet lists them.
const payoutCurrencies = {
  Currency.ngn: 'Nigerian Naira (₦ NGN)',
  Currency.usd: r'US Dollar ($ USD)',
  Currency.ghs: 'Ghanaian Cedi (₵ GHS)',
};

/// Sheet — Payout Currency. Pops with the chosen currency.
Future<Currency?> showPayoutCurrencySheet(
  BuildContext context, {
  required Currency selected,
}) {
  return showStarSheet<Currency>(
    context: context,
    builder: (context) => StarSheet(
      title: 'Payout currency',
      children: [
        for (final MapEntry(key: currency, value: label)
            in payoutCurrencies.entries)
          WalletSheetOption(
            label: label,
            selected: currency == selected,
            onTap: () => Navigator.of(context).pop(currency),
          ),
      ],
    ),
  );
}
