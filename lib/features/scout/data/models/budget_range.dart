import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';

/// How an open call's budget is counted.
enum BudgetUnit { flat, perShow, perDay, perEpisode }

/// What an open call pays:
/// `{"min": {"amountMinor": …, "currency": "NGN"}, "max": {…} | null, "unit": "perShow"}`.
class BudgetRange {
  const BudgetRange({required this.min, this.max, this.unit = BudgetUnit.flat});

  factory BudgetRange.fromJson(Json json) => BudgetRange(
    min: Money.fromJson(json['min'] as Json),
    max: json['max'] == null ? null : Money.fromJson(json['max'] as Json),
    unit: readEnum(BudgetUnit.values, json['unit'], BudgetUnit.flat),
  );

  final Money min;

  /// Null for a fixed amount.
  final Money? max;
  final BudgetUnit unit;

  Json toJson() => {
    'min': min.toJson(),
    'max': max?.toJson(),
    'unit': unit.name,
  };
}
