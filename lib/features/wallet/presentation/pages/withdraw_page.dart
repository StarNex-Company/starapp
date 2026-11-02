import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/data/models/withdrawal.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/amount_input.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_cards.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_form.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// Wallet — Withdraw, full screen: the amount keypad with quick-amount
/// chips, the destination account, and the quoted fee and payout.
///
/// The quote is fetched once the amount has been still for a moment. The
/// confirm button only enables for an amount the server has just quoted
/// and accepted. There is no PIN or OTP step, as designed.
class WithdrawPage extends ConsumerStatefulWidget {
  const WithdrawPage({super.key});

  /// How long the amount must be still before it is quoted.
  static const quoteDelay = Duration(milliseconds: 350);

  @override
  ConsumerState<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends ConsumerState<WithdrawPage> {
  AmountInput _input = const AmountInput();

  /// The amount the quote is for: [_input] once it has settled.
  Money? _quotedAmount;
  Timer? _debounce;
  bool _submitting = false;

  /// One key per withdrawal: kept while the amount and destination stay the
  /// same, so retrying after a failure can't pay out twice.
  String? _idempotencyKey;
  String? _keyFor;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _setInput(AmountInput input, Currency currency) {
    if (_submitting || input == _input) return;
    setState(() => _input = input);
    _debounce?.cancel();
    _debounce = Timer(WithdrawPage.quoteDelay, () {
      if (mounted) setState(() => _quotedAmount = input.toMoney(currency));
    });
  }

  void _openDestination(PayoutMethod? method) {
    // This page is on the root navigator, so tab routes go via their mirror.
    context.pushInTab(
      method == null ? AppRoutes.payoutMethodNew : AppRoutes.payouts,
    );
  }

  Future<void> _submit({
    required Money amount,
    required PayoutMethod destination,
    required WithdrawalQuote quote,
  }) async {
    final attempt =
        '${amount.amountMinor}:${amount.currency.code}:'
        '${destination.id}';
    if (_keyFor != attempt) {
      _idempotencyKey = newIdempotencyKey();
      _keyFor = attempt;
    }
    setState(() => _submitting = true);
    try {
      final withdrawal = await ref
          .read(withdrawalProvider.notifier)
          .withdraw(
            amount: amount,
            destination: destination,
            idempotencyKey: _idempotencyKey!,
            arrivalEstimate: quote.arrivalEstimate,
          );
      if (!mounted) return;
      final reference = Uri.encodeQueryComponent(withdrawal.reference);
      context.pushReplacement('${AppRoutes.walletWithdrawSent}?ref=$reference');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(walletSummaryProvider);

    return PopScope(
      // Stay put until the server answers, so a sent withdrawal always
      // reaches its confirmation.
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: StarScreenHeader(
          title: 'Withdraw',
          leading: StarIconButton.back(
            onPressed: _submitting ? null : () => context.pop(),
          ),
        ),
        body: StarAsyncView(
          value: summary,
          onRetry: () => ref.invalidate(walletSummaryProvider),
          builder: (summary) => _buildForm(summary),
        ),
      ),
    );
  }

  Widget _buildForm(WalletSummary summary) {
    final available = summary.available;
    final currency = available.currency;
    final method = summary.defaultPayoutMethod;
    final amount = _input.toMoney(currency);

    final quoted = _quotedAmount;
    final canQuote =
        method != null &&
        quoted != null &&
        quoted.amountMinor > 0 &&
        quoted.currency == currency &&
        quoted <= available;
    final quote = canQuote
        ? ref.watch(
            withdrawalQuoteProvider((
              amount: quoted,
              payoutMethodId: method.id,
            )),
          )
        : null;

    // Only a quote for exactly what's on screen counts.
    final settled = quoted == amount;
    final fresh = settled && quote != null && quote.hasValue
        ? quote.requireValue
        : null;
    final error = amount.isZero
        ? null
        : _amountError(amount, available, fresh, settled ? quote : null);
    final canSubmit =
        method != null && fresh != null && error == null && !_submitting;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                const Text(
                  'AMOUNT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: walletLeading,
                    letterSpacing: 0.72,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSubtle,
                  ),
                ),
                _AmountHeader(
                  amount: _input.display(currency),
                  available: available,
                  error: error,
                ),
                _QuickAmounts(
                  available: available,
                  current: amount,
                  onPick: (m) => _setInput(AmountInput.fromMoney(m), currency),
                ),
                PayoutAccountCard(
                  method: method,
                  subtitle: method?.accountName ?? 'Add a bank account first',
                  onTap: () => _openDestination(method),
                ),
                _QuoteSummary(quote: fresh, loading: _isLoading(amount, quote)),
                _Keypad(
                  onKey: (key) => _setInput(_input.press(key), currency),
                  onBackspace: () => _setInput(_input.backspace(), currency),
                ),
              ],
            ),
          ),
        ),
        StarBottomBar(
          child: StarPrimaryButton(
            label: _submitting
                ? 'Withdrawing…'
                : amount.isZero
                ? 'Withdraw'
                : 'Withdraw ${formatAmount(amount)}',
            leadingIcon: WalletIcons.arrowUpRightWhite,
            onPressed: canSubmit
                ? () =>
                      _submit(amount: amount, destination: method, quote: fresh)
                : null,
          ),
        ),
      ],
    );
  }

  bool _isLoading(Money amount, AsyncValue<WithdrawalQuote>? quote) =>
      !amount.isZero &&
      (_quotedAmount != amount || (quote != null && quote.isLoading));

  /// The inline message under the amount, or null when it can be sent.
  String? _amountError(
    Money amount,
    Money available,
    WithdrawalQuote? quote,
    AsyncValue<WithdrawalQuote>? result,
  ) {
    if (amount > available) return "That's more than your available balance.";
    if (quote != null) {
      if (amount < quote.min) {
        return 'The minimum withdrawal is ${formatAmount(quote.min)}.';
      }
      if (amount > quote.max) {
        return 'You can withdraw up to ${formatAmount(quote.max)} right now.';
      }
      return null;
    }
    final failure = result?.error;
    if (failure == null) return null;
    if (failure is ValidationException) {
      return failure.fieldErrors['amount'] ?? failure.message;
    }
    return describeError(failure);
  }
}

