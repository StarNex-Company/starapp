import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/wallet/data/models/payout_settings.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:starapp/features/wallet/presentation/pages/add_payout_method_page.dart';
import 'package:starapp/features/wallet/presentation/pages/payouts_page.dart';
import 'package:starapp/features/wallet/presentation/pages/statements_page.dart';
import 'package:starapp/features/wallet/presentation/pages/tax_info_page.dart';
import 'package:starapp/features/wallet/presentation/pages/transaction_page.dart';
import 'package:starapp/features/wallet/presentation/pages/wallet_activity_page.dart';
import 'package:starapp/features/wallet/presentation/pages/wallet_page.dart';
import 'package:starapp/features/wallet/presentation/pages/withdraw_page.dart';
import 'package:starapp/features/wallet/presentation/pages/withdrawal_sent_page.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_form.dart';

/// The wallet's routes as the app registers them, flat, plus the top-level
/// mirrors that full-screen Withdraw links to through `pushInTab`.
GoRouter _router(String location) {
  GoRoute page(String path, Widget Function(GoRouterState s) build) =>
      GoRoute(path: path, builder: (_, s) => build(s));
  final payouts = AppRoutes.payouts.replaceFirst('/profile', '');
  final methodNew = AppRoutes.payoutMethodNew.replaceFirst('/profile', '');
  final tax = AppRoutes.payoutTax.replaceFirst('/profile', '');

  return GoRouter(
    initialLocation: location,
    routes: [
      page(AppRoutes.home, (_) => const Scaffold(body: Text('Home'))),
      page(AppRoutes.wallet, (_) => const WalletPage()),
      page(AppRoutes.walletWithdraw, (_) => const WithdrawPage()),
      page(
        AppRoutes.walletWithdrawSent,
        (s) =>
            WithdrawalSentPage(reference: s.uri.queryParameters['ref'] ?? ''),
      ),
      page(AppRoutes.walletActivity, (_) => const WalletActivityPage()),
      page(AppRoutes.walletStatements, (_) => const StatementsPage()),
      page(
        AppRoutes.walletTransaction(':id'),
        (s) => TransactionPage(transactionId: s.pathParameters['id']!),
      ),
      page(AppRoutes.payouts, (_) => const PayoutsPage()),
      page(AppRoutes.payoutMethodNew, (_) => const AddPayoutMethodPage()),
      page(AppRoutes.payoutTax, (_) => const TaxInfoPage()),
      page(payouts, (_) => const PayoutsPage()),
      page(methodNew, (_) => const AddPayoutMethodPage()),
      page(tax, (_) => const TaxInfoPage()),
    ],
  );
}

