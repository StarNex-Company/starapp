import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/payout_settings.dart';
import 'package:starapp/features/wallet/data/models/statement.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';
import 'package:starapp/features/wallet/data/models/withdrawal.dart';
import 'package:starapp/features/wallet/data/repositories/wallet_repository.dart';

class ApiWalletRepository implements WalletRepository {
  const ApiWalletRepository(this._client);

  final ApiClient _client;

  @override
  Future<WalletSummary> getWalletSummary() => _client.get(
    '/wallet',
    decode: (json) => WalletSummary.fromJson(json as Json),
  );

  @override
  Future<Paged<WalletTransaction>> listTransactions({String? cursor}) =>
      _client.get(
        '/wallet/transactions',
        query: {'cursor': cursor},
        decode: (json) =>
            Paged.fromJson(json as Json, WalletTransaction.fromJson),
      );

  @override
  Future<WalletTransaction> getTransaction(String id) => _client.get(
    '/wallet/transactions/$id',
    decode: (json) => WalletTransaction.fromJson(json as Json),
  );

  @override
  Future<List<Statement>> listStatements() => _client.get(
    '/wallet/statements',
    decode: (json) => readList(json, Statement.fromJson),
  );

  @override
  Future<WithdrawalQuote> quoteWithdrawal({
    required Money amount,
    required String payoutMethodId,
  }) => _client.post(
    '/wallet/withdrawals/quote',
    data: {'amount': amount.toJson(), 'payoutMethodId': payoutMethodId},
    decode: (json) => WithdrawalQuote.fromJson(json as Json),
  );

  @override
  Future<Withdrawal> withdraw({
    required Money amount,
    required String payoutMethodId,
    required String idempotencyKey,
  }) => _client.post(
    '/wallet/withdrawals',
    // The key goes in the standard header; it's also in the body for
    // backends that read it there.
    headers: {'Idempotency-Key': idempotencyKey},
    data: {
      'amount': amount.toJson(),
      'payoutMethodId': payoutMethodId,
      'idempotencyKey': idempotencyKey,
    },
    decode: (json) => Withdrawal.fromJson(json as Json),
  );

  @override
  Future<List<PayoutMethod>> listPayoutMethods() => _client.get(
    '/payout-methods',
    decode: (json) => readList(json, PayoutMethod.fromJson),
  );

  @override
  Future<List<Bank>> listBanks() =>
      _client.get('/banks', decode: (json) => readList(json, Bank.fromJson));

  @override
  Future<ResolvedAccount> resolveAccount({
    required String bankCode,
    required String accountNumber,
  }) => _client.get(
    '/banks/resolve',
    query: {'bankCode': bankCode, 'accountNumber': accountNumber},
    decode: (json) => ResolvedAccount.fromJson(json as Json),
  );

  @override
  Future<PayoutMethod> addPayoutMethod({
    required String bankCode,
    required String accountNumber,
  }) => _client.post(
    '/payout-methods',
    data: {
      'type': PayoutMethodType.bankAccount.name,
      'bankCode': bankCode,
      'accountNumber': accountNumber,
    },
    decode: (json) => PayoutMethod.fromJson(json as Json),
  );

  @override
  Future<void> setDefaultPayoutMethod(String id) =>
      _client.put<void>('/payout-methods/$id/default');

  @override
  Future<PayoutSettings> getPayoutSettings() => _client.get(
    '/payout-settings',
    decode: (json) => PayoutSettings.fromJson(json as Json),
  );

  @override
  Future<void> setPayoutCurrency(Currency currency) => _client.patch<void>(
    '/payout-settings',
    data: {'payoutCurrency': currency.code},
  );

  @override
  Future<void> setAutoMonthlyPayout(bool enabled) => _client.patch<void>(
    '/payout-settings',
    data: {'autoMonthlyPayout': enabled},
  );

  @override
  Future<PayoutSettings> saveTaxInfo(TaxInfo info) => _client.put(
    '/payout-settings/tax',
    data: info.toJson(),
    decode: (json) => PayoutSettings.fromJson(json as Json),
  );
}
