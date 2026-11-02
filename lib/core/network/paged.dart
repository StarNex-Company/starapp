import 'package:starapp/core/utils/json.dart';

/// One page of a cursor-paginated list:
/// `{"items": [...], "nextCursor": "abc" | null}`.
class Paged<T> {
  const Paged({required this.items, this.nextCursor});

  factory Paged.fromJson(Json json, T Function(Json json) item) => Paged(
    items: readList(json['items'], item),
    nextCursor: json['nextCursor'] as String?,
  );

  final List<T> items;

  /// Pass back as `cursor` for the next page; null on the last page.
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}