Future<GoRouter> _pump(
  WidgetTester tester,
  String location, {
  MockWalletRepository? repository,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 62, bottom: 34);
  addTearDown(tester.view.reset);

  final router = _router(location);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(
          repository ?? MockWalletRepository(latency: Duration.zero),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// Lets the quote debounce fire and the quote come back.
Future<void> _quote(WidgetTester tester) async {
  await tester.pump(WithdrawPage.quoteDelay);
  await tester.pumpAndSettle();
}

/// Lets toasts finish before the test ends.
Future<void> _finish(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> _tapKeys(WidgetTester tester, String keys) async {
  for (final key in keys.split('')) {
    final button = find.byKey(ValueKey('keypad-$key'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }
}

void main() {
  testWidgets('Wallet shows the balance, totals and recent activity', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.wallet);

    expect(find.text('₦1,240,500.00'), findsOneWidget);
    expect(find.text(r'≈ $812.40 · updated just now'), findsOneWidget);
    expect(find.text('₦950K'), findsOneWidget);
    expect(find.text('₦168.5K'), findsOneWidget);
    expect(find.text('₦122K'), findsOneWidget);
    expect(find.text('GTBank •••• 4821'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('+₦900,000'), findsOneWidget);
    expect(find.text('−₦150,000'), findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);

    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.byType(WalletActivityPage), findsOneWidget);
  });

  testWidgets('Withdraw validates the amount against the quote', (
    tester,
  ) async {
    final router = await _pump(tester, AppRoutes.wallet);
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
    expect(find.byType(WithdrawPage), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.walletWithdraw);

    await _tapKeys(tester, '500');
    expect(find.text('₦500'), findsOneWidget);
    await _quote(tester);
    expect(find.text('The minimum withdrawal is ₦1,000.'), findsOneWidget);

    await tester.ensureVisible(find.text('25%'));
    await tester.tap(find.text('25%'));
    await _quote(tester);
    expect(
      find.text('₦310,125'),
      findsNWidgets(2),
      reason: "the amount and You'll receive",
    );
    expect(find.text('Within minutes'), findsOneWidget);
    expect(find.text('₦0'), findsOneWidget, reason: 'the fee');
    expect(find.text('Withdraw ₦310,125'), findsOneWidget);
    expect(find.textContaining('minimum'), findsNothing);

    await tester.ensureVisible(find.text('Max'));
    await tester.tap(find.text('Max'));
    await _tapKeys(tester, '1');
    expect(
      find.text("That's more than your available balance."),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('keypad-⌫')));
    await tester.tap(find.byKey(const ValueKey('keypad-⌫')));
    await _quote(tester);
    expect(find.text('Withdraw ₦1,240,500'), findsOneWidget);
    expect(find.textContaining('available balance.'), findsNothing);
  });

  testWidgets('a withdrawal lands on the sent screen and updates the wallet', (
    tester,
  ) async {
    final router = await _pump(tester, AppRoutes.wallet);
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
    await _tapKeys(tester, '500000');
    await _quote(tester);
    await tester.tap(find.text('Withdraw ₦500,000'));
    await tester.pumpAndSettle();

    expect(find.byType(WithdrawalSentPage), findsOneWidget);
    expect(router.state.uri.queryParameters['ref'], 'SA-WD-77120');
    expect(find.text('Ref SA-WD-77120'), findsOneWidget);
    expect(
      find.text(
        '₦500,000 is heading to GTBank •••• 4821. It usually arrives '
        'within minutes.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Back to Wallet'));
    await tester.pumpAndSettle();
    expect(find.byType(WalletPage), findsOneWidget);
    expect(find.text('₦740,500.00'), findsOneWidget);
    expect(find.text('−₦500,000'), findsOneWidget);
    expect(find.text('Processing'), findsNWidgets(2));
  });

  testWidgets('Withdraw is disabled at a zero balance', (tester) async {
    final repository = MockWalletRepository(latency: Duration.zero);
    await repository.withdraw(
      amount: (await repository.getWalletSummary()).available,
      payoutMethodId: 'pm-gtb-4821',
      idempotencyKey: 'empty-the-wallet',
    );
    await _pump(tester, AppRoutes.wallet, repository: repository);

    expect(find.text('₦0.00'), findsOneWidget);
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
    expect(find.byType(WithdrawPage), findsNothing);
  });

  testWidgets('All activity groups by month and loads the next page', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.walletActivity);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WalletActivityPage)),
    );

    expect(find.text('Challenge prize'), findsOneWidget);
    expect(find.textContaining('· processing'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(container.read(walletActivityProvider).value, hasLength(7));
    expect(container.read(walletActivityProvider.notifier).hasMore, isFalse);
  });

  testWidgets('a prize shows its challenge, conversion and reference', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.walletTransaction('tx-prize-afro-dance'));

    expect(find.text('+₦900,000'), findsOneWidget);
    expect(find.text('Challenge prize · paid'), findsOneWidget);
    expect(find.text('Afro-Dance Takeover'), findsOneWidget);
    expect(find.text('Top 10 · #7'), findsOneWidget);
    expect(find.text(r'$600 converted at ₦1,500'), findsOneWidget);
    expect(find.text('SA-PR-30218'), findsOneWidget);
    expect(find.text('Get help with this'), findsNothing);
  });

  testWidgets('Statements download shows the saved toast in mock mode', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.walletStatements);

    expect(find.text('PDF'), findsNWidgets(2));
    await tester.tap(find.text('PDF').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved to your files'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('Payouts: currency sheet and the auto-payout switch', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.payouts);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PayoutsPage)),
    );

    expect(find.text('Needed for payouts over ₦5M a year'), findsOneWidget);
    expect(find.text('₦1,240,500 available'), findsOneWidget);
    expect(find.text('NGN ₦'), findsOneWidget);

    await tester.tap(find.text('Payout currency'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'US Dollar ($ USD)'));
    await tester.pumpAndSettle();
    expect(find.text(r'USD $'), findsOneWidget);

    await tester.tap(find.byType(WalletToggle));
    await tester.pumpAndSettle();
    expect(
      container.read(payoutSettingsProvider).value?.autoMonthlyPayout,
      isTrue,
    );
  });

  testWidgets('Add payout method resolves the name, saves and pops', (
    tester,
  ) async {
    final router = await _pump(tester, AppRoutes.payouts);
    await tester.tap(find.text('Add payout method'));
    await tester.pumpAndSettle();
    expect(find.byType(AddPayoutMethodPage), findsOneWidget);

    await tester.tap(find.text('Choose your bank'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'acc');
    await tester.pumpAndSettle();
    expect(find.text('GTBank'), findsNothing);
    await tester.tap(find.text('Access Bank'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '0000000000');
    await tester.pumpAndSettle();
    expect(
      find.text("We couldn't verify this account. Check the number and bank."),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), '0123456789');
    await tester.pumpAndSettle();
    expect(find.text('0123 456 789'), findsOneWidget);
    expect(find.text('EMMANUEL AYANLEYE · verified ✓'), findsOneWidget);

    await tester.tap(find.text('Save payout method'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Payout method saved'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.payouts);
    expect(find.text('Access Bank •••• 6789'), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('Tax information shows local and server field errors', (
    tester,
  ) async {
    await _pump(
      tester,
      AppRoutes.payoutTax,
      repository: _RejectingTaxRepository(),
    );
    expect(
      find.textContaining('Needed once your yearly payouts pass ₦5,000,000.'),
      findsOneWidget,
    );
    expect(find.text('Nigeria'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '123');
    await tester.tap(find.text('Save tax details'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid TIN.'), findsOneWidget);
    expect(
      find.text('Enter your name as it appears on your ID.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField).first, '2345 6789 0123');
    await tester.enterText(find.byType(TextField).last, 'Emmanuel Ayanleye');
    await tester.tap(find.text('Save tax details'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid TIN.'), findsNothing);
    expect(find.text("This name doesn't match the TIN."), findsOneWidget);
    await _finish(tester);
  });
  testWidgets(
    'without a payout method the Wallet and Withdraw offer to add one',
    (tester) async {
      final router = await _pump(
        tester,
        AppRoutes.wallet,
        repository: _NoMethodRepository(),
      );
      expect(find.text('Add payout method'), findsOneWidget);
      expect(find.text('Change'), findsNothing);

      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      await _tapKeys(tester, '5000');
      await _quote(tester);
      expect(find.text('Withdraw ₦5,000'), findsOneWidget);
      await tester.tap(find.text('Withdraw ₦5,000'));
      await tester.pumpAndSettle();
      expect(find.byType(WithdrawalSentPage), findsNothing, reason: 'disabled');

      await tester.ensureVisible(find.text('Add payout method'));
      await tester.tap(find.text('Add payout method'));
      await tester.pumpAndSettle();
      expect(find.byType(AddPayoutMethodPage), findsOneWidget);
      expect(
        router.state.uri.path,
        AppRoutes.payoutMethodNew.replaceFirst('/profile', ''),
        reason: 'the top-level mirror, from the full-screen page',
      );
    },
  );
}

class _NoMethodRepository extends MockWalletRepository {
  _NoMethodRepository() : super(latency: Duration.zero);

  @override
  Future<WalletSummary> getWalletSummary() async {
    final s = await super.getWalletSummary();
    return WalletSummary(
      available: s.available,
      approxUsd: s.approxUsd,
      updatedAt: s.updatedAt,
      prizesTotal: s.prizesTotal,
      fanTipsTotal: s.fanTipsTotal,
      scoutDealsTotal: s.scoutDealsTotal,
      recent: s.recent,
    );
  }
}

class _RejectingTaxRepository extends MockWalletRepository {
  _RejectingTaxRepository() : super(latency: Duration.zero);

  @override
  Future<PayoutSettings> saveTaxInfo(TaxInfo info) async {
    throw const ValidationException(
      'Please check the details and try again.',
      statusCode: 422,
      fieldErrors: {'legalName': "This name doesn't match the TIN."},
    );
  }
}
