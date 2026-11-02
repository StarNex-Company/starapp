import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/features/messages/data/models/attachment_preview.dart';
import 'package:starapp/features/messages/data/models/conversation.dart';
import 'package:starapp/features/messages/data/models/direct_conversation.dart';
import 'package:starapp/features/messages/data/models/inbox.dart';
import 'package:starapp/features/messages/data/models/message.dart';
import 'package:starapp/features/messages/data/models/offer.dart';
import 'package:starapp/features/messages/data/models/participant.dart';
import 'package:starapp/features/messages/data/repositories/mock_messages_repository.dart';

void main() {
  test('the mock inbox parses and covers every designed state', () async {
    final repo = MockMessagesRepository();
    final summary = await repo.getInboxSummary();
    final rows = (await repo.listConversations()).items;

    expect(summary.pendingScoutRequests, 2, reason: 'Requests banner');
    expect(summary.requestPreview.map((c) => c.name), [
      'Afrowave Records',
      'Kora Studios',
    ]);
    expect(summary.totalUnread, greaterThan(0), reason: 'tab unread dot');
    expect(rows.any((r) => r.unreadCount > 0), isTrue, reason: 'unread row');
    expect(rows.any((r) => r.isMuted), isTrue, reason: 'muted row');
    expect(
      rows.any((r) => r.kind == ConversationKind.direct && !r.isMuted),
      isTrue,
      reason: 'peer thread',
    );
    final system = rows.singleWhere((r) => r.kind == ConversationKind.system);
    expect(system.deepLink, AppRoutes.moderationPaused);
    expect(system.counterpart.kind, ParticipantKind.system);

    final scout = rows.singleWhere((r) => r.kind == ConversationKind.scout);
    final conversation = await repo.getConversation(scout.id);
    expect(conversation.counterpart.displayName, 'Afrowave Records');
    expect(conversation.proposal?.status, OfferStatus.pending);
    expect(conversation.scoutRequestId, isNotNull);

    final messages = (await repo.listMessages(scout.id)).items;
    expect(
      messages.map((m) => m.sentAt).toList(),
      [...messages.map((m) => m.sentAt)]..sort((a, b) => b.compareTo(a)),
      reason: 'newest first',
    );
    final offer = messages.singleWhere((m) => m.type == MessageType.offer);
    expect(offer.offer!.status, OfferStatus.pending);
    expect(offer.offer!.dayCount, 3);
    final brief = offer.offer!.attachments.single;
    expect(brief.kind, AttachmentKind.document);
    expect(brief.extension, 'PDF');
    expect(
      messages.any((m) => m.status == MessageStatus.seen && m.isMine),
      isTrue,
    );
    expect(
      messages.any((m) => m.status == MessageStatus.delivered && m.isMine),
      isTrue,
    );

    final preview = await repo.getAttachment(brief.id);
    expect(preview.ownerName, 'Afrowave Records');
    expect(preview.sections.map((s) => s.heading), [
      'Concept',
      'Shoot dates',
      'Fee',
      'Usage',
    ]);

    expect(await repo.suggestedRecipients(), hasLength(3));
  });

  test('every model round-trips through toJson', () async {
    final repo = MockMessagesRepository();
    final summary = await repo.getInboxSummary();
    expect(InboxSummary.fromJson(summary.toJson()).toJson(), summary.toJson());

    for (final row in (await repo.listConversations()).items) {
      expect(ConversationSummary.fromJson(row.toJson()).toJson(), row.toJson());
      final c = await repo.getConversation(row.id);
      expect(Conversation.fromJson(c.toJson()).toJson(), c.toJson());
      for (final m in (await repo.listMessages(row.id)).items) {
        expect(Message.fromJson(m.toJson()).toJson(), m.toJson());
      }
    }

    final preview = await repo.getAttachment('att-gbedu-brief');
    expect(
      AttachmentPreview.fromJson(preview.toJson()).toJson(),
      preview.toJson(),
    );
    for (final p in await repo.suggestedRecipients()) {
      expect(Participant.fromJson(p.toJson()).toJson(), p.toJson());
    }

    final countered = await repo.counterOffer(
      'offer-gbedu',
      const Money(110000000, Currency.ngn),
      'Covers two rehearsal days.',
    );
    expect(Offer.fromJson(countered.toJson()).toJson(), countered.toJson());
    expect(countered.lastCounter?.note, 'Covers two rehearsal days.');
  });

  test('unknown values and missing fields fall back', () {
    final m = Message.fromJson({
      'id': 'x',
      'conversationId': 'c',
      'type': 'sticker',
      'status': 'beamed',
    });
    expect(m.type, MessageType.text);
    expect(m.status, MessageStatus.sent);
    expect(m.isMine, isFalse);

    final p = Participant.fromJson({
      'id': 'p',
      'displayName': 'Lagos Film Collective',
      'kind': 'robot',
    });
    expect(p.kind, ParticipantKind.creator);
    expect(p.initials, 'LF');
    expect(p.shortName, 'Lagos');
  });

  test('direct conversation results parse both outcomes', () {
    final opened = DirectConversationResult.fromJson({
      'status': 'opened',
      'conversationId': 'c-1',
    });
    expect(opened.status, DirectConversationStatus.opened);
    expect(opened.conversationId, 'c-1');

    final request = DirectConversationResult.fromJson({
      'status': 'messageRequestSent',
    });
    expect(request.status, DirectConversationStatus.messageRequestSent);
    expect(
      DirectConversationResult.fromJson(request.toJson()).status,
      DirectConversationStatus.messageRequestSent,
    );
  });

  test(
    'the mock opens known people and sends a request to anyone else',
    () async {
      final repo = MockMessagesRepository();

      final existing = await repo.getOrCreateDirectConversation('emmanuel-f');
      expect(existing.conversationId, 'c-emmanuel');

      final created = await repo.getOrCreateDirectConversation('tunde-beats');
      expect(created.status, DirectConversationStatus.opened);
      expect(
        (await repo.listConversations()).items.map((c) => c.id),
        contains(created.conversationId),
      );

      final stranger = await repo.getOrCreateDirectConversation('chidi-eze');
      expect(stranger.status, DirectConversationStatus.messageRequestSent);
    },
  );
}
