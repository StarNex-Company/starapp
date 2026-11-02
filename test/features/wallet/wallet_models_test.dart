import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/payout_settings.dart';
import 'package:starapp/features/wallet/data/models/statement.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';
import 'package:starapp/features/wallet/data/models/withdrawal.dart';
import 'package:starapp/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:starapp/features/wallet/presentation/widgets/amount_input.dart';

MockWalletRepository _repo() => MockWalletRepository(latency: Duration.zero);

const _ngn = Currency.ngn;

void main() {
  group('fixtures', () {
    test('the summary parses and covers the Wallet screen', () async {
      final summary = await _repo().getWalletSummary();

      expect(summary.available, const Money(124050000, _ngn));
      expect(summary.available.format(decimals: true), '₦1,240,500.00');
      expect(summary.approxUsd, const Money(81240, Currency.usd));
      expect(summary.defaultPayoutMethod?.label, 'GTBank •••• 4821');
      expect(summary.defaultPayoutMethod?.isDefault, isTrue);
      expect(summary.recent, isNotEmpty);
      expect(
        summary.recent.first.type,
        TransactionType.challengePrize,
        reason: 'the +₦900,000 prize leads',
      );
      expect(summary.recent.first.amount, Money.major(900000, _ngn));
      expect(
        summary.recent.any(
          (t) =>
              t.type == TransactionType.withdrawal &&
              t.status == TransactionStatus.processing &&
              t.amount == Money.major(150000, _ngn) &&
              !t.isCredit,
        ),
        isTrue,
        reason: 'a processing −₦150,000 withdrawal',
      );
      expect(
        summary.recent.any((t) => t.type == TransactionType.fanTips),
        isTrue,
      );
    });

    test('transactions cover every type and status the screens show', () async {
      final repo = _repo();
      final first = await repo.listTransactions();
      expect(first.hasMore, isTrue, reason: 'All activity pages');
      final second = await repo.listTransactions(cursor: first.nextCursor);
      expect(second.hasMore, isFalse);
      final all = [...first.items, ...second.items];

      expect({for (final t in all) t.id}.length, all.length);
      expect(
        {for (final t in all) t.type},
        {
          TransactionType.challengePrize,
          TransactionType.fanTips,
          TransactionType.scoutDeal,
          TransactionType.withdrawal,
        },
      );
      expect(
        {for (final t in all) t.status},
        containsAll([
          TransactionStatus.processing,
          TransactionStatus.paid,
          TransactionStatus.completed,
          TransactionStatus.failed,
        ]),
      );
      final prize = all.firstWhere(
        (t) => t.type == TransactionType.challengePrize,
      );
      expect(prize.rank, 7);
      expect(prize.originalAmount, const Money(60000, Currency.usd));
      expect(prize.fxRate, 1500);
      expect(
        prize.originalAmount!.amountMinor * prize.fxRate!,
        prize.amount.amountMinor,
        reason: r'$600 × ₦1,500 = ₦900,000 exactly',
      );
      expect(
        all.firstWhere((t) => t.type == TransactionType.scoutDeal).companyName,
        'Kora Studios',
      );
      expect((await repo.getTransaction(prize.id)).reference, 'SA-PR-30218');
      await expectLater(
        repo.getTransaction('missing'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('two statements and a few banks', () async {
      final repo = _repo();
      final statements = await repo.listStatements();
      expect(statements, hasLength(2));
      expect(statements.first.closingBalance, const Money(124050000, _ngn));
      expect(statements.every((s) => s.month >= 1 && s.month <= 12), isTrue);
      expect((await repo.listBanks()).length, greaterThanOrEqualTo(3));
    });
  });

  group('mock withdrawal rules', () {
    test(
      'quotes a ₦0 fee, a ₦1,000 minimum and the balance as maximum',
      () async {
        final quote = await _repo().quoteWithdrawal(
          amount: Money.major(500000, _ngn),
          payoutMethodId: 'pm-gtb-4821',
        );
        expect(quote.fee, const Money.zero());
        expect(quote.receive, Money.major(500000, _ngn));
        expect(quote.min, Money.major(1000, _ngn));
        expect(quote.max, const Money(124050000, _ngn));
        expect(quote.arrivalEstimate, 'Within minutes');
      },
    );

    test('rejects amounts under the minimum or over the balance', () async {
      final repo = _repo();
      for (final amount in [
        Money.major(999.99, _ngn),
        const Money(124050001, _ngn),
      ]) {
        await expectLater(
          repo.withdraw(
            amount: amount,
            payoutMethodId: 'pm-gtb-4821',
            idempotencyKey: newIdempotencyKey(),
          ),
          throwsA(isA<ValidationException>()),
        );
      }
      final summary = await repo.getWalletSummary();
      expect(summary.available, const Money(124050000, _ngn));
    });

    test('one idempotency key pays out once', () async {
      final repo = _repo();
      final key = newIdempotencyKey();
      Future<Withdrawal> send() => repo.withdraw(
        amount: Money.major(500000, _ngn),
        payoutMethodId: 'pm-gtb-4821',
        idempotencyKey: key,
      );

      final first = await send();
      final retry = await send();
      expect(retry.id, first.id);
      expect(first.reference, 'SA-WD-77120');
      expect(first.status, TransactionStatus.processing);

      final summary = await repo.getWalletSummary();
      expect(summary.available, Money.major(740500, _ngn));
      expect(summary.recent.first.reference, first.reference);
      expect(summary.recent.first.status, TransactionStatus.processing);
    });

    test(
      'adding a bank account resolves its name; a bad number fails',
      () async {
        final repo = _repo();
        final resolved = await repo.resolveAccount(
          bankCode: '044',
          accountNumber: '0123456789',
        );
        expect(resolved.accountName, 'EMMANUEL AYANLEYE');
        await expectLater(
          repo.resolveAccount(bankCode: '044', accountNumber: '0000000000'),
          throwsA(isA<ValidationException>()),
        );

        final added = await repo.addPayoutMethod(
          bankCode: '044',
          accountNumber: '0123456789',
        );
        expect(added.label, 'Access Bank •••• 6789');
        expect(added.isDefault, isFalse);
        await repo.setDefaultPayoutMethod(added.id);
        final methods = await repo.listPayoutMethods();
        expect(
          [
            for (final m in methods)
              if (m.isDefault) m.id,
          ],
          [added.id],
        );
      },
    );

    test('tax info is validated and saved', () async {
      final repo = _repo();
      final before = await repo.getPayoutSettings();
      expect(before.taxThreshold, Money.major(5000000, _ngn));
      expect(before.taxInfo, isNull);

      await expectLater(
        repo.saveTaxInfo(
          const TaxInfo(tin: '123', legalName: 'A B', countryCode: 'NG'),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.fieldErrors.keys,
            'fieldErrors',
            contains('tin'),
          ),
        ),
      );
      final saved = await repo.saveTaxInfo(
        const TaxInfo(
          tin: '234567890123',
          legalName: 'Emmanuel Ayanleye',
          countryCode: 'NG',
        ),
      );
      expect(saved.taxInfo?.legalName, 'Emmanuel Ayanleye');
    });
  });

  group('JSON', () {
    test('every model round-trips', () async {
      final repo = _repo();
      final summary = await repo.getWalletSummary();
      expect(
        WalletSummary.fromJson(summary.toJson()).toJson(),
        summary.toJson(),
      );

      final page = await repo.listTransactions();
      for (final t in page.items) {
        expect(WalletTransaction.fromJson(t.toJson()).toJson(), t.toJson());
      }
      for (final s in await repo.listStatements()) {
        expect(Statement.fromJson(s.toJson()).toJson(), s.toJson());
      }
      for (final m in await repo.listPayoutMethods()) {
        expect(PayoutMethod.fromJson(m.toJson()).toJson(), m.toJson());
      }
      for (final b in await repo.listBanks()) {
        expect(Bank.fromJson(b.toJson()).toJson(), b.toJson());
      }
      final resolved = await repo.resolveAccount(
        bankCode: '058',
        accountNumber: '0123456789',
      );
      expect(
        ResolvedAccount.fromJson(resolved.toJson()).toJson(),
        resolved.toJson(),
      );

      final quote = await repo.quoteWithdrawal(
        amount: Money.major(5000, _ngn),
        payoutMethodId: 'pm-gtb-4821',
      );
      expect(WithdrawalQuote.fromJson(quote.toJson()).toJson(), quote.toJson());

      final withdrawal = await repo.withdraw(
        amount: Money.major(5000, _ngn),
        payoutMethodId: 'pm-gtb-4821',
        idempotencyKey: newIdempotencyKey(),
      );
      expect(
        Withdrawal.fromJson(withdrawal.toJson()).toJson(),
        withdrawal.toJson(),
      );

      final settings = await repo.saveTaxInfo(
        const TaxInfo(tin: '12345678', legalName: 'Ada', countryCode: 'GH'),
      );
      expect(
        PayoutSettings.fromJson(settings.toJson()).toJson(),
        settings.toJson(),
      );
    });

    test('unknown enums and missing optional fields fall back', () {
      final t = WalletTransaction.fromJson({
        'id': 'x',
        'type': 'somethingNew',
        'status': 'onHold',
        'amount': {'amountMinor': 100, 'currency': 'NGN'},
      });
      expect(t.type, TransactionType.adjustment);
      expect(t.status, TransactionStatus.pending);
      expect(t.isCredit, isFalse);
      expect(t.subtitle, '');
      expect(t.rank, isNull);
      expect(t.originalAmount, isNull);

      final summary = WalletSummary.fromJson({
        'available': {'amountMinor': 0, 'currency': 'NGN'},
        'prizesTotal': {'amountMinor': 0, 'currency': 'NGN'},
        'fanTipsTotal': {'amountMinor': 0, 'currency': 'NGN'},
        'scoutDealsTotal': {'amountMinor': 0, 'currency': 'NGN'},
      });
      expect(summary.defaultPayoutMethod, isNull);
      expect(summary.approxUsd, isNull);
      expect(summary.recent, isEmpty);
    });
  });

  group('AmountInput', () {
    test('converts to exact minor units', () {
      var input = const AmountInput();
      for (final key in ['0', '1', '2', '5', '0', '.', '5', '5', '9']) {
        input = input.press(key);
      }
      expect(input.text, '1250.55', reason: 'leading zero and 3rd decimal');
      expect(input.toMoney(_ngn), const Money(125055, _ngn));
      expect(input.display(_ngn), '₦1,250.55');
      expect(input.press('.').text, '1250.55');
      expect(const AmountInput().press('.').text, '0.');
      expect(const AmountInput('0.').toMoney(_ngn), const Money(0, _ngn));
      expect(const AmountInput('0.5').toMoney(_ngn), const Money(50, _ngn));
      expect(input.backspace().text, '1250.5');
    });

    test('round-trips money and caps the length', () {
      expect(
        AmountInput.fromMoney(const Money(31012525, _ngn)).text,
        '310125.25',
      );
      expect(AmountInput.fromMoney(const Money(50, _ngn)).text, '0.50');
      expect(AmountInput.fromMoney(Money.major(500000, _ngn)).text, '500000');
      var input = const AmountInput('9999999999');
      input = input.press('9');
      expect(input.text, '9999999999');
    });

    test('idempotency keys are random v4 UUIDs', () {
      final key = newIdempotencyKey(Random(1));
      expect(
        key,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-'
            r'[0-9a-f]{12}$',
          ),
        ),
      );
      expect(newIdempotencyKey(), isNot(newIdempotencyKey()));
    });
  });
}
