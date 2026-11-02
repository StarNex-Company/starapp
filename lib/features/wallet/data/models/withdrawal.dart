import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';

/// What a withdrawal of [amount] would cost and when it would land
/// (`POST /wallet/withdrawals/quote`). [min] and [max] are the limits for
/// this user right now; [max] never exceeds the available balance.
class WithdrawalQuote {
  const WithdrawalQuote({
    required this.amount,
    required this.fee,
    required this.receive,
    required this.arrivalEstimate,
    required this.min,
    required this.max,
  });

  factory WithdrawalQuote.fromJson(Json json) => WithdrawalQuote(
    amount: Money.fromJson(json['amount'] as Json),
    fee: Money.fromJson(json['fee'] as Json),
    receive: Money.fromJson(json['receive'] as Json),
    arrivalEstimate: json['arrivalEstimate'] as String? ?? '',
    min: Money.fromJson(json['min'] as Json),
    max: Money.fromJson(json['max'] as Json),
  );

  final Money amount;
  final Money fee;

  /// What reaches the bank account: [amount] less [fee].
  final Money receive;

  /// Completes "Arrives …", e.g. "Within minutes", "In 1–2 business days".
  final String arrivalEstimate;
  final Money min;
  final Money max;

  Json toJson() => {
    'amount': amount.toJson(),
    'fee': fee.toJson(),
    'receive': receive.toJson(),
    'arrivalEstimate': arrivalEstimate,
    'min': min.toJson(),
    'max': max.toJson(),
  };
}

/// A withdrawal the server accepted (`POST /wallet/withdrawals`).
class Withdrawal {
  const Withdrawal({
    required this.id,
    required this.amount,
    required this.destination,
    required this.status,
    required this.reference,
    required this.createdAt,
  });

  factory Withdrawal.fromJson(Json json) => Withdrawal(
    id: json['id'] as String,
    amount: Money.fromJson(json['amount'] as Json),
    destination: PayoutMethod.fromJson(json['destination'] as Json),
    status: readEnum(
      TransactionStatus.values,
      json['status'],
      TransactionStatus.pending,
    ),
    reference: json['reference'] as String? ?? '',
    createdAt: readDate(json['createdAt']) ?? DateTime.now(),
  );

  final String id;
  final Money amount;
  final PayoutMethod destination;
  final TransactionStatus status;

  /// e.g. "SA-WD-77120".
  final String reference;
  final DateTime createdAt;

  Json toJson() => {
    'id': id,
    'amount': amount.toJson(),
    'destination': destination.toJson(),
    'status': status.name,
    'reference': reference,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}
