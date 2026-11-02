import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/network/token_store.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/core/session/data/repositories/mock_session_repository.dart';
import 'package:starapp/features/profile/presentation/pages/my_profile_page.dart';
import 'package:starapp/features/profile/presentation/pages/shortcuts_page.dart';

Future<void> _pump(
  WidgetTester tester,
  String location, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const Scaffold(body: Text('Welcome page')),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, _) => const MyProfilePage(),
        routes: [
          GoRoute(path: 'shortcuts', builder: (_, _) => const ShortcutsPage()),
          GoRoute(
            path: 'wallet',
            builder: (_, _) => const Scaffold(body: Text('Wallet page')),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore('token')),
        ...overrides,
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _confirmLogOut(WidgetTester tester) async {
  await tester.tap(find.byTooltip('More'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Log out'));
  await tester.pumpAndSettle();
  expect(find.text('Log out of Star App?'), findsOneWidget);
  await tester.tap(find.text('Log out'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the Wallet shortcut opens the wallet', (tester) async {
    await _pump(tester, AppRoutes.profileShortcuts);

    expect(find.text('₦1,240,500 available'), findsOneWidget);
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Wallet page'), findsOneWidget);
  });

  testWidgets('Log out confirms, signs out and returns to welcome', (
    tester,
  ) async {
    await _pump(tester, AppRoutes.profile);
    await _confirmLogOut(tester);

    expect(find.text('Welcome page'), findsOneWidget);
  });

  testWidgets('a failed log out stays put and says why', (tester) async {
    await _pump(
      tester,
      AppRoutes.profile,
      overrides: [
        sessionRepositoryProvider.overrideWithValue(_OfflineSession()),
      ],
    );
    await _confirmLogOut(tester);

    expect(find.byType(MyProfilePage), findsOneWidget);
    expect(find.text(const NetworkException().message), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}

class _OfflineSession extends MockSessionRepository {
  @override
  Future<void> signOut() async => throw const NetworkException();
}
