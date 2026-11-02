import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';

/// What a saved post is, for the filter chips and `?type=`.
enum SavedKind { video, challenge, audio }

/// A post the signed-in user bookmarked. Only they can see the list.
class SavedItem {
  const SavedItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.creator,
    required this.views,
    required this.savedAt,
    this.thumbnailUrl,
  });

  factory SavedItem.fromJson(Json json) => SavedItem(
    id: json['id'] as String,
    kind: readEnum(SavedKind.values, json['kind'], SavedKind.video),
    title: json['title'] as String,
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    views: readInt(json['views']),
    savedAt: readDate(json['savedAt']) ?? DateTime.now(),
    thumbnailUrl: json['thumbnailUrl'] as String?,
  );

  /// The saved post's id.
  final String id;
  final SavedKind kind;
  final String title;
  final CreatorSummary creator;
  final int views;
  final DateTime savedAt;
  final String? thumbnailUrl;

  Json toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'creator': creator.toJson(),
    'views': views,
    'savedAt': savedAt.toUtc().toIso8601String(),
    'thumbnailUrl': thumbnailUrl,
  };
}

/// The saved posts loaded so far for one filter (`GET /me/saved`): a
/// [Paged] response plus [total], how many match the filter in all.
class SavedItems {
  const SavedItems({required this.items, required this.total, this.nextCursor});

  factory SavedItems.fromJson(Json json) {
    final page = Paged.fromJson(json, SavedItem.fromJson);
    return SavedItems(
      items: page.items,
      nextCursor: page.nextCursor,
      total: readInt(json['total'], page.items.length),
    );
  }

  /// Newest first.
  final List<SavedItem> items;
  final int total;

  /// Pass back as `cursor` for the next page; null on the last page.
  final String? nextCursor;

  bool get hasMore => nextCursor != null;

  Json toJson() => {
    'items': [for (final i in items) i.toJson()],
    'nextCursor': nextCursor,
    'total': total,
  };

  /// [nextCursor] always replaces the current one, so pass it on every call.
  SavedItems copyWith({
    List<SavedItem>? items,
    int? total,
    required String? nextCursor,
  }) {
    return SavedItems(
      items: items ?? this.items,
      total: total ?? this.total,
      nextCursor: nextCursor,
    );
  }
}
