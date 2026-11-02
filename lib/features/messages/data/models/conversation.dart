import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/messages/data/models/offer.dart';
import 'package:starapp/features/messages/data/models/participant.dart';

/// [direct]: two creators. [scout]: a company hiring through Scout, with an
/// offer. [system]: announcements from the Star App team.
enum ConversationKind { direct, scout, system }

/// A thread's header data (`GET /conversations/{id}`).
class Conversation {
  const Conversation({
    required this.id,
    required this.kind,
    required this.counterpart,
    this.isOnline = false,
    this.lastActiveAt,
    this.canSend = true,
    this.isMuted = false,
    this.proposal,
    this.scoutRequestId,
  });

  factory Conversation.fromJson(Json json) => Conversation(
    id: json['id'] as String,
    kind: readEnum(
      ConversationKind.values,
      json['kind'],
      ConversationKind.direct,
    ),
    counterpart: Participant.fromJson(json['counterpart'] as Json),
    isOnline: json['isOnline'] as bool? ?? false,
    lastActiveAt: readDate(json['lastActiveAt']),
    canSend: json['canSend'] as bool? ?? true,
    isMuted: json['isMuted'] as bool? ?? false,
    proposal: json['proposal'] == null
        ? null
        : PinnedProposal.fromJson(json['proposal'] as Json),
    scoutRequestId: json['scoutRequestId'] as String?,
  );

  final String id;
  final ConversationKind kind;
  final Participant counterpart;
  final bool isOnline;

  /// When the counterpart was last seen, while not [isOnline].
  final DateTime? lastActiveAt;

  /// False where the user can only read, e.g. the system thread.
  final bool canSend;
  final bool isMuted;

  /// Scout threads: the offer pinned above the messages.
  final PinnedProposal? proposal;

  /// Scout threads: the request the conversation started from.
  final String? scoutRequestId;

  Json toJson() => {
    'id': id,
    'kind': kind.name,
    'counterpart': counterpart.toJson(),
    'isOnline': isOnline,
    'lastActiveAt': lastActiveAt?.toUtc().toIso8601String(),
    'canSend': canSend,
    'isMuted': isMuted,
    'proposal': proposal?.toJson(),
    'scoutRequestId': scoutRequestId,
  };

  Conversation copyWith({bool? isMuted, PinnedProposal? proposal}) =>
      Conversation(
        id: id,
        kind: kind,
        counterpart: counterpart,
        isOnline: isOnline,
        lastActiveAt: lastActiveAt,
        canSend: canSend,
        isMuted: isMuted ?? this.isMuted,
        proposal: proposal ?? this.proposal,
        scoutRequestId: scoutRequestId,
      );
}

/// The offer a Scout thread pins above its messages.
class PinnedProposal {
  const PinnedProposal({
    required this.offerId,
    required this.title,
    required this.amount,
    required this.status,
  });

  factory PinnedProposal.fromJson(Json json) => PinnedProposal(
    offerId: json['offerId'] as String,
    title: json['title'] as String? ?? '',
    amount: Money.fromJson(json['amount'] as Json),
    status: readEnum(OfferStatus.values, json['status'], OfferStatus.pending),
  );

  final String offerId;

  /// e.g. "Featured Dancer".
  final String title;
  final Money amount;
  final OfferStatus status;

  Json toJson() => {
    'offerId': offerId,
    'title': title,
    'amount': amount.toJson(),
    'status': status.name,
  };

  PinnedProposal copyWith({OfferStatus? status}) => PinnedProposal(
    offerId: offerId,
    title: title,
    amount: amount,
    status: status ?? this.status,
  );
}
