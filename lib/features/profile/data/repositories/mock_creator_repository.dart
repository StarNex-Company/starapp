import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';
import 'package:starapp/features/profile/data/repositories/creator_repository.dart';

/// Serves the fixtures below, shaped like `GET /creators/{id}` and
/// `GET /creators/{id}/posts`, through the real `fromJson`. Chidi is the
/// fully designed profile (Figma "Profile — Creator (Public)"); Ayeni is
/// already followed, so his profile shows the "(Following)" layout and the
/// co-founder badge. Any other id gets a bare profile built from the id.
class MockCreatorRepository implements CreatorRepository {
  const MockCreatorRepository();

  @override
  Future<CreatorProfile> fetchCreator(String creatorId) async {
    final now = DateTime.now();
    final json = switch (creatorId) {
      'chidi' => _chidi(now),
      'ayeni' => _ayeni(now),
      _ => _generic(creatorId),
    };
    return CreatorProfile.fromJson(json);
  }

  @override
  Future<Paged<CreatorPost>> fetchPosts(
    String creatorId, {
    String? cursor,
  }) async => Paged.fromJson({
    'items': _posts[creatorId] ?? const [],
    'nextCursor': null,
  }, CreatorPost.fromJson);
}

String _ago(DateTime now, int days) =>
    now.subtract(Duration(days: days)).toUtc().toIso8601String();

Json _chidi(DateTime now) => {
  'id': 'chidi',
  'name': 'Chidi Eze',
  'handle': 'chidi_eze',
  'avatarUrl': 'assets/images/profile/creator_photo_chidi.jpg',
  'tier': 'superNova',
  'isVerified': true,
  'coverUrl': _trending,
  'location': 'Lagos, Nigeria',
  'bio':
      'Freestyle dancer and choreographer. Finding freedom in every '
      'movement. Open to brand collaborations.',
  'talents': ['Dance', 'Choreography', 'Freestyle'],
  'stars': 48200,
  'followers': 12418,
  'following': 312,
  'wins': 3,
  'isFollowing': false,
  'hasStory': true,
  'featuredChallenge': {
    'challengeId': 'afro-dance-takeover',
    'title': 'Afro-Dance Takeover',
    'status': 'live',
    'date': _ago(now, 10),
    'rank': 4,
    'entrants': 1248,
  },
  'challenges': [
    {
      'challengeId': 'afro-dance-takeover',
      'title': 'Afro-Dance Takeover',
      'status': 'finished',
      'date': _ago(now, 45),
      'rank': 4,
      'entrants': 1248,
    },
    {
      'challengeId': 'freestyle-friday',
      'title': 'Freestyle Friday',
      'status': 'finished',
      'date': _ago(now, 75),
      'rank': 1,
      'entrants': 410,
      'prize': {'amountMinor': 150000, 'currency': 'USD'},
    },
    {
      'challengeId': 'lagos-street-dance',
      'title': 'Lagos Street Dance',
      'status': 'finished',
      'date': _ago(now, 110),
      'rank': 2,
      'entrants': 640,
    },
  ],
  'stats': {
    'views30d': 120000,
    'viewsChange': 18,
    'watchRatio': 0.81,
    'entries': 9,
    'topCategory': 'Dance',
    'topSubcategory': 'Choreography',
    'firstWinAt': _ago(now, 290),
  },
};

Json _ayeni(DateTime now) => {
  'id': 'ayeni',
  'name': 'Ayeni Micheal',
  'handle': 'ayeni_micheal',
  'avatarUrl': 'assets/images/profile/creator_photo_ayeni.jpg',
  'tier': 'shootingStar',
  'isVerified': true,
  'coverUrl': _studio,
  'location': 'Lagos, Nigeria',
  'bio':
      'Building Star App 🚀 Product lead by day, Afro-fusion guitarist by '
      'night.',
  'talents': ['Guitar', 'Music', 'Tech'],
  'stars': 420,
  'followers': 97,
  'following': 58,
  'wins': 0,
  // In the session's mock following set.
  'isFollowing': true,
  'isCoFounder': true,
  'featuredChallenge': _welcome(now),
  'challenges': [
    {
      'challengeId': 'afro-fusion-guitar-jam',
      'title': 'Afro-Fusion Guitar Jam',
      'status': 'live',
      'date': _ago(now, 0),
    },
    _welcome(now),
  ],
  'stats': {
    'views30d': 2100,
    'viewsChange': 4,
    'watchRatio': 0.63,
    'entries': 2,
    'topCategory': 'Music',
    'topSubcategory': 'Guitar',
  },
};

Json _welcome(DateTime now) => {
  'challengeId': 'welcome-challenge',
  'title': 'Welcome Challenge',
  'status': 'finished',
  'date': _ago(now, 230),
};

/// What an id without a fixture gets: its words title-cased as the name and
/// no photo, so the avatar shows its placeholder.
Json _generic(String id) => {
  'id': id,
  'name': id
      .split(RegExp('[-_]'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' '),
  'handle': id,
  'avatarUrl': null,
};

// Video stills shared with other screens.
const _trending = 'assets/images/home/trending_thumb.jpg';
const _studio = 'assets/images/challenges/arena_studio.jpg';
const _dancer = 'assets/images/videos/video_amina_k.jpg';
const _freestyle = 'assets/images/stories/story_freestyle.jpg';
const _conceptCity = 'assets/images/stories/gallery_concept_city.jpg';
const _sarahReel = 'assets/images/stories/story_sarah_1.jpg';
const _gabrielReel = 'assets/images/stories/story_gabriel_1.jpg';
const _funmilayoReel = 'assets/images/stories/story_funmilayo_1.jpg';

/// The designed six-video grid: the first is a challenge entry.
List<Json> _grid(String creatorId, List<String> stills) => [
  for (final (i, views) in const [
    48000,
    120000,
    9400,
    31000,
    2200,
    76000,
  ].indexed)
    {
      'id': '$creatorId-post-${i + 1}',
      'views': views,
      'thumbnailUrl': stills[i],
      'isEntry': i == 0,
    },
];

final _posts = <String, List<Json>>{
  'chidi': _grid('chidi', const [
    _trending,
    _studio,
    _dancer,
    _dancer,
    _trending,
    _studio,
  ]),
  'ayeni': _grid('ayeni', const [
    _studio,
    _freestyle,
    _conceptCity,
    _sarahReel,
    _gabrielReel,
    _funmilayoReel,
  ]),
};
