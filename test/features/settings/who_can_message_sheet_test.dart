import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/features/settings/data/provider/settings_providers.dart';
import 'package:starapp/features/settings/data/repositories/mock_settings_repository.dart';
import 'package:starapp/features/settings/presentation/pages/privacy_security_page.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// Records privacy PATCHes, or rejects them.
class _Repository extends MockSettingsRepository {
  _Repository({this.reject = false});

  final bool reject;
  final sent = <Json>[];

  @override
  Future<void> updatePrivacySettings(Json changes) async {
    if (reject) throw const ValidationException('Not allowed right now.');
    sent.add(changes);
  }
}

Future<ProviderContainer> _pump(WidgetTester tester, _Repository repo) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const PrivacySecurityPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('Who can message me'));
  await tester.pumpAndSettle();
}

bool _selected(WidgetTester tester, String label) {
  final row = find.ancestor(of: find.text(label), matching: find.byType(Row));
  return tester
      .widget<StarRadioDot>(
        find.descendant(of: row.first, matching: find.byType(StarRadioDot)),
      )
      .selected;
}

void main() {
  testWidgets('the row shows the current choice and the sheet lists all four', (
    tester,
  ) async {
    await _pump(tester, _Repository());
    expect(find.text('Everyone'), findsOneWidget);

    await _openSheet(tester);

    expect(find.text('Who can message you?'), findsOneWidget);
    expect(find.text('Applies to new conversations only'), findsOneWidget);
    for (final label in [
      'People you follow',
      'Verified companies only',
      'No one',
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(_selected(tester, label), isFalse);
    }
    expect(find.text('Anyone on Star App'), findsOneWidget);
    expect(find.text('Scouts with a verified badge'), findsOneWidget);
    // "Everyone" is both the row's value and the selected option.
    expect(find.text('Everyone'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking an option saves it at once and closes the sheet', (
    tester,
  ) async {
    final repo = _Repository();
    final container = await _pump(tester, repo);

    await _openSheet(tester);
    await tester.tap(find.text('People you follow'));
    await tester.pumpAndSettle();

    expect(find.text('Who can message you?'), findsNothing);
    expect(find.text('Following'), findsOneWidget);
    expect(
      container.read(privacySettingsProvider).value?.whoCanMessage,
      WhoCanMessage.following,
    );
    expect(repo.sent, [
      {'whoCanMessage': 'following'},
    ]);
  });

  testWidgets('closing or re-picking the current option changes nothing', (
    tester,
  ) async {
    final repo = _Repository();
    await _pump(tester, repo);

    await _openSheet(tester);
    await tester.tap(find.text('Everyone').last);
    await tester.pumpAndSettle();
    expect(find.text('Who can message you?'), findsNothing);

    await _openSheet(tester);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Who can message you?'), findsNothing);
    expect(repo.sent, isEmpty);
  });

  testWidgets('a rejected change rolls back and says why', (tester) async {
    final container = await _pump(tester, _Repository(reject: true));

    await _openSheet(tester);
    await tester.tap(find.text('No one'));
    await tester.pumpAndSettle();

    expect(
      container.read(privacySettingsProvider).value?.whoCanMessage,
      WhoCanMessage.everyone,
    );
    expect(find.text('Not allowed right now.'), findsOneWidget);
    expect(find.text('Everyone'), findsOneWidget);
    // Let the toast time out.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
