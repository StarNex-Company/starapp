import 'package:starapp/features/scout/data/models/talent_category.dart';

/// The marketplace's time filter. Serialized by name.
enum OpenCallWindow {
  /// Everything accepting applications; the default.
  openNow,
  closingThisWeek,

  /// Posted in the last 48 hours.
  newlyPosted,
}

/// What the marketplace shows: the search box, category chips and the
/// filter sheet. Equal filters share one cached count.
class OpenCallFilters {
  const OpenCallFilters({
    this.query,
    this.category,
    this.window,
    this.city,
    this.remoteOnly = false,
    this.matchMyTalents = false,
  });

  /// Free text over role, company and city.
  final String? query;

  /// Null for all categories.
  final TalentCategory? category;

  /// Null behaves as [OpenCallWindow.openNow].
  final OpenCallWindow? window;

  /// Null for anywhere.
  final String? city;
  final bool remoteOnly;

  /// Only calls that fit the user's talents.
  final bool matchMyTalents;

  static const _keep = Object();

  /// Pass `null` to clear a nullable filter; omit it to keep the current
  /// value.
  OpenCallFilters copyWith({
    Object? query = _keep,
    Object? category = _keep,
    Object? window = _keep,
    Object? city = _keep,
    bool? remoteOnly,
    bool? matchMyTalents,
  }) => OpenCallFilters(
    query: identical(query, _keep) ? this.query : query as String?,
    category: identical(category, _keep)
        ? this.category
        : category as TalentCategory?,
    window: identical(window, _keep) ? this.window : window as OpenCallWindow?,
    city: identical(city, _keep) ? this.city : city as String?,
    remoteOnly: remoteOnly ?? this.remoteOnly,
    matchMyTalents: matchMyTalents ?? this.matchMyTalents,
  );

  /// The sheet's filters back at their defaults; the search query stays.
  OpenCallFilters resetSheet() => OpenCallFilters(query: query);

  /// Query parameters for `GET /scout/calls` and `/scout/calls/count`.
  /// Unset filters are null, which `ApiClient` drops.
  Map<String, Object?> toQuery() {
    final text = query?.trim();
    return {
      'q': text == null || text.isEmpty ? null : text,
      'category': category?.name,
      'window': window?.name,
      'city': city,
      'remoteOnly': remoteOnly ? true : null,
      'matchMyTalents': matchMyTalents ? true : null,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is OpenCallFilters &&
      other.query == query &&
      other.category == category &&
      other.window == window &&
      other.city == city &&
      other.remoteOnly == remoteOnly &&
      other.matchMyTalents == matchMyTalents;

  @override
  int get hashCode =>
      Object.hash(query, category, window, city, remoteOnly, matchMyTalents);
}
