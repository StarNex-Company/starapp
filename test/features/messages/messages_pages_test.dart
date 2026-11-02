import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/messages/data/provider/messages_providers.dart';
import 'package:starapp/features/messages/data/repositories/mock_messages_repository.dart';
import 'package:starapp/features/messages/presentation/pages/attachment_viewer_page.dart';
import 'package:starapp/features/messages/presentation/pages/conversation_page.dart';
import 'package:starapp/features/messages/presentation/pages/messages_page.dart';
import 'package:starapp/features/messages/presentation/pages/new_message_page.dart';
import 'package:starapp/features/messages/presentation/widgets/inbox_widgets.dart';

/// Pumps [page] at `/` under a router whose other destinations just print
/// the location they were opened with. Uses the default test font, which
/// surfaces overflow that large accessibility text would cause.
Future<GoRouter> _pump(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 62, bottom: 34);
  addTearDown(tester.view.reset);

  Widget stub(BuildContext _, GoRouterState s) =>
      Scaffold(body: Text('route:${s.uri}'));
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => page),
      GoRoute(
        path: AppRoutes.newMessage,
        builder: (_, s) =>
            NewMessagePage(toUserId: s.uri.queryParameters['to']),
      ),
      for (final path in [
        '/chat/:id',
        AppRoutes.scout,
        AppRoutes.messageRequests,
        AppRoutes.moderationPaused,
        AppRoutes.messages,
        '/scout/requests/:id',
        '/scout/companies/:id',
        '/attachments/:id',
        '/creator/:id',
      ])
        GoRoute(path: path, builder: stub),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        messagesRepositoryProvider.overrideWith(
          (_) => MockMessagesRepository(),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return router;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Lets any toast's timer run out so the test ends cleanly.
Future<void> _clearToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 300));
}

String _location(GoRouter router) => router.state.uri.toString();

