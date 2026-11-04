import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/saved_item.dart';
import 'package:starapp/features/profile/data/repositories/saved_repository.dart';

/// Serves the fixture below in pages of [_pageSize], shaped like the
/// `GET /me/saved` response, through the real `fromJson`. The cursor is the
/// offset of the next page.
class MockSavedRepository implements SavedRepository {
  const MockSavedRepository();

  static const _pageSize = 6;

  @override
  Future<SavedItems> fetchSaved({SavedKind? type, String? cursor}) async {
    final matching = [
      for (final item in _saved(DateTime.now()))
        if (type == null || item['kind'] == type.name) item,
    ];
    final start = int.tryParse(cursor ?? '') ?? 0;
    final end = (start + _pageSize).clamp(0, matching.length);
    return SavedItems.fromJson({
      'items': matching.sublist(start.clamp(0, end), end),
      'nextCursor': end < matching.length ? '$end' : null,
      'total': matching.length,
    });
  }

  @override
  Future<void> unsave(String postId) async {}
}

const _img = 'assets/images/profile';
const _sahel = '$_img/saved_thumb_sahel_soul.jpg';
const _freestyle = '$_img/saved_thumb_street_freestyle.jpg';
const _studio = 'assets/images/shared/arena_studio.jpg';

const _amina = {
  'id': 'amina',
  'name': 'Amina K.',
  'handle': 'amina',
  'avatarUrl': '$_img/saved_avatar_amina.png',
};
const _maya = {
  'id': 'maya-lin',
  'name': 'Maya Lin',
  'handle': 'maya_lin',
  'avatarUrl': '$_img/saved_avatar_maya.png',
};
const _tunde = {
  'id': 'tunde-beats',
  'name': 'Tunde Beats',
  'handle': 'tunde_beats',
  'avatarUrl': '$_img/saved_avatar_tunde.png',
};
const _chidi = {
  'id': 'chidi',
  'name': 'Chidi Eze',
  'handle': 'chidi_eze',
  'avatarUrl': '$_img/saved_avatar_chidi.png',
};
const _silver = {
  'id': 'silver-sonik',
  'name': 'Silver Sonik',
  'handle': 'silver_sonik',
  'avatarUrl': '$_img/saved_avatar_silver.png',
};
const _david = {
  'id': 'david-cole',
  'name': 'David Cole',
  'handle': 'david_cole',
  'avatarUrl': '$_img/saved_avatar_david.png',
};

/// Newest first: this week, last week and earlier, every kind.
List<Json> _saved(DateTime now) {
  Json item(
    String id,
    String kind,
    String title,
    Json creator,
    String thumbnail,
    int views,
    int daysAgo,
  ) => {
    'id': id,
    'kind': kind,
    'title': title,
    'creator': creator,
    'thumbnailUrl': thumbnail,
    'views': views,
    'savedAt': now.subtract(Duration(days: daysAgo)).toUtc().toIso8601String(),
  };

  return [
    item(
      'sahel-soul',
      'video',
      'Sahel Soul routine',
      _amina,
      _sahel,
      1200000,
      1,
    ),
    item(
      'midnight-pulse',
      'video',
      'Midnight Pulse (live)',
      _maya,
      _studio,
      864000,
      2,
    ),
    item(
      'lamba-groove',
      'audio',
      'Lamba Groove beat',
      _tunde,
      _studio,
      412000,
      3,
    ),
    item(
      'street-freestyle',
      'challenge',
      'Street freestyle',
      _chidi,
      _freestyle,
      88000,
      4,
    ),
    item(
      'ori-cover',
      'audio',
      'Ori (vocal cover)',
      _silver,
      _studio,
      230000,
      5,
    ),
    item(
      'gold-coast-choreo',
      'challenge',
      'Gold Coast choreo',
      _david,
      _sahel,
      51000,
      6,
    ),
    item(
      'afro-fusion-warm-up',
      'video',
      'Afro-fusion warm-up',
      _amina,
      _sahel,
      640000,
      9,
    ),
    item(
      'talking-drum-loop',
      'audio',
      'Talking drum loop',
      _tunde,
      _studio,
      128000,
      40,
    ),
  ];
}
