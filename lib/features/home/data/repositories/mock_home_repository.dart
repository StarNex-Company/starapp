import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/home/data/models/feed_category.dart';
import 'package:starapp/features/home/data/models/home_feed.dart';
import 'package:starapp/features/home/data/models/post.dart';
import 'package:starapp/features/home/data/repositories/home_repository.dart';

/// Serves the fixtures below, shaped like the `GET /home` and `GET /feed`
/// responses, through the real `fromJson`. Every feed tab gets the same
/// single page.
class MockHomeRepository implements HomeRepository {
  const MockHomeRepository();

  @override
  Future<HomeSections> fetchSections() async =>
      HomeSections.fromJson(_sections(DateTime.now()));

  @override
  Future<Paged<Post>> fetchPosts({
    FeedCategory category = FeedCategory.following,
    String? cursor,
  }) async => Paged.fromJson(_feed(DateTime.now()), Post.fromJson);

  @override
  Future<void> setStarred(String postId, {required bool starred}) async {}

  @override
  Future<void> setBookmarked(String postId, {required bool bookmarked}) async {}

  @override
  Future<void> setReported(String postId, {required bool reported}) async {}

  @override
  Future<void> hideSuggestion(String creatorId) async {}
}

const _img = 'assets/images/home';

/// A fixture image: a bare name in [_img], or a full asset path.
String _asset(String name) => name.startsWith('assets/') ? name : '$_img/$name';

Json _person(
  String id,
  String name,
  String handle,
  String avatar, {
  String? tier,
  bool verified = false,
}) => {
  'id': id,
  'name': name,
  'handle': handle,
  'avatarUrl': _asset(avatar),
  'tier': tier,
  'isVerified': verified,
};

final _adeboye = _person(
  'adeboye',
  'Pastor E.A Adeboye',
  'pastor_adeboye',
  'avatar_adeboye.png',
  verified: true,
);
final _tinubu = _person(
  'tinubu',
  'President Bola A. Tinubu',
  'officialbat',
  'avatar_tinubu.jpg',
  verified: true,
);

/// A creator tier shows the creator badge beside the name.
final _ayeni = _person(
  'ayeni',
  'Ayeni Micheal',
  'ayeni_micheal',
  'avatar_ayeni.jpg',
  tier: 'risingNova',
  verified: true,
);

/// Who appears in "Starred by" and "Followed by".
final _friends = [
  _person('kola-bankole', 'Kola Bankole', 'kola_bankole', 'assets/images/shared/avatar_you.jpg'),
  _person('maya-lin', 'Maya Lin', 'mayalin', 'avatar_liker.jpg'),
  _person('david-cole', 'David Cole', 'davidcole', 'assets/images/shared/avatar_you.jpg'),
];

String _ago(DateTime now, Duration age) =>
    now.subtract(age).toUtc().toIso8601String();

