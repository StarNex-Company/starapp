import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/payout_settings.dart';
import 'package:starapp/features/wallet/data/models/statement.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';
import 'package:starapp/features/wallet/data/models/withdrawal.dart';
import 'package:starapp/features/wallet/data/repositories/wallet_repository.dart';

/// Serves JSON fixtures shaped like the API responses through the real
/// `fromJson`. It keeps its own state for the session so the flows hang
/// together: a withdrawal lowers the balance and shows up as processing, a
/// new payout method appears in the list.
///
/// Rules it enforces, as the backend should: withdrawals of at least
/// ₦1,000 and at most the available balance, no fee, and one withdrawal per
/// idempotency key.
class MockWalletRepository implements WalletRepository {
  MockWalletRepository({this.latency = const Duration(milliseconds: 400)})
    : _now = DateTime.now() {
    _transactions = _transactionFixtures(_now);
  }

  /// Delay on calls that hit a bank or move money, so their loading states
  /// show in mock mode.
  final Duration latency;
  final DateTime _now;

  static const _pageSize = 6;
  static const _recentCount = 5;
  static const _min = Money(100000, Currency.ngn);

  int _availableMinor = 124050000;
  int _nextReference = 77120;
  late final List<Json> _transactions;
  final List<Json> _methods = [
    {
      'id': 'pm-gtb-4821',
      'type': 'bankAccount',
      'bankName': 'GTBank',
      'bankCode': '058',
      'accountLast4': '4821',
      'accountName': 'Emmanuel Ayanleye',
      'isVerified': true,
      'isDefault': true,
    },
  ];
  final Json _settings = {
    'payoutCurrency': 'NGN',
    'autoMonthlyPayout': false,
    'taxInfo': null,
    'taxInfoRequired': false,
    'taxThreshold': {'amountMinor': 500000000, 'currency': 'NGN'},
  };
  final Map<String, Json> _withdrawalsByKey = {};

  Future<void> _wait() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  Json get _available => {'amountMinor': _availableMinor, 'currency': 'NGN'};

  Json? get _defaultMethod {
    for (final m in _methods) {
      if (m['isDefault'] == true) return m;
    }
    return null;
  }

  @override
  Future<WalletSummary> getWalletSummary() async => WalletSummary.fromJson({
    'available': _available,
    // $812.40 for the opening ₦1,240,500 (about ₦1,527/$); the API quotes
    // the live rate.
    'approxUsd': {
      'amountMinor': _availableMinor * 81240 ~/ 124050000,
      'currency': 'USD',
    },
    'updatedAt': DateTime.now().toUtc().toIso8601String(),
    'prizesTotal': {'amountMinor': 95000000, 'currency': 'NGN'},
    'fanTipsTotal': {'amountMinor': 16850000, 'currency': 'NGN'},
    'scoutDealsTotal': {'amountMinor': 12200000, 'currency': 'NGN'},
    'defaultPayoutMethod': _defaultMethod,
    'recent': _transactions.take(_recentCount).toList(),
  });

  @override
  Future<Paged<WalletTransaction>> listTransactions({String? cursor}) async {
    final start = int.tryParse(cursor ?? '') ?? 0;
    final end = (start + _pageSize).clamp(0, _transactions.length);
    return Paged.fromJson({
      'items': _transactions.sublist(start, end),
      'nextCursor': end < _transactions.length ? '$end' : null,
    }, WalletTransaction.fromJson);
  }

  @override
  Future<WalletTransaction> getTransaction(String id) async {
    for (final t in _transactions) {
      if (t['id'] == id) return WalletTransaction.fromJson(t);
    }
    throw const NotFoundException("We couldn't find that transaction.");
  }

  @override
  Future<List<Statement>> listStatements() async {
    Json statement(int monthsAgo, int closingMinor) {
      final month = DateTime(_now.year, _now.month - monthsAgo);
      final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      return {
        'id': 'st-$key',
        'year': month.year,
        'month': month.month,
        'closingBalance': {'amountMinor': closingMinor, 'currency': 'NGN'},
        'pdfUrl': 'https://api.starapp.io/v1/wallet/statements/st-$key.pdf',
      };
    }

    return readList([
      statement(1, 124050000),
      statement(2, 56800000),
    ], Statement.fromJson);
  }

  @override
  Future<WithdrawalQuote> quoteWithdrawal({
    required Money amount,
    required String payoutMethodId,
  }) async {
    _checkCurrency(amount);
    return WithdrawalQuote.fromJson({
      'amount': amount.toJson(),
      'fee': const Money.zero().toJson(),
      'receive': amount.toJson(),
      'arrivalEstimate': 'Within minutes',
      'min': _min.toJson(),
      'max': _available,
    });
  }

