import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';

/// The Wallet screen in one call (`GET /wallet`).
class WalletSummary {
  const WalletSummary({
    required this.available,
    required this.updatedAt,
    required this.prizesTotal,
    required this.fanTipsTotal,
    required this.scoutDealsTotal,
    this.approxUsd,
    this.defaultPayoutMethod,
    this.recent = const [],
  });

  factory WalletSummary.fromJson(Json json) => WalletSummary(
    available: Money.fromJson(json['available'] as Json),
    approxUsd: json['approxUsd'] == null
        ? null
        : Money.fromJson(json['approxUsd'] as Json),
    updatedAt: readDate(json['updatedAt']) ?? DateTime.now(),
    prizesTotal: Money.fromJson(json['prizesTotal'] as Json),
    fanTipsTotal: Money.fromJson(json['fanTipsTotal'] as Json),
    scoutDealsTotal: Money.fromJson(json['scoutDealsTotal'] as Json),
    defaultPayoutMethod: json['defaultPayoutMethod'] == null
        ? null
        : PayoutMethod.fromJson(json['defaultPayoutMethod'] as Json),
    recent: readList(json['recent'], WalletTransaction.fromJson),
  );

  /// What can be withdrawn now.
  final Money available;

  /// [available] in US dollars, for reference; null when not quoted.
  final Money? approxUsd;
  final DateTime updatedAt;

  /// Lifetime earnings by source.
  final Money prizesTotal;
  final Money fanTipsTotal;
  final Money scoutDealsTotal;

  /// Null until the user adds a payout method.
  final PayoutMethod? defaultPayoutMethod;

  /// The latest few transactions, newest first.
  final List<WalletTransaction> recent;

  Json toJson() => {
    'available': available.toJson(),
    'approxUsd': approxUsd?.toJson(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'prizesTotal': prizesTotal.toJson(),
    'fanTipsTotal': fanTipsTotal.toJson(),
    'scoutDealsTotal': scoutDealsTotal.toJson(),
    'defaultPayoutMethod': defaultPayoutMethod?.toJson(),
    'recent': [for (final t in recent) t.toJson()],
  };
}
