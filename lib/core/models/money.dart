import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/core/utils/json.dart';

enum Currency {
  ngn('NGN'),
  usd('USD'),
  ghs('GHS'),
  kes('KES'),
  zar('ZAR');

  const Currency(this.code);

  /// ISO 4217 code, as the API sends it.
  final String code;

  static Currency fromCode(Object? code, [Currency fallback = Currency.ngn]) {
    for (final c in values) {
      if (c.code == code) return c;
    }
    return fallback;
  }
}

/// An amount of money in minor units (kobo, cents), the only safe way to
/// carry money: `{"amountMinor": 124050000, "currency": "NGN"}`.
class Money implements Comparable<Money> {
  const Money(this.amountMinor, this.currency);

  const Money.zero([this.currency = Currency.ngn]) : amountMinor = 0;

  /// From major units, e.g. `Money.major(1240500, Currency.ngn)`.
  Money.major(num amount, this.currency) : amountMinor = (amount * 100).round();

  factory Money.fromJson(Json json) =>
      Money(readInt(json['amountMinor']), Currency.fromCode(json['currency']));

  final int amountMinor;
  final Currency currency;

  double get major => amountMinor / 100;
  bool get isZero => amountMinor == 0;

  Money operator +(Money other) {
    assert(other.currency == currency, 'Mixed currencies');
    return Money(amountMinor + other.amountMinor, currency);
  }

  Money operator -(Money other) {
    assert(other.currency == currency, 'Mixed currencies');
    return Money(amountMinor - other.amountMinor, currency);
  }

  Money operator *(num factor) =>
      Money((amountMinor * factor).round(), currency);

  /// "₦1,240,500"; pass [decimals] for "₦1,240,500.00".
  String format({bool decimals = false}) => formatMoney(
    amountMinor,
    currency: currency.code,
    fromMinorUnits: true,
    showDecimals: decimals,
  );

  Json toJson() => {'amountMinor': amountMinor, 'currency': currency.code};

  @override
  int compareTo(Money other) => amountMinor.compareTo(other.amountMinor);

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.amountMinor == amountMinor &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(amountMinor, currency);

  @override
  String toString() => format(decimals: true);
}
