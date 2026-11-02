import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/create/data/provider/create_providers.dart';
import 'package:starapp/features/create/data/repositories/mock_create_repository.dart';
import 'package:starapp/features/create/presentation/pages/camera_page.dart';
import 'package:starapp/features/create/presentation/pages/entry_submitted_page.dart';
import 'package:starapp/features/create/presentation/pages/preview_edit_page.dart';
import 'package:starapp/features/create/presentation/pages/submit_entry_page.dart';
import 'package:starapp/features/create/presentation/pages/uploading_page.dart';
import 'package:starapp/features/moderation/presentation/pages/appeal_page.dart';
import 'package:starapp/features/moderation/presentation/pages/appeal_submitted_page.dart';
import 'package:starapp/features/moderation/presentation/pages/content_paused_page.dart';

Widget _uploading = const UploadingPage(autoStart: false);

final _routes = <String, Widget Function()>{
  AppRoutes.home: () => const Scaffold(body: Text('home')),
  AppRoutes.createCamera: () => const CameraPage(),
  AppRoutes.createPreview: () => const PreviewEditPage(),
  AppRoutes.createSubmitEntry: () => const SubmitEntryPage(),
  AppRoutes.createUploading: () => _uploading,
  AppRoutes.createSubmitted: () => const EntrySubmittedPage(),
  AppRoutes.moderationPaused: () => const ContentPausedPage(),
  AppRoutes.moderationAppeal: () => const AppealPage(),
  AppRoutes.moderationAppealSubmitted: () => const AppealSubmittedPage(),
};

Future<void> _pumpAt(
  WidgetTester tester,
  String location, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 62, bottom: 34);
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: location,
    routes: [
      for (final MapEntry(:key, :value) in _routes.entries)
        GoRoute(path: key, builder: (_, _) => value()),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  // Let the mock repositories answer, then let success screens animate in;
  // the upload spinner never settles.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUp(() => _uploading = const UploadingPage(autoStart: false));

  for (final location in _routes.keys.skip(1)) {
    testWidgets('$location renders without layout errors', (tester) async {
      await _pumpAt(tester, location);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Preview Continue opens Submit Entry', (tester) async {
    await _pumpAt(tester, AppRoutes.createPreview);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SubmitEntryPage), findsOneWidget);
  });

  testWidgets('Submit Entry shows the draft edited on Preview', (tester) async {
    await _pumpAt(tester, AppRoutes.createPreview);

    await tester.ensureVisible(find.text('Dance'));
    await tester.tap(find.text('Dance'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('0:44 · Dance · Lagos'), findsOneWidget);
  });

  testWidgets('finished upload replaces itself with Entry Submitted', (
    tester,
  ) async {
    const step = Duration(milliseconds: 100);
    _uploading = const UploadingPage();
    await _pumpAt(
      tester,
      AppRoutes.createUploading,
      overrides: [
        createRepositoryProvider.overrideWithValue(
          const MockCreateRepository(
            upload: UploadSimulation(
              compressDuration: step,
              uploadDuration: step,
              processDuration: step,
              tick: Duration(milliseconds: 10),
            ),
          ),
        ),
      ],
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(EntrySubmittedPage), findsOneWidget);
    expect(find.byType(UploadingPage), findsNothing);
    // The upload's answer reaches the success screen.
    expect(find.text('+50 Stars · entry bonus'), findsOneWidget);
  });

  testWidgets('Content Paused leads to the appeal form', (tester) async {
    await _pumpAt(tester, AppRoutes.moderationPaused);

    await tester.tap(find.text('Submit an appeal'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AppealPage), findsOneWidget);
  });
}
