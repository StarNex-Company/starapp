import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/moderation/data/models/moderation_case.dart';
import 'package:starapp/features/moderation/data/provider/moderation_providers.dart';
import 'package:starapp/features/moderation/data/repositories/mock_moderation_repository.dart';
import 'package:starapp/features/moderation/presentation/pages/appeal_page.dart';
import 'package:starapp/features/moderation/presentation/pages/appeal_submitted_page.dart';

/// Rejects every appeal the way the API does when fields are invalid.
class _RejectingRepository extends MockModerationRepository {
  _RejectingRepository();

  AppealForm? sent;

  @override
  Future<void> submitAppeal(String caseId, AppealForm form) async {
    sent = form;
    throw const ValidationException(
      'Please check the highlighted fields.',
      statusCode: 422,
      fieldErrors: {'details': 'Tell us a bit more (at least 20 characters).'},
    );
  }
}

Future<void> _pumpAppeal(
  WidgetTester tester,
  MockModerationRepository repository,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: AppRoutes.moderationAppeal,
    routes: [
      GoRoute(
        path: AppRoutes.moderationAppeal,
        builder: (_, _) => const AppealPage(),
      ),
      GoRoute(
        path: AppRoutes.moderationAppealSubmitted,
        builder: (_, state) => AppealSubmittedPage(
          caseId: state.uri.queryParameters['id'] ?? defaultModerationCaseId,
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [moderationRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  test('the case fixture parses and covers the designed state', () async {
    final c = await const MockModerationRepository().fetchCase('SA-48213');

    expect(c.id, 'SA-48213');
    expect(c.post.postedAt.isBefore(DateTime.now()), isTrue);
    expect(c.post.viewCount, 2100);
    expect(c.reason, isNotEmpty);
    expect(c.nextSteps, hasLength(3));
    expect(c.appealReasons, hasLength(3));
  });

  test(
    'toJson round-trips, and the appeal body is {reason, details}',
    () async {
      final c = await const MockModerationRepository().fetchCase('SA-48213');
      expect(ModerationCase.fromJson(c.toJson()).toJson(), c.toJson());

      expect(const AppealForm(reasonId: 'licensed', details: 'Mine').toJson(), {
        'reason': 'licensed',
        'details': 'Mine',
      });
    },
  );

  testWidgets('a rejected appeal shows the field error and stays put', (
    tester,
  ) async {
    final repository = _RejectingRepository();
    await _pumpAppeal(tester, repository);

    await tester.enterText(find.byType(TextField), 'Short');
    await tester.tap(find.text('Submit appeal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.sent?.reasonId, 'own-rights');
    expect(repository.sent?.details, 'Short');
    expect(
      find.text('Tell us a bit more (at least 20 characters).'),
      findsOneWidget,
    );
    expect(find.byType(AppealSubmittedPage), findsNothing);

    // Editing the field clears its error.
    await tester.enterText(find.byType(TextField), 'Short, now longer');
    await tester.pump();
    expect(
      find.text('Tell us a bit more (at least 20 characters).'),
      findsNothing,
    );
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('an accepted appeal opens Appeal Submitted for the case', (
    tester,
  ) async {
    await _pumpAppeal(tester, const MockModerationRepository());

    await tester.tap(find.text('Submit appeal'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AppealSubmittedPage), findsOneWidget);
    expect(find.text('Case #SA-48213'), findsOneWidget);
  });
}
