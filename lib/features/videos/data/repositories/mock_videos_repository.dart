import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/session/data/repositories/mock_session_repository.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/videos/data/models/feed_video.dart';
import 'package:starapp/features/videos/data/models/video_comment.dart';
import 'package:starapp/features/videos/data/repositories/videos_repository.dart';

/// Serves the fixtures below, shaped like the API's responses, through the
/// real `fromJson`, so mock mode exercises the same parsing as the API.
/// Posters stand in for playback.
class MockVideosRepository implements VideosRepository {
  const MockVideosRepository();

  static int _posted = 0;

  @override
  Future<Paged<FeedVideo>> fetchFeed(VideosFeed feed, {String? cursor}) async {
    final now = DateTime.now();
    return Paged.fromJson(switch (feed) {
      VideosFeed.forYou => _forYou(now),
      VideosFeed.following => _following(now),
    }, FeedVideo.fromJson);
  }

  @override
  Future<void> setStarred(String videoId, {required bool starred}) async {}

  @override
  Future<void> setSaved(String videoId, {required bool saved}) async {}

  @override
  Future<void> recordShare(String videoId) async {}

  @override
  Future<Paged<VideoComment>> fetchComments(
    String videoId, {
    String? cursor,
  }) async => Paged.fromJson(_comments(DateTime.now()), VideoComment.fromJson);

  @override
  Future<Paged<VideoComment>> fetchReplies(
    String videoId,
    String commentId, {
    String? cursor,
  }) async => Paged.fromJson({
    'items': _replies(DateTime.now())[commentId] ?? const [],
    'nextCursor': null,
  }, VideoComment.fromJson);

