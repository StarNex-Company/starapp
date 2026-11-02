import 'dart:math';

import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/formatters.dart';

/// The amount typed on the Withdraw keypad, kept as text so it converts to
/// minor units exactly (no floating point): "1240500", "250.5", "0.".
class AmountInput {
  const AmountInput([this.text = '']);

  /// From an exact amount, e.g. a 25% chip.
  factory AmountInput.fromMoney(Money money) {
    final whole = money.amountMinor ~/ 100;
    final fraction = money.amountMinor % 100;
    return AmountInput(
      fraction == 0
          ? '$whole'
          : '$whole.${fraction.toString().padLeft(2, '0')}',
    );
  }

  /// Up to ₦9,999,999,999.99.
  static const maxWholeDigits = 10;

  final String text;

  bool get isEmpty => text.isEmpty;

  /// Appends a digit or the decimal point; returns this when the key can't
  /// apply (third decimal, second point, too many digits).
  AmountInput press(String key) {
    final dot = text.indexOf('.');
    if (key == '.') {
      if (dot >= 0) return this;
      return AmountInput(text.isEmpty ? '0.' : '$text.');
    }
    if (dot >= 0) {
      return text.length - dot > 2 ? this : AmountInput('$text$key');
    }
    if (text == '0') return AmountInput(key);
    if (text.length >= maxWholeDigits) return this;
    return AmountInput('$text$key');
  }

  AmountInput backspace() =>
      text.isEmpty ? this : AmountInput(text.substring(0, text.length - 1));

  /// The exact amount in [currency]'s minor units.
  Money toMoney(Currency currency) {
    if (text.isEmpty) return Money(0, currency);
    final parts = text.split('.');
    final whole = int.parse(parts.first.isEmpty ? '0' : parts.first);
    final fraction = parts.length > 1 ? parts[1].padRight(2, '0') : '00';
    return Money(whole * 100 + int.parse(fraction), currency);
  }

  /// As typed, grouped: "₦500,000", "₦1,250.5", "₦0".
  String display(Currency currency) {
    final symbol = currencySymbol(currency.code);
    final parts = text.split('.');
    final whole = int.tryParse(parts.first) ?? 0;
    final fraction = parts.length > 1 ? '.${parts[1]}' : '';
    return '$symbol${formatGrouped(whole)}$fraction';
  }

  @override
  bool operator ==(Object other) => other is AmountInput && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

/// A random version-4 UUID, used once per withdrawal so the server can
/// recognise a retry of the same request.
String newIdempotencyKey([Random? random]) {
  final rng = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')];
  return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-'
      '${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-'
      '${hex.sublist(10).join()}';
}
