import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/data/repositories/my_profile_repository.dart';

/// Serves the fixtures below, shaped like the `GET /me/profile`,
/// `GET /me/posts` and `GET /me/shortcuts` responses, through the real
/// `fromJson`.
class MockMyProfileRepository implements MyProfileRepository {
  const MockMyProfileRepository();

  @override
  Future<MyProfile> fetchMyProfile() async =>
      MyProfile.fromJson(_profile(DateTime.now()));

  @override
  Future<Paged<ProfileGridPost>> fetchPosts({String? cursor}) async =>
      Paged.fromJson(_posts, ProfileGridPost.fromJson);

  @override
  Future<ShortcutsSummary> fetchShortcuts() async =>
      ShortcutsSummary.fromJson(_shortcuts);
}

const _images = 'assets/images';

Json _profile(DateTime now) {
  String ago(int days) =>
      now.subtract(Duration(days: days)).toUtc().toIso8601String();

  return {
    'isFounder': true,
    'tierProgress': {
      'nextTier': 'stellar',
      'progress': 0.519,
      'starsToNext': 721,
      'nextPerk': 'priority placement',
      'topPercent': 4,
      'region': 'Nigeria',
    },
    'passport': {
      'score': 94,
      'metrics': [
        {'kind': 'consistency', 'percent': 96},
        {'kind': 'engagement', 'percent': 93},
        {'kind': 'improvement', 'percent': 88},
      ],
    },
    'challenges': [
      {
        'id': 'afro-beats-clash',
        'title': 'Afro-Beats Producer & Vocal Clash',
        'standing': 'live',
        'enteredAt': ago(12),
        'rank': 14,
        'stars': 331,
      },
      {
        'id': 'afro-dance-takeover',
        'title': 'Afro-Dance Takeover',
        'standing': 'placed',
        'enteredAt': ago(70),
        'endedAt': ago(45),
        'rank': 7,
        'entrants': 1248,
      },
      {
        'id': 'welcome-challenge',
        'title': 'Welcome Challenge',
        'standing': 'completed',
        'enteredAt': ago(230),
        'endedAt': ago(228),
        'stars': 50,
      },
    ],
    'stats': [
      {'kind': 'views', 'value': 11800, 'changePercent': 24},
      {'kind': 'watchTime', 'value': 72, 'changePercent': 6},
      {'kind': 'starsThisMonth', 'value': 384, 'isRecord': true},
      {'kind': 'topCategory', 'value': 62, 'category': 'Music'},
    ],
  };
}

const _posts = {
  'items': [
    {
      'id': 'studio-session-freestyle',
      'thumbnailUrl': 'assets/images/shared/arena_studio.jpg',
      'views': 4200,
      'isChallengeEntry': true,
    },
    {
      'id': 'late-night-vocal-run',
      'thumbnailUrl': 'assets/images/shared/avatar_you.jpg',
      'views': 2800,
    },
    {
      'id': 'sunday-choir-rehearsal',
      'thumbnailUrl': 'assets/images/shared/post_adeboye_portrait.jpg',
      'views': 1100,
    },
    {
      'id': 'behind-the-beat',
      'thumbnailUrl': '$_images/profile/me_cover.jpg',
      'views': 940,
    },
    {
      'id': 'afro-beats-cover-burna-boy',
      'thumbnailUrl': 'assets/images/shared/creator_amina.jpg',
      'views': 3600,
    },
    {
      'id': 'gbedu-dance-cover',
      'thumbnailUrl': 'assets/images/shared/hub_banner_concept_art.jpg',
      'views': 610,
    },
  ],
  'nextCursor': null,
};

const _shortcuts = {
  'walletBalance': {'amountMinor': 124050000, 'currency': 'NGN'},
  'savedCount': 8,
  'verificationStepsDone': 3,
  'verificationSteps': 5,
};