  @override
  Future<Withdrawal> withdraw({
    required Money amount,
    required String payoutMethodId,
    required String idempotencyKey,
  }) async {
    await _wait();
    final repeat = _withdrawalsByKey[idempotencyKey];
    if (repeat != null) return Withdrawal.fromJson(repeat);

    _checkCurrency(amount);
    if (amount.amountMinor < _min.amountMinor) {
      throw _amountError('The minimum withdrawal is ${_min.format()}.');
    }
    if (amount.amountMinor > _availableMinor) {
      throw _amountError("That's more than your available balance.");
    }
    final method = _methods.where((m) => m['id'] == payoutMethodId).firstOrNull;
    if (method == null) {
      throw const ValidationException('Choose where to send the money.');
    }

    final reference = 'SA-WD-${_nextReference++}';
    final createdAt = DateTime.now().toUtc().toIso8601String();
    final json = {
      'id': 'wd-$reference',
      'amount': amount.toJson(),
      'destination': method,
      'status': 'processing',
      'reference': reference,
      'createdAt': createdAt,
    };
    _availableMinor -= amount.amountMinor;
    _withdrawalsByKey[idempotencyKey] = json;
    _transactions.insert(0, {
      'id': 'tx-$reference',
      'type': 'withdrawal',
      'isCredit': false,
      'amount': amount.toJson(),
      'status': 'processing',
      'title': 'Withdrawal to ${method['bankName']}',
      'subtitle': '',
      'createdAt': createdAt,
      'reference': reference,
      'payoutMethodId': payoutMethodId,
    });
    return Withdrawal.fromJson(json);
  }

  @override
  Future<List<PayoutMethod>> listPayoutMethods() async =>
      readList(_methods, PayoutMethod.fromJson);

  @override
  Future<List<Bank>> listBanks() async => readList(_banks, Bank.fromJson);

  @override
  Future<ResolvedAccount> resolveAccount({
    required String bankCode,
    required String accountNumber,
  }) async {
    await _wait();
    return ResolvedAccount.fromJson({
      'accountName': _resolve(bankCode, accountNumber),
    });
  }

  @override
  Future<PayoutMethod> addPayoutMethod({
    required String bankCode,
    required String accountNumber,
  }) async {
    await _wait();
    final name = _resolve(bankCode, accountNumber);
    final bank = _banks.firstWhere((b) => b['code'] == bankCode);
    final last4 = accountNumber.substring(accountNumber.length - 4);
    final json = {
      'id': 'pm-$bankCode-$last4',
      'type': 'bankAccount',
      'bankName': bank['name'],
      'bankCode': bankCode,
      'accountLast4': last4,
      'accountName': name,
      'isVerified': true,
      'isDefault': _methods.isEmpty,
    };
    _methods
      ..removeWhere((m) => m['id'] == json['id'])
      ..add(json);
    return PayoutMethod.fromJson(json);
  }

  @override
  Future<void> setDefaultPayoutMethod(String id) async {
    if (!_methods.any((m) => m['id'] == id)) {
      throw const NotFoundException();
    }
    for (final m in _methods) {
      m['isDefault'] = m['id'] == id;
    }
  }

  @override
  Future<PayoutSettings> getPayoutSettings() async =>
      PayoutSettings.fromJson(_settings);

  @override
  Future<void> setPayoutCurrency(Currency currency) async =>
      _settings['payoutCurrency'] = currency.code;

  @override
  Future<void> setAutoMonthlyPayout(bool enabled) async =>
      _settings['autoMonthlyPayout'] = enabled;

  @override
  Future<PayoutSettings> saveTaxInfo(TaxInfo info) async {
    await _wait();
    final digits = info.tin.replaceAll('-', '');
    if (digits.length < 8 || int.tryParse(digits) == null) {
      throw const ValidationException(
        'Please check the details and try again.',
        statusCode: 422,
        fieldErrors: {'tin': 'Enter a valid TIN.'},
      );
    }
    _settings
      ..['taxInfo'] = info.toJson()
      ..['taxInfoRequired'] = false;
    return PayoutSettings.fromJson(_settings);
  }

