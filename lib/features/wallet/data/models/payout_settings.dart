import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';

/// Payout preferences and tax details (`GET /payout-settings`).
class PayoutSettings {
  const PayoutSettings({
    required this.payoutCurrency,
    required this.autoMonthlyPayout,
    required this.taxThreshold,
    this.taxInfo,
    this.taxInfoRequired = false,
  });

  factory PayoutSettings.fromJson(Json json) => PayoutSettings(
    payoutCurrency: Currency.fromCode(json['payoutCurrency']),
    autoMonthlyPayout: json['autoMonthlyPayout'] as bool? ?? false,
    taxInfo: json['taxInfo'] == null
        ? null
        : TaxInfo.fromJson(json['taxInfo'] as Json),
    taxInfoRequired: json['taxInfoRequired'] as bool? ?? false,
    taxThreshold: Money.fromJson(json['taxThreshold'] as Json),
  );

  final Currency payoutCurrency;

  /// Withdraw the whole balance on the 1st of each month.
  final bool autoMonthlyPayout;

  /// Null until the user saves it.
  final TaxInfo? taxInfo;

  /// Whether this year's payouts have passed [taxThreshold] without
  /// [taxInfo] on file.
  final bool taxInfoRequired;

  /// Yearly payouts above this need tax details, e.g. ₦5,000,000.
  final Money taxThreshold;

  Json toJson() => {
    'payoutCurrency': payoutCurrency.code,
    'autoMonthlyPayout': autoMonthlyPayout,
    'taxInfo': taxInfo?.toJson(),
    'taxInfoRequired': taxInfoRequired,
    'taxThreshold': taxThreshold.toJson(),
  };

  PayoutSettings copyWith({
    Currency? payoutCurrency,
    bool? autoMonthlyPayout,
    TaxInfo? taxInfo,
    bool? taxInfoRequired,
  }) => PayoutSettings(
    payoutCurrency: payoutCurrency ?? this.payoutCurrency,
    autoMonthlyPayout: autoMonthlyPayout ?? this.autoMonthlyPayout,
    taxInfo: taxInfo ?? this.taxInfo,
    taxInfoRequired: taxInfoRequired ?? this.taxInfoRequired,
    taxThreshold: taxThreshold,
  );
}

/// `PUT /payout-settings/tax`.
class TaxInfo {
  const TaxInfo({
    required this.tin,
    required this.legalName,
    required this.countryCode,
  });

  factory TaxInfo.fromJson(Json json) => TaxInfo(
    tin: json['tin'] as String? ?? '',
    legalName: json['legalName'] as String? ?? '',
    countryCode: json['countryCode'] as String? ?? '',
  );

  /// Taxpayer identification number, digits and hyphens only.
  final String tin;
  final String legalName;

  /// ISO 3166-1 alpha-2, e.g. "NG".
  final String countryCode;

  Json toJson() => {
    'tin': tin,
    'legalName': legalName,
    'countryCode': countryCode,
  };
}
