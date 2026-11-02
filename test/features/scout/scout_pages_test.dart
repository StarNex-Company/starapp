import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/provider/scout_providers.dart';
import 'package:starapp/features/scout/data/repositories/mock_scout_repository.dart';
import 'package:starapp/features/scout/presentation/pages/company_page.dart';
import 'package:starapp/features/scout/presentation/pages/my_applications_page.dart';
import 'package:starapp/features/scout/presentation/pages/open_call_page.dart';
import 'package:starapp/features/scout/presentation/pages/scout_marketplace_page.dart';
import 'package:starapp/features/scout/presentation/pages/scout_request_page.dart';
import 'package:starapp/features/scout/presentation/pages/scout_requests_page.dart';

/// Stand-in for pages other features own.
Widget _stub(String label) => Scaffold(body: Center(child: Text(label)));

/// The app's shape for Scout: tab pages in a shell navigator, the request
/// and conversation full screen, plus the top-level mirrors `pushInTab`
/// uses from full-screen pages.
GoRouter _router(String location) => GoRouter(
  initialLocation: location,
  routes: [
    ShellRoute(
      builder: (_, _, child) => child,
      routes: [
        GoRoute(
          path: '/messages',
          builder: (_, _) => _stub('inbox'),
          routes: [
            GoRoute(
              path: 'requests',
              builder: (_, _) => const ScoutRequestsPage(),
            ),
            GoRoute(
              path: 'new',
              builder: (_, s) =>
                  _stub('new message to ${s.uri.queryParameters['to']}'),
            ),
            GoRoute(
              path: 'attachments/:id',
              builder: (_, s) => _stub('attachment ${s.pathParameters['id']}'),
            ),
            GoRoute(
              path: 'scout',
              builder: (_, _) => const ScoutMarketplacePage(),
              routes: [
                GoRoute(
                  path: 'applications',
                  builder: (_, _) => const MyApplicationsPage(),
                ),
                GoRoute(
                  path: 'calls/:id',
                  builder: (_, s) =>
                      OpenCallPage(callId: s.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'companies/:id',
                  builder: (_, s) =>
                      CompanyPage(companyId: s.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/profile/wallet/transactions/:id',
          builder: (_, s) => _stub('transaction ${s.pathParameters['id']}'),
        ),
      ],
    ),
    GoRoute(
      path: '/scout/requests/:id',
      builder: (_, s) => ScoutRequestPage(requestId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/scout/calls/:id',
      builder: (_, s) => OpenCallPage(callId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/scout/companies/:id',
      builder: (_, s) => CompanyPage(companyId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/attachments/:id',
      builder: (_, s) => _stub('attachment ${s.pathParameters['id']}'),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (_, s) => _stub('chat ${s.pathParameters['id']}'),
    ),
  ],
);

Future<GoRouter> _pump(
  WidgetTester tester,
  String location, {
  MockScoutRepository? repository,
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
        scoutRepositoryProvider.overrideWithValue(
          repository ?? MockScoutRepository(latency: _latency),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await _settle(tester);
  return router;
}

const _latency = Duration(milliseconds: 100);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Pops and waits out the route transition.
Future<void> _pop(WidgetTester tester, GoRouter router) async {
  router.pop();
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Lets a toast fade out so no timers are left running.
Future<void> _settleToast(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 300));
}

String _location(GoRouter router) => router.state.uri.toString();

class _FailingApply extends MockScoutRepository {
  _FailingApply() : super(latency: _latency);

  @override
  Future<Application> applyToOpenCall(String id) async {
    await Future<void>.delayed(latency);
    throw const NetworkException();
  }
}

class _NoApplications extends MockScoutRepository {
  _NoApplications() : super(latency: _latency);

  @override
  Future<ApplicationsSummary> getApplicationsSummary() async =>
      const ApplicationsSummary();
}

class _FailingCalls extends MockScoutRepository {
  _FailingCalls() : super(latency: _latency);

  bool fail = true;

  @override
  listOpenCalls(filters, {String? cursor}) async {
    if (fail) throw const NetworkException();
    return super.listOpenCalls(filters, cursor: cursor);
  }
}

void main() {
  group('Scout Marketplace', () {
    testWidgets('shows the summary, the featured call and the rows', (
      tester,
    ) async {
      await _pump(tester, '/messages/scout');

      expect(find.text('Scout Marketplace'), findsOneWidget);
      expect(find.text('Your applications'), findsOneWidget);
      expect(find.text('FEATURED'), findsOneWidget);
      expect(
        find.text('Lead Vocalist, "Gold Coast" Summer Tour 2027'),
        findsOneWidget,
      );
      expect(find.text('Apply now'), findsOneWidget);
      expect(find.text('Open calls for you'), findsOneWidget);
      expect(find.text('4'), findsOneWidget, reason: 'My Applications pill');
    });

    testWidgets('Apply goes Applying → Applied and counts it at once', (
      tester,
    ) async {
      await _pump(tester, '/messages/scout');

      await tester.tap(find.text('Apply now'));
      await tester.pump();
      expect(find.text('Applying'), findsOneWidget);
      expect(find.text('5'), findsOneWidget, reason: 'counted optimistically');
      expect(find.text('2'), findsOneWidget, reason: 'Sent 1 → 2');

      await tester.pump(_latency);
      await _settle(tester);
      expect(find.text('Applied · In review'), findsOneWidget);
      expect(find.text('Applying'), findsNothing);
    });

    testWidgets('a failed apply rolls back and shows a toast', (tester) async {
      await _pump(tester, '/messages/scout', repository: _FailingApply());

      await tester.tap(find.text('Apply now'));
      await tester.pump();
      expect(find.text('Applying'), findsOneWidget);

      await tester.pump(_latency);
      await tester.pump();
      expect(find.text('Apply now'), findsOneWidget);
      expect(find.text('4'), findsOneWidget, reason: 'count rolled back');
      expect(find.text(const NetworkException().message), findsOneWidget);
      await _settleToast(tester);
    });

    testWidgets('the summary card hides when there are no applications', (
      tester,
    ) async {
      await _pump(tester, '/messages/scout', repository: _NoApplications());

      expect(find.text('Your applications'), findsNothing);
      expect(find.text('My Applications'), findsOneWidget);
    });

    testWidgets('only the filter icon opens the sheet; Show N roles applies', (
      tester,
    ) async {
      await _pump(tester, '/messages/scout');

      await tester.tap(find.byType(TextField));
      await _settle(tester);
      expect(find.text('Filter open calls'), findsNothing);

      await tester.tap(find.byTooltip('Filter open calls'));
      await _settle(tester);
      expect(find.text('Filter open calls'), findsOneWidget);
      expect(find.text('Show 6 roles'), findsOneWidget);

      await tester.tap(find.text('Music').last);
      await _settle(tester);
      expect(find.text('Show 1 role'), findsOneWidget);

      await tester.ensureVisible(find.text('Show 1 role'));
      await tester.tap(find.text('Show 1 role'));
      await _settle(tester);
      expect(find.text('Filter open calls'), findsNothing);
      expect(find.text('Open calls for you'), findsNothing);
      expect(find.text('FEATURED'), findsOneWidget);
    });

    testWidgets('search filters the list and offers a reset when empty', (
      tester,
    ) async {
      await _pump(tester, '/messages/scout');

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(const Duration(milliseconds: 300));
      await _settle(tester);
      expect(find.text('No open calls match your search.'), findsOneWidget);

      await tester.tap(find.text('Reset filters'));
      await _settle(tester);
      expect(find.text('FEATURED'), findsOneWidget);
    });

    testWidgets('a load error offers a retry', (tester) async {
      final repository = _FailingCalls();
      await _pump(tester, '/messages/scout', repository: repository);

      expect(find.text(const NetworkException().message), findsOneWidget);
      repository.fail = false;
      await tester.tap(find.text('Try again'));
      await _settle(tester);
      expect(find.text('FEATURED'), findsOneWidget);
    });

    testWidgets('rows, the segment and View all navigate', (tester) async {
      final router = await _pump(tester, '/messages/scout');

      await tester.tap(find.text('My Applications'));
      await _settle(tester);
      expect(_location(router), '/messages/scout/applications');
      await _pop(tester, router);

      await tester.tap(
        find.text('Lead Vocalist, "Gold Coast" Summer Tour 2027'),
      );
      await _settle(tester);
      expect(_location(router), '/messages/scout/calls/gold-coast-tour');
    });
  });

  group('Open call', () {
    testWidgets('the notice opens the company', (tester) async {
      final router = await _pump(
        tester,
        '/messages/scout/calls/gold-coast-tour',
      );

      expect(find.text('Afrowave Records · Verified company'), findsOneWidget);
      expect(find.text('Paid per show'), findsOneWidget);
      expect(find.text('Jun – Aug ${DateTime.now().year + 1}'), findsOneWidget);
      await tester.tap(find.text('Afrowave Records · Verified company'));
      await _settle(tester);
      expect(_location(router), '/messages/scout/companies/afrowave-records');
    });

    testWidgets('not eligible names the missing requirement', (tester) async {
      await _pump(tester, '/messages/scout/calls/nova-halftime');

      await tester.scrollUntilVisible(find.text('Not eligible'), 200);
      expect(find.text('Requires: Stellar tier or above'), findsOneWidget);
      expect(find.text('Apply now'), findsNothing);
    });

    testWidgets('an applied call shows its status', (tester) async {
      await _pump(tester, '/messages/scout/calls/pulse-brand-voice');

      await tester.scrollUntilVisible(find.text('Applied · Shortlisted'), 200);
      expect(find.text('Closed'), findsOneWidget, reason: 'Applicants note');
    });

    testWidgets('Apply now applies from the page', (tester) async {
      await _pump(tester, '/messages/scout/calls/eko-nights-dancers');

      await tester.scrollUntilVisible(find.text('Apply now'), 200);
      await tester.tap(find.text('Apply now'));
      await tester.pump();
      expect(find.text('Applying'), findsOneWidget);
      await tester.pump(_latency);
      await _settle(tester);
      expect(find.text('Applied · In review'), findsOneWidget);
    });
  });

  testWidgets('My applications rows lead by status', (tester) async {
    final router = await _pump(tester, '/messages/scout/applications');

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);

    await tester.tap(find.text('In review'));
    await _settle(tester);
    expect(_location(router), '/messages/scout/calls/kora-choreographer');
    await _pop(tester, router);

    await tester.tap(find.text('Offer'));
    await _settle(tester);
    expect(_location(router), '/chat/c-afrowave');
    await _pop(tester, router);

    await tester.tap(find.text('Completed'));
    await _settle(tester);
    expect(_location(router), '/profile/wallet/transactions/tx-scout-kora');
  });

  group('Company', () {
    testWidgets('follow is instant and toasts', (tester) async {
      await _pump(tester, '/messages/scout/companies/afrowave-records');

      expect(find.text('24.6K followers · 48 artists signed'), findsNothing);
      expect(find.textContaining('24.6K followers'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Follow company'), 300);
      await tester.tap(find.text('Follow company'));
      await tester.pump();
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Company followed'), findsOneWidget);
      await tester.pump(_latency);
      await _settleToast(tester);
    });

    testWidgets('sections without data are left out', (tester) async {
      await _pump(tester, '/messages/scout/companies/kora-studios');

      expect(find.text('Creator rating'), findsNothing);
      expect(find.text('What creators say'), findsNothing);
      await tester.scrollUntilVisible(find.text('Open roles'), 300);
    });

    testWidgets('Message opens a new message to the company', (tester) async {
      final router = await _pump(
        tester,
        '/messages/scout/companies/afrowave-records',
      );

      await tester.scrollUntilVisible(find.text('Message Afrowave'), 300);
      await tester.tap(find.text('Message Afrowave'));
      await _settle(tester);
      expect(_location(router), '/messages/new?to=afrowave-records');
    });
  });

  group('Scout request', () {
    testWidgets('Decline toasts and leaves it read-only', (tester) async {
      await _pump(tester, '/scout/requests/sr-gbedu');

      expect(find.text('+200 Stars · company interest'), findsOneWidget);
      await tester.tap(find.text('Decline'));
      await tester.pump();
      expect(find.text('Request declined'), findsOneWidget);
      expect(find.text('You declined this request'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      await tester.pump(_latency);
      await _settleToast(tester);
    });

    testWidgets('Accept opens the conversation', (tester) async {
      final router = await _pump(tester, '/scout/requests/sr-gbedu');

      await tester.tap(find.text('Accept'));
      await tester.pump();
      expect(find.text('Accept'), findsOneWidget);
      await tester.pump(_latency);
      await _settle(tester);
      expect(_location(router), '/chat/c-afrowave');

      await _pop(tester, router);
      expect(find.text('Open conversation'), findsOneWidget);
    });

    testWidgets('Ask opens the conversation and keeps it pending', (
      tester,
    ) async {
      final router = await _pump(tester, '/scout/requests/sr-gbedu');

      await tester.tap(find.text('Ask'));
      await tester.pump(_latency);
      await _settle(tester);
      expect(_location(router), '/chat/c-afrowave');
      await _pop(tester, router);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('report toasts; company and attachment use the mirrors', (
      tester,
    ) async {
      final router = await _pump(tester, '/scout/requests/sr-gbedu');

      await tester.tap(find.byTooltip('Report'));
      await tester.pump();
      expect(
        find.text('Reported · our team will review this request'),
        findsOneWidget,
      );
      await tester.pump(_latency);
      await _settleToast(tester);

      await tester.tap(find.text('Afrowave Records').first);
      await _settle(tester);
      expect(_location(router), '/scout/companies/afrowave-records');
      await _pop(tester, router);

      await tester.scrollUntilVisible(find.text('Gbedu_brief.pdf'), 200);
      await tester.ensureVisible(find.text('Gbedu_brief.pdf'));
      await _settle(tester);
      await tester.tap(find.text('Gbedu_brief.pdf'));
      await _settle(tester);
      expect(_location(router), '/attachments/att-gbedu-brief');
    });
  });

  testWidgets('Requests list badges new ones and opens them', (tester) async {
    final router = await _pump(tester, '/messages/requests');

    expect(find.text('New'), findsOneWidget);
    expect(find.text('2d'), findsOneWidget);
    await tester.tap(find.text('Afrowave Records'));
    await _settle(tester);
    expect(_location(router), '/scout/requests/sr-gbedu');
  });
}
