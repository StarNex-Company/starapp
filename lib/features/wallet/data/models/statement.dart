import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';

/// A monthly PDF statement (`GET /wallet/statements`).
class Statement {
  const Statement({
    required this.id,
    required this.year,
    required this.month,
    required this.closingBalance,
    required this.pdfUrl,
  });

  factory Statement.fromJson(Json json) => Statement(
    id: json['id'] as String,
    year: readInt(json['year']),
    month: readInt(json['month'], 1),
    closingBalance: Money.fromJson(json['closingBalance'] as Json),
    pdfUrl: json['pdfUrl'] as String? ?? '',
  );

  final String id;
  final int year;

  /// 1–12.
  final int month;
  final Money closingBalance;

  /// Opened in the browser or PDF viewer; may be short-lived and signed.
  final String pdfUrl;

  Json toJson() => {
    'id': id,
    'year': year,
    'month': month,
    'closingBalance': closingBalance.toJson(),
    'pdfUrl': pdfUrl,
  };
}
