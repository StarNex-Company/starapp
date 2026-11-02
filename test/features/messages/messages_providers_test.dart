import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/messages/data/models/message.dart';
import 'package:starapp/features/messages/data/models/offer.dart';
import 'package:starapp/features/messages/data/provider/messages_providers.dart';
import 'package:starapp/features/messages/data/repositories/messages_repository.dart';
import 'package:starapp/features/messages/data/repositories/mock_messages_repository.dart';

/// The mock inbox, with switchable failures.
class _FlakyRepository extends MockMessagesRepository {
  bool failSends = false;
  bool failOffers = false;

  @override
  Future<Message> sendMessage(
    String conversationId,
    String text, {
    required String clientId,
  }) async {
    if (failSends) throw const NetworkException();
    return super.sendMessage(conversationId, text, clientId: clientId);
  }

  @override
  Future<Offer> acceptOffer(String offerId) async {
    if (failOffers) throw const NetworkException();
    return super.acceptOffer(offerId);
  }
}

void main() {
  late _FlakyRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = _FlakyRepository();
    container = ProviderContainer(
      overrides: [messagesRepositoryProvider.overrideWithValue(repo)],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  Future<ConversationThread> open(String id) async {
    container.listen(conversationProvider(id), (_, _) {});
    return container.read(conversationProvider(id).future);
  }

  ConversationThread thread(String id) =>
      container.read(conversationProvider(id)).requireValue;

  test('a send shows once, de-duplicated against the live echo', () async {
    await open('c-emmanuel');
    final before = thread('c-emmanuel').messages.length;

    await container
        .read(conversationProvider('c-emmanuel').notifier)
        .send('  Let us do it  ');

    final messages = thread('c-emmanuel').messages;
    expect(messages, hasLength(before + 1));
    expect(messages.first.text, 'Let us do it');
    expect(messages.first.status, MessageStatus.sent);
    expect(messages.first.id, isNot(messages.first.clientId));
  });

  test('a failed send stays, marked failed, and retry delivers it', () async {
    await open('c-emmanuel');
    final notifier = container.read(
      conversationProvider('c-emmanuel').notifier,
    );
    repo.failSends = true;

    await expectLater(
      notifier.send('Hello?'),
      throwsA(isA<NetworkException>()),
    );
    final failed = thread('c-emmanuel').messages.first;
    expect(failed.status, MessageStatus.failed);
    expect(failed.text, 'Hello?');

    repo.failSends = false;
    await notifier.retry(failed);
    final messages = thread('c-emmanuel').messages;
    expect(messages.where((m) => m.text == 'Hello?'), hasLength(1));
    expect(messages.first.status, MessageStatus.sent);
  });

  test('accepting an offer updates the card and the pinned proposal', () async {
    await open('c-afrowave');
    final notifier = container.read(
      conversationProvider('c-afrowave').notifier,
    );

    await notifier.acceptOffer('offer-gbedu');

    final t = thread('c-afrowave');
    expect(t.conversation.proposal?.status, OfferStatus.accepted);
    expect(
      t.messages.singleWhere((m) => m.offer != null).offer!.status,
      OfferStatus.accepted,
    );
  });

  test('a rejected accept rolls back and rethrows', () async {
    await open('c-afrowave');
    final notifier = container.read(
      conversationProvider('c-afrowave').notifier,
    );
    repo.failOffers = true;

    await expectLater(
      notifier.acceptOffer('offer-gbedu'),
      throwsA(isA<NetworkException>()),
    );
    expect(
      thread('c-afrowave').conversation.proposal?.status,
      OfferStatus.pending,
    );
  });

  test('countering records the counter on the offer', () async {
    await open('c-afrowave');
    await container
        .read(conversationProvider('c-afrowave').notifier)
        .counterOffer('offer-gbedu', Money.major(1100000, Currency.ngn), 'Hi');

    final offer = thread(
      'c-afrowave',
    ).messages.singleWhere((m) => m.offer != null).offer!;
    expect(offer.status, OfferStatus.countered);
    expect(offer.lastCounter?.amount, Money.major(1100000, Currency.ngn));
  });

  test('opening a thread marks it read and the inbox follows', () async {
    container.listen(inboxSummaryProvider, (_, _) {});
    container.listen(conversationsProvider, (_, _) {});
    final before = await container.read(inboxSummaryProvider.future);
    expect(before.totalUnread, 2);

    await open('c-afrowave');
    await pumpEventQueue();

    expect(container.read(inboxSummaryProvider).requireValue.totalUnread, 0);
    final rows = container.read(conversationsProvider).requireValue;
    expect(rows.singleWhere((r) => r.id == 'c-afrowave').unreadCount, 0);
  });

  test('search filters the inbox, and an empty query restores it', () async {
    container.listen(conversationsProvider, (_, _) {});
    final all = await container.read(conversationsProvider.future);

    container.read(conversationQueryProvider.notifier).set('ayeni');
    final found = await container.read(conversationsProvider.future);
    expect(found.map((c) => c.counterpart.displayName), ['Ayeni Micheal']);

    container.read(conversationQueryProvider.notifier).set('zzz');
    expect(await container.read(conversationsProvider.future), isEmpty);

    container.read(conversationQueryProvider.notifier).set('');
    expect(
      await container.read(conversationsProvider.future),
      hasLength(all.length),
    );
  });

  test('the repository provider is the mock by default', () {
    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    expect(
      fresh.read(messagesRepositoryProvider),
      isA<MessagesRepository>().having(
        (r) => r is MockMessagesRepository,
        'mock',
        isTrue,
      ),
    );
  });
}