  /// Echoes the comment back as the server would store it, written by the
  /// mock session's user.
  @override
  Future<VideoComment> postComment(
    String videoId,
    String text, {
    String? replyTo,
  }) async {
    final me = await const MockSessionRepository().fetchCurrentUser();
    return VideoComment.fromJson({
      'id': 'mine-${_posted++}',
      'author': me.summary.toJson(),
      'text': text,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> setCommentLiked(
    String videoId,
    String commentId, {
    required bool liked,
  }) async {}
}

const _videos = 'assets/images/videos';
const _search = 'assets/images/search';

const _chidi = {
  'id': 'chidi',
  'name': 'Chidi Eze',
  'handle': 'chidi_eze',
  'avatarUrl': '$_videos/comment_chidi_eze.jpg',
  'tier': 'superNova',
  'isVerified': true,
};
const _tunde = {
  'id': 'tunde-beats',
  'name': 'Tunde Beats',
  'handle': 'tunde_beats',
  'avatarUrl': '$_search/creator_tunde_beats.png',
  'tier': 'universeIcon',
  'isVerified': true,
};
const _kofi = {
  'id': 'kofi-mensah',
  'name': 'Kofi Mensah',
  'handle': 'kofi_mensah',
  'avatarUrl': '$_search/creator_kofi_mensah.png',
  'tier': 'superNova',
  'isVerified': true,
};
const _amina = {
  'id': 'amina',
  'name': 'Amina K.',
  'handle': 'amina_k',
  'avatarUrl': '$_search/creator_amina_k.png',
  'tier': 'universeIcon',
  'isVerified': true,
};
const _ayeni = {
  'id': 'ayeni',
  'name': 'Ayeni Micheal',
  'handle': 'ayeni_micheal',
  'avatarUrl': 'assets/images/home/avatar_ayeni.jpg',
  'tier': 'shootingStar',
  'isVerified': true,
};
const _zainab = {
  'id': 'zainab-bello',
  'name': 'Zainab Bello',
  'handle': 'zainab_bello',
  'avatarUrl': '$_videos/comment_zainab_bello.jpg',
};
const _emmanuel = {
  'id': 'emmanuel',
  'name': 'Emmanuel Ayanleye',
  'handle': 'emmanuel',
  'avatarUrl': '$_videos/comment_emmanuel_ayanleye.jpg',
  'tier': 'risingNova',
  'isVerified': true,
};
const _tolu = {
  'id': 'tolu-adeyemi',
  'name': 'Tolu Adeyemi',
  'handle': 'tolu_adeyemi',
  'avatarUrl': '$_videos/comment_tolu_adeyemi.jpg',
};

String _ago(DateTime now, Duration d) =>
    now.subtract(d).toUtc().toIso8601String();

/// `GET /feed/for-you`: a caption with its hashtag on a second line (as
/// designed) and ones with it inline. The last page, so the feed loops.
Json _forYou(DateTime now) => {
  'items': [
    {
      'id': 'fyp-chidi-eze',
      'creator': _chidi,
      'location': 'Lagos',
      'caption': 'Finding freedom in every movement.\n#OwnTheSpotlight ✨',
      'sound': 'Original Sound · Chidi Eze',
      'durationMs': 12000,
      'createdAt': _ago(now, const Duration(hours: 3)),
      'posterUrl': '$_videos/video_chidi_eze.jpg',
      'stars': 1098,
      'comments': 30100,
      'shares': 412,
      'saves': 123,
      'views': 184000,
    },
    {
      'id': 'fyp-tunde-beats',
      'creator': _tunde,
      'location': 'Lagos',
      'caption': 'New Afro-beat, cooked live 🎛️ #AfroBeatsClash',
      'sound': 'Original Sound · Tunde Beats',
      'durationMs': 12000,
      'createdAt': _ago(now, const Duration(hours: 9)),
      'posterUrl': '$_videos/video_tunde_beats.jpg',
      'stars': 2431,
      'comments': 4800,
      'shares': 230,
      'saves': 612,
      'views': 96500,
    },
    {
      'id': 'fyp-kofi-mensah',
      'creator': _kofi,
      'location': 'Accra',
      'caption': 'Teaching the Highlife 2.0 guitar lick 🎸 #OwnTheSpotlight',
      'sound': 'Original Sound · Kofi Mensah',
      'durationMs': 12000,
      'createdAt': _ago(now, const Duration(days: 1)),
      'posterUrl': '$_videos/video_kofi_mensah.jpg',
      'stars': 1876,
      'comments': 3200,
      'shares': 158,
      'saves': 405,
      'views': 71200,
    },
  ],
  'nextCursor': null,
};

/// `GET /feed/following`.
Json _following(DateTime now) => {
  'items': [
    {
      'id': 'following-amina-k',
      'creator': _amina,
      'location': 'Abuja',
      'caption':
          'Sahel Soul, the routine that won it all 🏆 #AfroDanceTakeover',
      'sound': 'Original Sound · Amina K.',
      'durationMs': 12000,
      'createdAt': _ago(now, const Duration(hours: 5)),
      'posterUrl': '$_videos/video_amina_k.jpg',
      'stars': 18400,
      'comments': 2100,
      'shares': 1320,
      'saves': 3902,
      'views': 412000,
    },
    {
      'id': 'following-ayeni-micheal',
      'creator': _ayeni,
      'location': 'Lagos',
      'caption': 'Late-night jam in Lagos 🎸 #AfroFusion',
      'sound': 'Original Sound · Ayeni Micheal',
      'durationMs': 12000,
      'createdAt': _ago(now, const Duration(days: 2)),
      'posterUrl': '$_videos/video_ayeni_micheal.jpg',
      'stars': 6210,
      'comments': 884,
      'shares': 301,
      'saves': 1140,
      'views': 128000,
    },
  ],
  'nextCursor': null,
};

/// `GET /videos/{id}/comments`: every video shows these. One comment comes
/// with the first of its replies; the rest load on "View 3 replies".
Json _comments(DateTime now) => {
  'items': [
    {
      'id': 'c-chidi-eze',
      'author': _chidi,
      'text': 'The control on that turn 🔥',
      'createdAt': _ago(now, const Duration(hours: 2)),
      'likes': 12,
    },
    {
      'id': 'c-zainab-bello',
      'author': _zainab,
      'text': 'This deserves to win October.',
      'createdAt': _ago(now, const Duration(hours: 2)),
      'likes': 8,
      'replies': [_replies(now)['c-zainab-bello']!.first],
      'replyCount': 4,
    },
    {
      'id': 'c-tolu-adeyemi',
      'author': _tolu,
      'text': 'Starred! Keep going.',
      'createdAt': _ago(now, const Duration(hours: 2)),
      'likes': 5,
    },
  ],
  'nextCursor': null,
};

/// `GET /videos/{id}/comments/{commentId}/replies`, by comment id.
Map<String, List<Json>> _replies(DateTime now) => {
  'c-zainab-bello': [
    {
      'id': 'c-zainab-bello-r1',
      'author': _emmanuel,
      'text': 'Thank you so much Zainab! ✨ Appreciate the support!',
      'createdAt': _ago(now, const Duration(hours: 2)),
      'isAuthor': true,
    },
    {
      'id': 'c-zainab-bello-r2',
      'author': _tolu,
      'text': 'Facts! October is yours.',
      'createdAt': _ago(now, const Duration(hours: 1)),
    },
    {
      'id': 'c-zainab-bello-r3',
      'author': _kofi,
      'text': 'Voted already 🙌',
      'createdAt': _ago(now, const Duration(hours: 1)),
    },
    {
      'id': 'c-zainab-bello-r4',
      'author': _amina,
      'text': 'Rooting for you!',
      'createdAt': _ago(now, const Duration(minutes: 45)),
    },
  ],
};
