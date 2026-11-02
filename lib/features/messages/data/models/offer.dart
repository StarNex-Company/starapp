import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';

enum OfferStatus { pending, countered, accepted, declined, expired, withdrawn }

/// A company's paid offer inside a Scout thread (`POST /offers/{id}/accept`,
/// `POST /offers/{id}/counter`).
class Offer {
  const Offer({
    required this.id,
    required this.role,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.usage,
    required this.expiresAt,
    required this.status,
    this.attachments = const [],
    this.lastCounter,
  });

  factory Offer.fromJson(Json json) => Offer(
    id: json['id'] as String,
    role: json['role'] as String? ?? '',
    amount: Money.fromJson(json['amount'] as Json),
    startDate: readDate(json['startDate']) ?? DateTime.now(),
    endDate: readDate(json['endDate']) ?? DateTime.now(),
    usage: json['usage'] as String? ?? '',
    expiresAt: readDate(json['expiresAt']) ?? DateTime.now(),
    status: readEnum(OfferStatus.values, json['status'], OfferStatus.pending),
    attachments: readList(json['attachments'], Attachment.fromJson),
    lastCounter: json['lastCounter'] == null
        ? null
        : CounterOffer.fromJson(json['lastCounter'] as Json),
  );

  final String id;

  /// e.g. "Featured dancer".
  final String role;
  final Money amount;

  /// First and last shoot day.
  final DateTime startDate;
  final DateTime endDate;

  /// e.g. "Music video + socials".
  final String usage;
  final DateTime expiresAt;
  final OfferStatus status;

  /// The brief and any other files sent with the offer.
  final List<Attachment> attachments;

  /// The creator's latest counter, once they've sent one.
  final CounterOffer? lastCounter;

  /// Shoot days, counting both ends.
  int get dayCount => endDate.difference(startDate).inDays + 1;

  Json toJson() => {
    'id': id,
    'role': role,
    'amount': amount.toJson(),
    'startDate': startDate.toUtc().toIso8601String(),
    'endDate': endDate.toUtc().toIso8601String(),
    'usage': usage,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'status': status.name,
    'attachments': [for (final a in attachments) a.toJson()],
    'lastCounter': lastCounter?.toJson(),
  };

  Offer copyWith({OfferStatus? status, CounterOffer? lastCounter}) => Offer(
    id: id,
    role: role,
    amount: amount,
    startDate: startDate,
    endDate: endDate,
    usage: usage,
    expiresAt: expiresAt,
    status: status ?? this.status,
    attachments: attachments,
    lastCounter: lastCounter ?? this.lastCounter,
  );
}

/// The creator's counter to an [Offer].
class CounterOffer {
  const CounterOffer({
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  factory CounterOffer.fromJson(Json json) => CounterOffer(
    amount: Money.fromJson(json['amount'] as Json),
    note: json['note'] as String? ?? '',
    createdAt: readDate(json['createdAt']) ?? DateTime.now(),
  );

  final Money amount;
  final String note;
  final DateTime createdAt;

  Json toJson() => {
    'amount': amount.toJson(),
    'note': note,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}
