import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';

enum TransactionType {
  challengePrize,
  fanTips,
  scoutDeal,
  withdrawal,
  adjustment,
}

enum TransactionStatus {
  pending,
  processing,
  paid,
  completed,
  failed,
  reversed,
}

/// One movement in or out of the wallet (`GET /wallet/transactions`).
///
/// [amount] is always positive; [isCredit] gives the direction. The typed
/// fields below are filled for the matching [type] only.
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.isCredit,
    required this.amount,
    required this.status,
    required this.title,
    required this.createdAt,
    required this.reference,
    this.subtitle = '',
    this.challengeId,
    this.challengeName,
    this.rank,
    this.originalAmount,
    this.fxRate,
    this.fanCount,
    this.companyId,
    this.companyName,
    this.applicationId,
    this.payoutMethodId,
  });

  factory WalletTransaction.fromJson(Json json) => WalletTransaction(
    id: json['id'] as String,
    type: readEnum(
      TransactionType.values,
      json['type'],
      TransactionType.adjustment,
    ),
    isCredit: json['isCredit'] as bool? ?? false,
    amount: Money.fromJson(json['amount'] as Json),
    status: readEnum(
      TransactionStatus.values,
      json['status'],
      TransactionStatus.pending,
    ),
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    createdAt: readDate(json['createdAt']) ?? DateTime.now(),
    reference: json['reference'] as String? ?? '',
    challengeId: json['challengeId'] as String?,
    challengeName: json['challengeName'] as String?,
    rank: json['rank'] == null ? null : readInt(json['rank']),
    originalAmount: json['originalAmount'] == null
        ? null
        : Money.fromJson(json['originalAmount'] as Json),
    fxRate: json['fxRate'] == null ? null : readDouble(json['fxRate']),
    fanCount: json['fanCount'] == null ? null : readInt(json['fanCount']),
    companyId: json['companyId'] as String?,
    companyName: json['companyName'] as String?,
    applicationId: json['applicationId'] as String?,
    payoutMethodId: json['payoutMethodId'] as String?,
  );

  final String id;
  final TransactionType type;
  final bool isCredit;
  final Money amount;
  final TransactionStatus status;

  /// Server-rendered, e.g. "Challenge prize", "Withdrawal to GTBank".
  final String title;

  /// Server-rendered context without the date, e.g. "Afro-Dance Takeover ·
  /// Top 10" or "48 fans"; empty when there is none.
  final String subtitle;
  final DateTime createdAt;

  /// Shown to the user and support, e.g. "SA-PR-30218".
  final String reference;

  // challengePrize
  final String? challengeId;
  final String? challengeName;

  /// Final leaderboard position.
  final int? rank;

  /// The prize as announced when it was paid in another currency, e.g. $600
  /// converted to [amount] at [fxRate].
  final Money? originalAmount;

  /// Units of [amount]'s currency per unit of [originalAmount]'s, e.g. 1500.
  final double? fxRate;

  // fanTips
  final int? fanCount;

  // scoutDeal
  final String? companyId;
  final String? companyName;
  final String? applicationId;

  // withdrawal
  final String? payoutMethodId;

  /// Still on its way out: a withdrawal the bank hasn't confirmed.
  bool get isInFlight =>
      status == TransactionStatus.pending ||
      status == TransactionStatus.processing;

  Json toJson() => {
    'id': id,
    'type': type.name,
    'isCredit': isCredit,
    'amount': amount.toJson(),
    'status': status.name,
    'title': title,
    'subtitle': subtitle,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'reference': reference,
    'challengeId': challengeId,
    'challengeName': challengeName,
    'rank': rank,
    'originalAmount': originalAmount?.toJson(),
    'fxRate': fxRate,
    'fanCount': fanCount,
    'companyId': companyId,
    'companyName': companyName,
    'applicationId': applicationId,
    'payoutMethodId': payoutMethodId,
  };
}