  /// "0000000000" stands in for an account the bank doesn't recognise.
  String _resolve(String bankCode, String accountNumber) {
    if (!_banks.any((b) => b['code'] == bankCode)) {
      throw const ValidationException(
        'Choose your bank.',
        statusCode: 422,
        fieldErrors: {'bankCode': 'Choose your bank.'},
      );
    }
    if (!RegExp(r'^\d{10}$').hasMatch(accountNumber) ||
        accountNumber == '0000000000') {
      throw const ValidationException(
        "We couldn't verify this account. Check the number and bank.",
        statusCode: 422,
        fieldErrors: {
          'accountNumber':
              "We couldn't verify this account. Check the number and bank.",
        },
      );
    }
    return 'EMMANUEL AYANLEYE';
  }

  static void _checkCurrency(Money amount) {
    if (amount.currency != Currency.ngn) {
      throw const ValidationException('Withdrawals are in naira only.');
    }
  }

  static ValidationException _amountError(String message) =>
      ValidationException(
        message,
        statusCode: 422,
        fieldErrors: {'amount': message},
      );
}

const List<Json> _banks = [
  {'code': '044', 'name': 'Access Bank'},
  {'code': '011', 'name': 'First Bank'},
  {'code': '058', 'name': 'GTBank'},
  {'code': '50211', 'name': 'Kuda'},
  {'code': '033', 'name': 'UBA'},
  {'code': '057', 'name': 'Zenith Bank'},
];

/// Newest first: every type and status the wallet screens show.
List<Json> _transactionFixtures(DateTime now) {
  String ago(int days, [int hours = 0]) => now
      .subtract(Duration(days: days, hours: hours))
      .toUtc()
      .toIso8601String();
  Json ngn(int major) => {'amountMinor': major * 100, 'currency': 'NGN'};

  return [
    {
      'id': 'tx-prize-afro-dance',
      'type': 'challengePrize',
      'isCredit': true,
      'amount': ngn(900000),
      'status': 'paid',
      'title': 'Challenge prize',
      'subtitle': 'Afro-Dance Takeover · Top 10',
      'createdAt': ago(1, 3),
      'reference': 'SA-PR-30218',
      'challengeId': 'afro-dance-takeover',
      'challengeName': 'Afro-Dance Takeover',
      'rank': 7,
      'originalAmount': {'amountMinor': 60000, 'currency': 'USD'},
      'fxRate': 1500,
    },
    {
      'id': 'tx-wd-77102',
      'type': 'withdrawal',
      'isCredit': false,
      'amount': ngn(150000),
      'status': 'processing',
      'title': 'Withdrawal to GTBank',
      'subtitle': '',
      'createdAt': ago(2, 1),
      'reference': 'SA-WD-77102',
      'payoutMethodId': 'pm-gtb-4821',
    },
    {
      'id': 'tx-tips-48',
      'type': 'fanTips',
      'isCredit': true,
      'amount': ngn(12500),
      'status': 'paid',
      'title': 'Fan tips',
      'subtitle': '48 fans',
      'createdAt': ago(4),
      'reference': 'SA-FT-11873',
      'fanCount': 48,
    },
    {
      'id': 'tx-scout-kora',
      'type': 'scoutDeal',
      'isCredit': true,
      'amount': ngn(122000),
      'status': 'paid',
      'title': 'Scout deal · Kora Studios',
      'subtitle': 'Backing vocals',
      'createdAt': ago(12),
      'reference': 'SA-SD-40921',
      'companyId': 'kora-studios',
      'companyName': 'Kora Studios',
      'applicationId': 'app-kora-backing-vocals',
    },
    {
      'id': 'tx-wd-76988',
      'type': 'withdrawal',
      'isCredit': false,
      'amount': ngn(300000),
      'status': 'completed',
      'title': 'Withdrawal to GTBank',
      'subtitle': '',
      'createdAt': ago(15),
      'reference': 'SA-WD-76988',
      'payoutMethodId': 'pm-gtb-4821',
    },
    {
      'id': 'tx-tips-31',
      'type': 'fanTips',
      'isCredit': true,
      'amount': ngn(8200),
      'status': 'paid',
      'title': 'Fan tips',
      'subtitle': '31 fans',
      'createdAt': ago(25),
      'reference': 'SA-FT-11604',
      'fanCount': 31,
    },
    {
      'id': 'tx-wd-76511',
      'type': 'withdrawal',
      'isCredit': false,
      'amount': ngn(50000),
      'status': 'failed',
      'title': 'Withdrawal to GTBank',
      'subtitle': '',
      'createdAt': ago(40),
      'reference': 'SA-WD-76511',
      'payoutMethodId': 'pm-gtb-4821',
    },
  ];
}
