import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/payout_settings.dart';
import 'package:starapp/features/wallet/data/models/statement.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';
import 'package:starapp/features/wallet/data/models/withdrawal.dart';
import 'package:starapp/features/wallet/data/repositories/api_wallet_repository.dart';
import 'package:starapp/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:starapp/features/wallet/data/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockWalletRepository.new,
    api: ApiWalletRepository.new,
  ),
);

/// Lookups that answer a form as the user types: a failure is the answer
/// (account not found, amount too low), so it isn't retried.
Duration? _noRetry(int retryCount, Object error) => null;

/// Balance, totals, default payout method and recent activity.
final walletSummaryProvider = FutureProvider<WalletSummary>(
  (ref) => ref.watch(walletRepositoryProvider).getWalletSummary(),
);

/// Every transaction, newest first. [WalletActivityNotifier.loadMore]
/// appends the next page.
final walletActivityProvider =
    AsyncNotifierProvider<WalletActivityNotifier, List<WalletTransaction>>(
      WalletActivityNotifier.new,
    );

class WalletActivityNotifier extends AsyncNotifier<List<WalletTransaction>> {
  String? _nextCursor;
  bool _loadingMore = false;

  @override
  Future<List<WalletTransaction>> build() async {
    final page = await ref.watch(walletRepositoryProvider).listTransactions();
    _nextCursor = page.nextCursor;
    return page.items;
  }

  bool get hasMore => _nextCursor != null;

  /// Appends the next page; a no-op on the last page or while loading.
  Future<void> loadMore() async {
    final items = state.value;
    final cursor = _nextCursor;
    if (items == null || cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await ref
          .read(walletRepositoryProvider)
          .listTransactions(cursor: cursor);
      _nextCursor = page.nextCursor;
      state = AsyncData([...items, ...page.items]);
    } finally {
      _loadingMore = false;
    }
  }
}

final transactionProvider = FutureProvider.family<WalletTransaction, String>(
  (ref, id) => ref.watch(walletRepositoryProvider).getTransaction(id),
);

final statementsProvider = FutureProvider<List<Statement>>(
  (ref) => ref.watch(walletRepositoryProvider).listStatements(),
);

/// Re-reads everything that shows the balance or history, e.g. after a
/// withdrawal.
void invalidateWalletData(WidgetRef ref) => ref
  ..invalidate(walletSummaryProvider)
  ..invalidate(walletActivityProvider)
  ..invalidate(transactionProvider);

/// The withdrawal fee, arrival and limits for an amount and destination.
/// The Withdraw screen debounces the amount before it changes the key.
final withdrawalQuoteProvider = FutureProvider.autoDispose
    .family<WithdrawalQuote, ({Money amount, String payoutMethodId})>(
      (ref, key) => ref
          .watch(walletRepositoryProvider)
          .quoteWithdrawal(
            amount: key.amount,
            payoutMethodId: key.payoutMethodId,
          ),
      retry: _noRetry,
    );

/// A withdrawal the server accepted, with the arrival estimate that was
/// quoted for it, for the confirmation screen.
typedef WithdrawalReceipt = ({Withdrawal withdrawal, String arrivalEstimate});

/// The last withdrawal made this session; null until one succeeds.
final withdrawalProvider =
    NotifierProvider<WithdrawalNotifier, WithdrawalReceipt?>(
      WithdrawalNotifier.new,
    );

class WithdrawalNotifier extends Notifier<WithdrawalReceipt?> {
  @override
  WithdrawalReceipt? build() => null;

  /// Sends the money. Not optimistic: the balance only changes once the
  /// server has accepted it. Reuse [idempotencyKey] when retrying the same
  /// withdrawal after a failure whose outcome is unknown.
  Future<Withdrawal> withdraw({
    required Money amount,
    required PayoutMethod destination,
    required String idempotencyKey,
    required String arrivalEstimate,
  }) async {
    final withdrawal = await ref
        .read(walletRepositoryProvider)
        .withdraw(
          amount: amount,
          payoutMethodId: destination.id,
          idempotencyKey: idempotencyKey,
        );
    state = (withdrawal: withdrawal, arrivalEstimate: arrivalEstimate);
    return withdrawal;
  }
}

