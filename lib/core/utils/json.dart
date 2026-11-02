/// Helpers for hand-written `fromJson` factories. They are deliberately
/// tolerant: a missing list is empty, an unknown enum value falls back, so a
/// backend adding fields or enum cases never crashes the app.
library;

typedef Json = Map<String, dynamic>;

/// A list of objects; null or a non-list reads as empty.
List<T> readList<T>(Object? value, T Function(Json json) fromJson) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map) fromJson(Map<String, dynamic>.from(item)),
  ];
}

/// A list of strings; null reads as empty.
List<String> readStrings(Object? value) =>
    value is List ? [for (final v in value) '$v'] : const [];

/// ISO-8601 → local [DateTime]; null when absent or malformed.
DateTime? readDate(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

/// Integers that may arrive as `12`, `12.0` or `"12"`.
int readInt(Object? value, [int fallback = 0]) => switch (value) {
  final int v => v,
  final num v => v.round(),
  final String v => int.tryParse(v) ?? fallback,
  _ => fallback,
};

double readDouble(Object? value, [double fallback = 0]) => switch (value) {
  final num v => v.toDouble(),
  final String v => double.tryParse(v) ?? fallback,
  _ => fallback,
};

/// An enum by its Dart name (`"risingNova"`); unknown values give [fallback].
T readEnum<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

/// Same, but null when absent or unknown.
T? readEnumOrNull<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