void main() {
  group('inbox', () {
    testWidgets('shows the designed rows, banner and counts', (tester) async {
      await _pump(tester, const MessagesPage());

      expect(find.text('Messages'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing, reason: 'tab root');
      expect(find.text('2 new Scout Requests'), findsOneWidget);
      expect(find.text('Afrowave Records and Kora Studios'), findsOneWidget);
      expect(find.byType(ConversationRow), findsNWidgets(4));
      expect(find.bySemanticsLabel(RegExp('2 unread')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Muted')), findsOneWidget);
      expect(find.text('2m'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('header, segments, banner and rows navigate', (tester) async {
      final router = await _pump(tester, const MessagesPage());

      Future<void> expectOpens(Finder target, String location) async {
        await tester.tap(target);
        await _settle(tester);
        expect(_location(router), location);
        router.pop();
        await _settle(tester);
      }

      await expectOpens(find.byTooltip('New message'), AppRoutes.newMessage);
      await expectOpens(find.text('Scout'), AppRoutes.scout);
      await expectOpens(find.text('Requests'), AppRoutes.messageRequests);
      await expectOpens(
        find.text('2 new Scout Requests'),
        AppRoutes.messageRequests,
      );
      await expectOpens(
        find.text('Afrowave Records'),
        AppRoutes.conversation('c-afrowave'),
      );
      await expectOpens(find.text('Star App Team'), AppRoutes.moderationPaused);
    });

    testWidgets('search filters in place, with a no-results state', (
      tester,
    ) async {
      await _pump(tester, const MessagesPage());

      await tester.enterText(find.byType(TextField), 'ayeni');
      await _settle(tester);
      expect(find.byType(ConversationRow), findsOneWidget);
      expect(find.text('Ayeni Micheal'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'nobody');
      await _settle(tester);
      expect(find.byType(ConversationRow), findsNothing);
      expect(find.textContaining('No conversations match'), findsOneWidget);
    });
  });

  group('conversation', () {
    testWidgets('scout thread: header, pinned proposal and offer card', (
      tester,
    ) async {
      final router = await _pump(
        tester,
        const ConversationPage(conversationId: 'c-afrowave'),
      );

      expect(find.text('Afrowave Records'), findsOneWidget);
      expect(find.text('Verified company · Active now'), findsOneWidget);
      expect(find.text('Pending your response'), findsOneWidget);
      expect(find.text('Accept offer'), findsOneWidget);
      expect(find.text('Gbedu_brief.pdf'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('View'));
      await _settle(tester);
      expect(_location(router), AppRoutes.scoutRequest('sr-gbedu'));
      router.pop();
      await _settle(tester);

      // Full screen, so attachments open through the top-level mirror.
      await tester.tap(find.text('Gbedu_brief.pdf'));
      await _settle(tester);
      expect(_location(router), '/attachments/att-gbedu-brief');
    });

    testWidgets('send is disabled until there is text', (tester) async {
      await _pump(tester, const ConversationPage(conversationId: 'c-emmanuel'));

      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();
      expect(find.text('Hey there'), findsNothing);

      await tester.enterText(find.byType(TextField), 'Hey there');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await _settle(tester);
      expect(find.text('Hey there'), findsOneWidget);
      expect(find.textContaining('· Sent'), findsOneWidget);
    });

    testWidgets('accepting shows the toast and hides the actions', (
      tester,
    ) async {
      await _pump(tester, const ConversationPage(conversationId: 'c-afrowave'));

      await tester.tap(find.text('Accept offer'));
      await _settle(tester);
      expect(
        find.text('Offer accepted · contract sent to your inbox'),
        findsOneWidget,
      );
      expect(find.text('Accept offer'), findsNothing);
      expect(find.text('Counter'), findsNothing);
      expect(find.text('Offer accepted'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget, reason: 'pinned bar');
      await _clearToasts(tester);
    });

    testWidgets('a counter offer is sent from the sheet', (tester) async {
      await _pump(tester, const ConversationPage(conversationId: 'c-afrowave'));

      await tester.tap(find.text('Counter'));
      await _settle(tester);
      expect(find.text('Counter offer'), findsOneWidget);
      expect(find.text('NOTE TO AFROWAVE'), findsOneWidget);

      final fields = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.first, '1100000');
      await tester.enterText(fields.at(1), 'Covers two rehearsal days.');
      await tester.pump();
      expect(find.text('1,100,000'), findsOneWidget);

      await tester.tap(find.text('Send counter offer'));
      await _settle(tester);
      expect(find.text('Counter offer sent to Afrowave'), findsOneWidget);
      expect(find.text('You countered · ₦1,100,000'), findsOneWidget);
      await _clearToasts(tester);
    });

    testWidgets('menu: company profile, mute and report', (tester) async {
      final router = await _pump(
        tester,
        const ConversationPage(conversationId: 'c-afrowave'),
      );

      await tester.tap(find.byTooltip('More'));
      await _settle(tester);
      expect(find.text('Voice call'), findsNothing);
      expect(find.text('Video call'), findsNothing);
      await tester.tap(find.text('Mute conversation'));
      await _settle(tester);
      expect(find.text('Conversation muted'), findsOneWidget);
      await _clearToasts(tester);

      await tester.tap(find.byTooltip('More'));
      await _settle(tester);
      expect(find.text('Unmute conversation'), findsOneWidget);
      await tester.tap(find.text('Report'));
      await _settle(tester);
      expect(find.text('Thanks, our team will review this'), findsOneWidget);
      await _clearToasts(tester);

      await tester.tap(find.byTooltip('More'));
      await _settle(tester);
      await tester.tap(find.text('View company profile'));
      await _settle(tester);
      expect(_location(router), '/scout/companies/afrowave-records');
    });

    testWidgets('attach: files are coming soon, the passport is shared', (
      tester,
    ) async {
      await _pump(tester, const ConversationPage(conversationId: 'c-emmanuel'));

      await tester.tap(find.byTooltip('Attach'));
      await _settle(tester);
      await tester.tap(find.text('Document'));
      await _settle(tester);
      expect(find.text('Coming soon'), findsOneWidget);
      await _clearToasts(tester);

      await tester.tap(find.byTooltip('Attach'));
      await _settle(tester);
      await tester.tap(find.text('Talent Passport'));
      await _settle(tester);
      expect(find.text('Portfolio link'), findsOneWidget);
    });
  });

  group('new message', () {
    testWidgets('suggestions, search results and no results', (tester) async {
      await _pump(tester, const NewMessagePage());

      expect(find.text('Suggested'), findsOneWidget);
      expect(find.text('Tunde Beats'), findsOneWidget);
      expect(find.text('@amina_k · Dancer'), findsOneWidget);
      expect(find.text('Verified company'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'emman');
      await _settle(tester);
      expect(find.text('Suggested'), findsNothing);
      expect(find.text('Emmanuel F.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzz');
      await _settle(tester);
      expect(find.textContaining('No one matches'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Message opens the thread in place of this page', (
      tester,
    ) async {
      final router = await _pump(tester, const SizedBox());
      router.push(AppRoutes.newMessage);
      await _settle(tester);

      await tester.tap(find.bySemanticsLabel('Message Tunde Beats'));
      await _settle(tester);
      expect(_location(router), AppRoutes.conversation('c-tunde-beats'));
      router.pop();
      await _settle(tester);
      expect(_location(router), '/', reason: 'New message was replaced');
    });

    testWidgets('?to= someone who takes requests sends one and pops', (
      tester,
    ) async {
      final router = await _pump(tester, const SizedBox());
      router.push('${AppRoutes.newMessage}?to=chidi-eze');
      await _settle(tester);

      expect(find.text('Message request sent'), findsOneWidget);
      expect(_location(router), '/');
      await _clearToasts(tester);
    });

    testWidgets('?to= someone already in the inbox opens their thread', (
      tester,
    ) async {
      final router = await _pump(tester, const SizedBox());
      router.push('${AppRoutes.newMessage}?to=emmanuel-f');
      await _settle(tester);

      expect(_location(router), AppRoutes.conversation('c-emmanuel'));
    });
  });

  testWidgets('attachment viewer shows the brief; mock download confirms', (
    tester,
  ) async {
    await _pump(
      tester,
      const AttachmentViewerPage(attachmentId: 'att-gbedu-brief'),
    );

    expect(find.text('Gbedu_brief.pdf'), findsOneWidget);
    expect(find.text('Afrowave Records · 1.2 MB · 4 pages'), findsOneWidget);
    expect(find.text('Concept'), findsOneWidget);

    await tester.tap(find.text('Download PDF'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved to your files'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _clearToasts(tester);
  });
}