/// The user's payout methods, the default first in the API's order.
/// [PayoutMethodsNotifier.setDefault] switches at once and rolls back if the
/// server rejects it.
final payoutMethodsProvider =
    AsyncNotifierProvider<PayoutMethodsNotifier, List<PayoutMethod>>(
      PayoutMethodsNotifier.new,
    );

class PayoutMethodsNotifier extends AsyncNotifier<List<PayoutMethod>> {
  WalletRepository get _repository => ref.read(walletRepositoryProvider);

  @override
  Future<List<PayoutMethod>> build() =>
      ref.watch(walletRepositoryProvider).listPayoutMethods();

  Future<void> setDefault(String id) async {
    final methods = state.value;
    if (methods == null) return;
    if (methods.any((m) => m.id == id && m.isDefault)) return;
    state = AsyncData([
      for (final m in methods) m.copyWith(isDefault: m.id == id),
    ]);
    try {
      await _repository.setDefaultPayoutMethod(id);
    } catch (_) {
      state = AsyncData(methods);
      rethrow;
    }
    ref.invalidate(walletSummaryProvider);
  }

  /// Verifies and saves a bank account, then adds it to the list.
  Future<PayoutMethod> add({
    required String bankCode,
    required String accountNumber,
  }) async {
    final method = await _repository.addPayoutMethod(
      bankCode: bankCode,
      accountNumber: accountNumber,
    );
    final methods = state.value ?? const [];
    state = AsyncData([
      for (final m in methods)
        if (m.id != method.id)
          method.isDefault ? m.copyWith(isDefault: false) : m,
      method,
    ]);
    ref.invalidate(walletSummaryProvider);
    return method;
  }
}

final banksProvider = FutureProvider<List<Bank>>(
  (ref) => ref.watch(walletRepositoryProvider).listBanks(),
);

/// The bank's name for a complete account number.
final resolvedAccountProvider = FutureProvider.autoDispose
    .family<ResolvedAccount, ({String bankCode, String accountNumber})>(
      (ref, key) => ref
          .watch(walletRepositoryProvider)
          .resolveAccount(
            bankCode: key.bankCode,
            accountNumber: key.accountNumber,
          ),
      retry: _noRetry,
    );

/// Payout currency, monthly auto-payout and tax details. The two switches
/// update at once and roll back if the server rejects them.
final payoutSettingsProvider =
    AsyncNotifierProvider<PayoutSettingsNotifier, PayoutSettings>(
      PayoutSettingsNotifier.new,
    );

class PayoutSettingsNotifier extends AsyncNotifier<PayoutSettings> {
  WalletRepository get _repository => ref.read(walletRepositoryProvider);

  @override
  Future<PayoutSettings> build() =>
      ref.watch(walletRepositoryProvider).getPayoutSettings();

  Future<void> setPayoutCurrency(Currency currency) {
    return _optimistic(
      (s) => s.copyWith(payoutCurrency: currency),
      () => _repository.setPayoutCurrency(currency),
    );
  }

  Future<void> setAutoMonthlyPayout(bool enabled) {
    return _optimistic(
      (s) => s.copyWith(autoMonthlyPayout: enabled),
      () => _repository.setAutoMonthlyPayout(enabled),
    );
  }

  /// Not optimistic: the form waits for the server, which may reject fields.
  Future<void> saveTaxInfo(TaxInfo info) async {
    state = AsyncData(await _repository.saveTaxInfo(info));
  }

  Future<void> _optimistic(
    PayoutSettings Function(PayoutSettings) change,
    Future<void> Function() request,
  ) async {
    final settings = state.value;
    if (settings == null) return;
    state = AsyncData(change(settings));
    try {
      await request();
    } catch (_) {
      state = AsyncData(settings);
      rethrow;
    }
  }
}
