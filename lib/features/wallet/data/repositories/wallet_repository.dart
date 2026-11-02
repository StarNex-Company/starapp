import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/payout_settings.dart';
import 'package:starapp/features/wallet/data/models/statement.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';
import 'package:starapp/features/wallet/data/models/withdrawal.dart';

/// The creator's earnings, withdrawals and payout setup. Screens read the
/// providers in `wallet_providers.dart`; `walletRepositoryProvider` picks the
/// mock or API implementation.
abstract interface class WalletRepository {
  // Balance and history

  Future<WalletSummary> getWalletSummary();

  /// Newest first; pass the previous page's `nextCursor` for the next one.
  Future<Paged<WalletTransaction>> listTransactions({String? cursor});

  Future<WalletTransaction> getTransaction(String id);

  // Statements

  /// Newest first.
  Future<List<Statement>> listStatements();

  // Withdrawing

  /// Fee, arrival and limits for withdrawing [amount] to [payoutMethodId].
  Future<WithdrawalQuote> quoteWithdrawal({
    required Money amount,
    required String payoutMethodId,
  });

  /// Sends [amount] to [payoutMethodId]. The server must treat a repeated
  /// [idempotencyKey] as the same withdrawal and return it again, so a retry
  /// after a dropped connection never pays out twice.
  Future<Withdrawal> withdraw({
    required Money amount,
    required String payoutMethodId,
    required String idempotencyKey,
  });

  // Payout methods

  Future<List<PayoutMethod>> listPayoutMethods();

  Future<List<Bank>> listBanks();

  /// The bank's name for the account; throws a `ValidationException` when
  /// the bank doesn't recognise it.
  Future<ResolvedAccount> resolveAccount({
    required String bankCode,
    required String accountNumber,
  });

  /// Verifies and saves a bank account. It becomes the default when it's the
  /// user's first method.
  Future<PayoutMethod> addPayoutMethod({
    required String bankCode,
    required String accountNumber,
  });

  Future<void> setDefaultPayoutMethod(String id);

  // Payout settings

  Future<PayoutSettings> getPayoutSettings();

  Future<void> setPayoutCurrency(Currency currency);

  Future<void> setAutoMonthlyPayout(bool enabled);

  /// Saves [info] and returns the updated settings.
  Future<PayoutSettings> saveTaxInfo(TaxInfo info);
}