extension on Money {
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
}

class _AmountHeader extends StatelessWidget {
  const _AmountHeader({
    required this.amount,
    required this.available,
    required this.error,
  });

  final String amount;
  final Money available;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Semantics(
          liveRegion: true,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 44,
                height: walletLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
        Column(
          spacing: 6,
          children: [
            Text(
              'Available · ${available.format(decimals: true)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: walletLeading,
                letterSpacing: 0,
                color: AppColors.textSubtle,
              ),
            ),
            if (error != null)
              WalletFieldError(error!, textAlign: TextAlign.center),
          ],
        ),
      ],
    );
  }
}

/// 25% / 40% / 75% / Max of the available balance, rounded down to the
/// minor unit so a chip never exceeds it.
class _QuickAmounts extends StatelessWidget {
  const _QuickAmounts({
    required this.available,
    required this.current,
    required this.onPick,
  });

  final Money available;
  final Money current;
  final ValueChanged<Money> onPick;

  static const _percents = [25, 40, 75, 100];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final percent in _percents)
          Builder(
            builder: (context) {
              final value = Money(
                available.amountMinor * percent ~/ 100,
                available.currency,
              );
              return _Chip(
                label: percent == 100 ? 'Max' : '$percent%',
                selected: !current.isZero && value == current,
                onTap: available.isZero ? null : () => onPick(value),
              );
            },
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      StarPill(label: label, selected: selected, onTap: onTap);
}

class _QuoteSummary extends StatelessWidget {
  const _QuoteSummary({required this.quote, required this.loading});

  /// Null until the current amount is quoted.
  final WithdrawalQuote? quote;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final quote = this.quote;
    const pending = '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.borderField)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0B1020),
            offset: Offset(0, 4),
            blurRadius: 9,
          ),
        ],
      ),
      child: Column(
        spacing: 10,
        children: [
          _QuoteRow(
            label: 'Fee',
            value: quote == null ? pending : formatAmount(quote.fee),
          ),
          _QuoteRow(label: 'Arrives', value: quote?.arrivalEstimate ?? pending),
          _QuoteRow(
            label: "You'll receive",
            value: quote == null ? pending : formatAmount(quote.receive),
            emphasis: true,
            trailing: loading ? const WalletFieldSpinner() : null,
          ),
        ],
      ),
    );
  }
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({
    required this.label,
    required this.value,
    this.emphasis = false,
    this.trailing,
  });

  final String label;
  final String value;
  final bool emphasis;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              height: walletLeading,
              letterSpacing: 0,
              color: AppColors.textSubtle,
            ),
          ),
        ),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ?trailing,
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    height: walletLeading,
                    letterSpacing: 0,
                    fontWeight: emphasis ? FontWeight.w700 : FontWeight.w600,
                    color: emphasis ? AppColors.brandBlue : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey, required this.onBackspace});

  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        for (final row in _rows)
          Row(
            spacing: 8,
            children: [
              for (final key in row)
                Expanded(
                  child: key == '⌫'
                      ? _Key(
                          key: const ValueKey('keypad-⌫'),
                          semanticLabel: 'Delete',
                          onTap: onBackspace,
                          child: SvgPicture.asset(WalletIcons.backspace),
                        )
                      : _Key(
                          key: ValueKey('keypad-$key'),
                          semanticLabel: key == '.' ? 'Decimal point' : key,
                          onTap: () => onKey(key),
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 22,
                              height: walletLeading,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    super.key,
    required this.child,
    required this.onTap,
    required this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: AppColors.closeButtonBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(height: 52, child: Center(child: child)),
        ),
      ),
    );
  }
}
