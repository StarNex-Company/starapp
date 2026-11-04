import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/data/repositories/discover_repository.dart';

/// Serves the fixtures below, each shaped like its API response, through the
/// real `fromJson`, so mock mode exercises the same parsing as the API.
class MockDiscoverRepository implements DiscoverRepository {
  const MockDiscoverRepository();

  @override
  Future<List<DiscoverCategory>> fetchCategories() async =>
      readList(_categories, DiscoverCategory.fromJson);

  @override
  Future<List<RisingCreator>> fetchRisingCreators() async =>
      readList(_rising, RisingCreator.fromJson);

  @override
  Future<List<SuggestedCreator>> fetchSuggestedCreators() async =>
      readList(_suggested, SuggestedCreator.fromJson);

  @override
  Future<void> dismissSuggestion(String creatorId) async {}

  @override
  Future<List<FeaturedChallenge>> fetchFeaturedChallenges() async =>
      readList(_challenges(DateTime.now()), FeaturedChallenge.fromJson);

  @override
  Future<Paged<DiscoverVideo>> fetchVideos({
    String? category,
    DiscoverFilters filters = const DiscoverFilters(),
    String? cursor,
  }) async => Paged.fromJson(_videos(), DiscoverVideo.fromJson);

  @override
  Future<void> setSaved(String videoId, {required bool saved}) async {}
}

const _img = 'assets/images/discover';

/// `GET /discover/categories`.
const _categories = [
  {'id': 'music', 'name': 'Afrobeats & Music'},
  {'id': 'dance', 'name': 'Dance Choreography'},
  {'id': 'visual-arts', 'name': 'Visual Arts'},
  {'id': 'acting', 'name': 'Acting & Monologue'},
  {'id': 'fashion', 'name': 'Fashion Design'},
  {'id': 'sports', 'name': 'Freestyle Sports'},
];

/// `GET /discover/rising`: unseen stories in each ring colour, then a
/// watched one.
const _rising = [
  {
    'creator': {
      'id': 'amina',
      'name': 'Amina K.',
      'handle': 'amina_k',
      'avatarUrl': 'assets/images/shared/creator_amina.jpg',
      'tier': 'superNova',
      'isVerified': true,
    },
    'storyKey': 'amina',
    'reason': 'stars',
    'hasUnseenStory': true,
  },
  {
    'creator': {
      'id': 'emmanuel-f',
      'name': 'Emmanuel F.',
      'handle': 'emmanuel_f',
      'avatarUrl': 'assets/images/shared/creator_carlos.jpg',
      'tier': 'stellar',
    },
    'storyKey': 'carlos',
    'reason': 'dance',
    'hasUnseenStory': true,
  },
  {
    'creator': {
      'id': 'ayeni',
      'name': 'Ayeni Micheal',
      'handle': 'ayeni_micheal',
      'avatarUrl': '$_img/creator_zainab.jpg',
      'tier': 'risingNova',
    },
    'storyKey': 'ayeni',
    'reason': 'challenge',
    'hasUnseenStory': true,
  },
  {
    'creator': {
      'id': 'silver-sonik',
      'name': 'Silver Sonik',
      'handle': 'silver_sonik',
      'avatarUrl': 'assets/images/shared/creator_lucas.jpg',
      'tier': 'shootingStar',
    },
    'storyKey': 'silver',
    'reason': 'music',
    'hasUnseenStory': false,
  },
];

const _followedBy = [
  {
    'id': 'tolu-adeyemi',
    'name': 'Tolu Adeyemi',
    'handle': 'tolu_adeyemi',
    'avatarUrl': '$_img/avatar_you.jpg',
  },
  {
    'id': 'efe-okafor',
    'name': 'Efe Okafor',
    'handle': 'efe_okafor',
    'avatarUrl': '$_img/mutual_2.jpg',
  },
  {
    'id': 'kola-bankole',
    'name': 'Kola Bankole',
    'handle': 'kola_bankole',
    'avatarUrl': '$_img/avatar_you.jpg',
  },
];

/// `GET /discover/suggestions`: more than the carousel shows, so dismissing
/// one brings in the next.
const _suggested = [
  {
    'creator': {
      'id': 'chidi-visuals',
      'name': 'Chidi Visuals',
      'handle': 'chidi_lens',
      'avatarUrl': 'assets/images/shared/creator_chidi.jpg',
    },
    'talent': 'Photography',
    'followedBy': _followedBy,
  },
  {
    'creator': {
      'id': 'nia',
      'name': 'Nia Adebayo',
      'handle': 'nia_dance',
      'avatarUrl': 'assets/images/shared/creator_carlos.jpg',
    },
    'talent': 'Dance',
    'followedBy': _followedBy,
  },
  {
    'creator': {
      'id': 'sarah-beats',
      'name': 'Sarah Beats',
      'handle': 'sarahbeats',
      'avatarUrl': 'assets/images/shared/creator_amina.jpg',
    },
    'talent': 'Production',
    'followedBy': _followedBy,
  },
  {
    'creator': {
      'id': 'marcus',
      'name': 'Marcus Sterling',
      'handle': 'marcusvocal',
      'avatarUrl': 'assets/images/shared/creator_lucas.jpg',
    },
    'talent': 'Singing',
    'followedBy': _followedBy,
  },
  {
    'creator': {
      'id': 'zainab-m',
      'name': 'Zainab M.',
      'handle': 'zainab_m',
      'avatarUrl': '$_img/creator_zainab.jpg',
    },
    'talent': 'Spoken word',
    'followedBy': _followedBy,
  },
  {
    'creator': {
      'id': 'lucas',
      'name': 'Lucas Thorne',
      'handle': 'lucas_t',
      'avatarUrl': '$_img/suggested_lucas.png',
    },
    'talent': 'Comedy',
    'followedBy': _followedBy,
  },
];

/// `GET /discover/challenges`: one banner in each tone.
List<Json> _challenges(DateTime now) {
  String inFuture(Duration d) => now.add(d).toUtc().toIso8601String();
  const blurb =
      'Sync traditional percussive footwork with electric modern urban '
      'choreography. Reviewed directly by top choreographers.';

  return [
    {
      'id': 'africa-talent-showdown-october',
      'arena': 'Africa Arena',
      'title': 'AFRICA TALENT SHOWDOWN OCTOBER',
      'description': blurb,
      'endsAt': inFuture(const Duration(hours: 24)),
      'prizePool': {'amountMinor': 800000, 'currency': 'USD'},
      'submissions': 6020,
      'tone': 'gold',
    },
    {
      'id': 'afro-fusion-dance-showdown-2026',
      'arena': 'Major Stage Arena',
      'title': 'AFRO-FUSION DANCE SHOWDOWN 2026',
      'description': blurb,
      'endsAt': inFuture(const Duration(days: 6)),
      'prizePool': {'amountMinor': 500000, 'currency': 'USD'},
      'submissions': 1420,
      'tone': 'navy',
    },
  ];
}

/// `GET /discover/videos`: a full grid, two of them already bookmarked.
Json _videos() => {
  'items': [
    for (var i = 1; i <= 6; i++)
      {
        'id': 'discover-video-$i',
        'creator': {
          'id': 'adeboye',
          'name': 'Pastor E.A Adeboye',
          'handle': 'pastor_adeboye',
          'avatarUrl': '$_img/video_author.jpg',
          'isVerified': true,
        },
        'caption':
            'Hey guys, I’ve been trying to create a special song for my '
            'daugther',
        'posterUrl': '$_img/video_thumb.jpg',
        'isSaved': i == 4 || i == 5,
      },
  ],
  'nextCursor': null,
};