/// `GET /home`.
Json _sections(DateTime now) {
  Json story(String key, Json creator, String cover, int followers) => {
    'storyKey': key,
    'creator': creator,
    'coverUrl': _asset(cover),
    'followers': followers,
  };
  Json talent(String id, Json author, {int minutesAgo = 120}) => {
    'id': id,
    'author': {...author, 'avatarUrl': _ayeni['avatarUrl']},
    'createdAt': _ago(now, Duration(minutes: minutesAgo)),
    'tag': '🎬 Acting Audition',
    'coverUrl': 'assets/images/shared/entry_video_frame.jpg',
  };
  Json suggestion(String id, String name, String handle, String avatar) => {
    'creator': _person(id, name, handle, avatar),
    'followedBy': _friends,
  };
  Json verified(String id, String name, String handle, String avatar) =>
      _person(id, name, handle, avatar, verified: true);
  Json creator(String id, String name, String handle) =>
      _person(id, name, handle, 'avatar_ayeni.jpg', tier: 'stellar');

  return {
    'stories': [
      story('adeboye', _adeboye, 'story_adeboye.png', 265800),
      story('tinubu', _tinubu, 'story_tinubu.png', 10),
      story(
        'sarah',
        verified(
          'sarah-angel',
          'Sarah Angel',
          'sarahangel',
          'avatar_sarah.jpg',
        ),
        'story_sarah.png',
        98100,
      ),
      story(
        'funmilayo',
        verified(
          'funmilayo',
          'Funmilayo Ade',
          'funmilayo_ade',
          'avatar_funmilayo.jpg',
        ),
        'story_funmilayo.png',
        2500,
      ),
      story(
        'gabriel',
        verified(
          'gabriel',
          'Gabriel Anyakumen',
          'gabriel_anya',
          'avatar_gabriel.jpg',
        ),
        'story_gabriel.png',
        260,
      ),
    ],
    'trendingTalents': [
      talent('t1', _ayeni),
      talent('t2', {..._adeboye, 'name': 'PastorE.A Adeboye'}, minutesAgo: 121),
      talent('t3', {
        ...creator('olayiwola', 'Olayiwola Solomon', 'olayiwola_sol'),
        'isVerified': true,
      }),
      talent(
        't4',
        _person(
          'olajide',
          'Olajide Great',
          'olajide_great',
          'avatar_ayeni.jpg',
        ),
      ),
      talent('t5', {
        ...creator('foster', 'Bishop Foster Emmanuel', 'bishop_foster'),
        'isVerified': true,
      }),
      talent('t6', {
        ...creator('emmanuel', 'Emmanuel Ayanleye', 'emmanuel'),
        'isVerified': true,
      }),
    ],
    'suggestedCreators': [
      suggestion(
        'chidi-visuals',
        'Chidi Visuals',
        'chidi_lens',
        'assets/images/shared/creator_chidi.jpg',
      ),
      suggestion('nia', 'Nia Adebayo', 'nia_dance', 'assets/images/shared/creator_carlos.jpg'),
      suggestion(
        'sarah-beats',
        'Sarah Beats',
        'sarahbeats',
        'assets/images/shared/creator_amina.jpg',
      ),
      suggestion(
        'marcus',
        'Marcus Sterling',
        'marcusvocal',
        'assets/images/shared/creator_lucas.jpg',
      ),
    ],
  };
}

/// `GET /feed`: the lead post, the one between the two carousels (with the
/// "+N" media pile), then the rest.
Json _feed(DateTime now) {
  const flyer = '$_img/post_worship_flyer.jpg';
  const portrait = 'assets/images/shared/post_adeboye_portrait.jpg';
  final adeboyePhoto = _adeboye['avatarUrl'];
  final yesterday = DateTime(now.year, now.month, now.day - 1, 13, 45);
  Json counts(int stars, int comments, int reposts) => {
    'stars': stars,
    'comments': comments,
    'reposts': reposts,
    'starredBy': _friends,
  };

  return {
    'items': [
      {
        'id': 'p1',
        'author': {
          ..._adeboye,
          'id': 'gloria',
          'name': 'Gloria H. Kenneth',
          'handle': 'gloria_kenneth',
        },
        'authorHasStory': true,
        'createdAt': _ago(now, const Duration(hours: 2)),
        'text':
            'Join us this Sunday for live worship 🎶 Our choir is entering the '
            'Afro-Beats Vocal Clash this month. Come support us and drop a ⭐ '
            'on the rehearsal clip! #VocalClash #StarApp',
        'mediaUrls': [flyer],
        'mediaCount': 1,
        ...counts(108200, 12000, 20),
      },
      {
        'id': 'p2',
        'author': _adeboye,
        'authorHasStory': true,
        'createdAt': _ago(now, const Duration(hours: 3)),
        'text':
            "Thank you to everyone who joined our Sunday service 🙏 The choir's "
            'full performance is now on our page. Share it with someone who '
            'needs to hear it today.',
        'mediaUrls': [flyer, portrait, adeboyePhoto, adeboyePhoto, portrait],
        'mediaCount': 32,
        ...counts(108200, 12000, 20),
      },
      {
        'id': 'p3',
        'author': {..._tinubu, 'isVerified': false},
        'createdAt': yesterday.toUtc().toIso8601String(),
        'text':
            'Proud of the young creatives putting Nigerian talent on the world '
            'stage 🇳🇬 Keep creating, keep shining. #EveryTalentDeservesAStage',
        ...counts(2000, 20, 2),
      },
      {
        'id': 'p4',
        'author': _ayeni,
        'authorHasStory': true,
        'createdAt': _ago(now, const Duration(hours: 5)),
        'text':
            'Big week for the Star App team 🚀 Monthly Challenges are now '
            'live. Which category are you entering first? Tell us in the '
            'comments 👇',
        ...counts(108200, 12000, 20),
      },
    ],
    'nextCursor': null,
  };
}
