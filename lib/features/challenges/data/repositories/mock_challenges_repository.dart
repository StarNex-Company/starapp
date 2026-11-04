import 'package:intl/intl.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/models/challenges_hub.dart';
import 'package:starapp/features/challenges/data/models/leaderboard.dart';
import 'package:starapp/features/challenges/data/models/my_entries.dart';
import 'package:starapp/features/challenges/data/models/tier.dart';
import 'package:starapp/features/challenges/data/models/winners.dart';
import 'package:starapp/features/challenges/data/repositories/challenges_repository.dart';

/// Serves JSON fixtures shaped like the API's responses through the real
/// `fromJson`, with dates relative to now. One detail fixture (the featured
/// arena) stands in for every challenge.
class MockChallengesRepository implements ChallengesRepository {
  MockChallengesRepository();

  /// Live boards served so far, by challenge. The first is the board as it
  /// opens; later ones carry the update that has landed since.
  final _liveFetches = <String, int>{};

  @override
  Future<ChallengesHub> fetchHub() async =>
      ChallengesHub.fromJson(_hub(DateTime.now()));

  @override
  Future<ChallengeDetail> fetchChallenge(String challengeId) async =>
      ChallengeDetail.fromJson(_detail(DateTime.now()));

  @override
  Future<List<ChallengeRule>> fetchRules(String challengeId) async =>
      readList(_rules(DateTime.now())['items'], ChallengeRule.fromJson);

  @override
  Future<void> setSaved(String challengeId, {required bool saved}) async {}

  @override
  Future<List<Challenge>> fetchBoardChallenges() async {
    final now = DateTime.now();
    return [Challenge.fromJson(_featured(now)), Challenge.fromJson(_past(now))];
  }

  @override
  Future<Leaderboard> fetchLeaderboard(
    String challengeId, {
    required BoardView view,
    String? region,
    ChallengeArena? arena,
    String? cursor,
  }) async {
    final now = DateTime.now();
    if (view == BoardView.allTime) {
      return Leaderboard.fromJson(_hallOfFame(now));
    }
    if (challengeId == _pastId) return Leaderboard.fromJson(_finalBoard(now));
    final fetches = _liveFetches[challengeId] =
        (_liveFetches[challengeId] ?? 0) + 1;
    return Leaderboard.fromJson(
      fetches == 1 ? _liveBoard(now) : _liveBoardUpdated(now),
    );
  }

  @override
  Future<List<Challenge>> fetchUpcoming() async =>
      readList(_upcoming(DateTime.now())['items'], Challenge.fromJson);

  @override
  Future<void> setReminder(String challengeId, {required bool remind}) async {}

  @override
  Future<Paged<MyEntry>> fetchMyEntries({String? cursor}) async =>
      Paged.fromJson(_myEntries(DateTime.now()), MyEntry.fromJson);

  @override
  Future<ChallengeWinners> fetchWinners(String challengeId) async =>
      ChallengeWinners.fromJson(_winners(DateTime.now()));

  @override
  Future<TierLevelUp> fetchTierLevelUp() async =>
      TierLevelUp.fromJson(_tierLevelUp);
}

const _img = 'assets/images/challenges';
const _featuredId = 'afro-beats-clash';
const _pastId = 'afro-dance-takeover';

/// Time left on the featured arena, as the design shows it ("4d 18h").
const _featuredLeft = Duration(days: 4, hours: 18, minutes: 22, seconds: 9);

/// "12 Days Left", with room for the seconds between fixture and screen.
const _twelveDays = Duration(days: 12, minutes: 30);

String _at(DateTime now, Duration offset) =>
    now.add(offset).toUtc().toIso8601String();

Json _usd(int dollars) => {'amountMinor': dollars * 100, 'currency': 'USD'};

Json _creator(
  String id,
  String name,
  String handle, {
  String? avatar,
  String? tier,
}) => {
  'id': id,
  'name': name,
  'handle': handle,
  'avatarUrl': avatar,
  'tier': tier,
};

Json _you(String avatar) => _creator(
  'emmanuel',
  'Emmanuel Ayanleye',
  'emmanuel',
  avatar: avatar,
  tier: 'risingNova',
);

Json _tunde(String avatar) =>
    _creator('tunde-beats', 'Tunde Beats', 'tunde_beats', avatar: avatar);
Json _maya(String avatar, {String? tier}) =>
    _creator('maya-lin', 'Maya Lin', 'maya_lin', avatar: avatar, tier: tier);
Json _david(String avatar, {String? tier}) => _creator(
  'david-cole',
  'David Cole',
  'david_cole',
  avatar: avatar,
  tier: tier,
);
Json _amina(String avatar, {String? tier = 'universeIcon'}) =>
    _creator('amina', 'Amina K.', 'amina_k', avatar: avatar, tier: tier);
Json _kofi({String? tier}) => _creator(
  'kofi-mensah',
  'Kofi Mensah',
  'kofi_mensah',
  avatar: '$_img/avatar_kofi.png',
  tier: tier,
);
Json _nia({String? tier}) => _creator(
  'nia',
  'Nia Adebayo',
  'nia_adebayo',
  avatar: '$_img/board_avatar_nia.png',
  tier: tier,
);

Json _place(
  int rank,
  Json creator,
  int stars, {
  String? location,
  String? entry,
  String? talent,
  int movement = 0,
}) => {
  'rank': rank,
  'creator': creator,
  'stars': stars,
  'location': location,
  'entryTitle': entry,
  'talent': talent,
  'movement': movement,
};

// ---------------------------------------------------------------- Challenges

Json _featured(DateTime now) => {
  'id': _featuredId,
  'title': 'Afro-Beats Producer & Vocal Clash',
  'category': 'Music & Production',
  'arena': 'music',
  'status': 'live',
  'coverUrl': 'assets/images/shared/arena_studio.jpg',
  'endsAt': _at(now, _featuredLeft),
  'prize': {
    'amount': _usd(10000),
    'kind': 'grandPrize',
    'perks': ['Sony Music scout review'],
    'bonusStars': 500,
  },
  'entryCount': 890,
  'capacity': 1000,
  'countryCount': 34,
  'topStars': 612,
};

Json _past(DateTime now) => {
  'id': _pastId,
  'title': 'Afro-Dance Takeover',
  'category': 'Dance',
  'arena': 'dance',
  'status': 'ended',
  'endsAt': _at(now, const Duration(days: -45)),
  'prize': {
    'amount': _usd(5000),
    'kind': 'grandPrize',
    'perks': ['Kora Studios choreography contract'],
    'bonusStars': 500,
  },
  'entryCount': 1248,
};

// ---------------------------------------------------------------- Hub

Json _hub(DateTime now) => {
  'activeCount': 6,
  'upcomingCount': 3,
  'myEntryCount': 2,
  'featured': {
    'challenge': _featured(now),
    'podium': [
      _place(
        1,
        _tunde('$_img/hub_avatar_tunde.jpg'),
        612,
        location: 'Lagos, NG',
        entry: 'Lamba Groove',
      ),
      _place(
        2,
        _maya('$_img/hub_avatar_maya.jpg'),
        540,
        location: 'Toronto, CA',
        entry: 'Midnight Pulse',
      ),
      _place(
        3,
        _david('$_img/hub_avatar_david.jpg'),
        536,
        location: 'London, UK',
        entry: 'Sunfall Waves',
      ),
    ],
    'standingsUpdatedAt': _at(now, const Duration(minutes: -2)),
  },
  'arenas': [
    {
      'challenge': {
        'id': 'urban-street-dance',
        'title': 'Urban Street Dance Championship',
        'category': 'Dance',
        'arena': 'dance',
        'status': 'live',
        'endsAt': _at(now, _twelveDays),
        'prize': {'amount': _usd(5000), 'kind': 'bountyPool'},
        'entryCount': 340,
      },
      'preview': {
        'kind': 'leaders',
        'entries': [
          {
            'id': 'marcus-ray-street',
            'creator': _creator('marcus-ray', 'Marcus Ray', 'marcus_ray'),
            'thumbnailUrl': '$_img/hub_entry_marcus.jpg',
            'stars': 486,
          },
          {
            'id': 'elena-fox-street',
            'creator': _creator('elena-fox', 'Elena Fox', 'elena_fox'),
            'thumbnailUrl': '$_img/hub_entry_elena.jpg',
            'stars': 402,
          },
          {
            'id': 'k-crew-street',
            'creator': _creator('k-crew', 'K-Crew', 'k_crew'),
            'thumbnailUrl': '$_img/hub_entry_kcrew.jpg',
            'stars': 318,
          },
        ],
      },
    },
    {
      'challenge': {
        'id': 'digital-concept-art',
        'title': 'Digital Concept Art & Animation',
        'category': 'Visual Arts',
        'arena': 'visualArts',
        'status': 'live',
        'endsAt': _at(now, _twelveDays),
        'prize': {'amount': _usd(3500), 'kind': 'prizePool'},
        'entryCount': 215,
      },
      'preview': {
        'kind': 'banner',
        'imageUrl': 'assets/images/shared/hub_banner_concept_art.jpg',
        'theme': 'Solarpunk Horizons',
      },
    },
  ],
};

// ---------------------------------------------------------------- Detail

String _deadline(DateTime now) =>
    DateFormat('MMM d, HH:mm').format(now.add(_featuredLeft));

Json _detail(DateTime now) => {
  'challenge': _featured(now),
  'about':
      'Produce an original Afro-beats track or deliver a vocal performance '
      'over one. Judges and fans reward originality, groove and stage '
      'presence. The top three win cash prizes, and every finalist gets a '
      'Sony Music scout review.',
  'rules': [
    'Verified creators only, one entry each',
    'Original work, maximum 3 minutes',
    'Submit before ${_deadline(now)}',
    'Stars from fans decide the leaderboard; judges pick the winner from '
        'the top 10',
  ],
  'inspiration': [
    {
      'id': 'inspiration-1',
      'thumbnailUrl': 'assets/images/shared/arena_studio.jpg',
      'viewCount': 1200000,
    },
    {
      'id': 'inspiration-2',
      'thumbnailUrl': '$_img/detail_inspiration_2.jpg',
      'viewCount': 864000,
    },
    {
      'id': 'inspiration-3',
      'thumbnailUrl': '$_img/detail_inspiration_3.jpg',
      'viewCount': 412000,
    },
    {
      'id': 'inspiration-4',
      'thumbnailUrl': 'assets/images/shared/arena_studio.jpg',
      'viewCount': 230000,
    },
  ],
  'topThree': [
    _place(
      1,
      _tunde('$_img/detail_avatar_tunde.png'),
      612,
      location: 'Lagos, NG',
      entry: 'Lamba Groove',
    ),
    _place(
      2,
      _maya('$_img/detail_avatar_maya.png'),
      540,
      location: 'Toronto, CA',
      entry: 'Midnight Pulse',
    ),
    _place(
      3,
      _david('$_img/detail_avatar_david.png'),
      536,
      location: 'London, UK',
      entry: 'Westside Drill',
    ),
  ],
};

Json _rules(DateTime now) => {
  'items': [
    {
      'icon': 'music',
      'title': 'Original work only',
      'subtitle': 'Your own beat and vocals, or licensed samples',
    },
    {
      'icon': 'clock',
      'title': 'Up to 3 minutes',
      'subtitle': 'Longer entries are trimmed automatically',
    },
    {
      'icon': 'calendar',
      'title': 'Deadline ${_deadline(now)}',
      'subtitle': "Late entries can't be accepted",
    },
    {
      'icon': 'shieldCheck',
      'title': 'Verified creators only',
      'subtitle': 'Finish verification to enter',
    },
    {
      'icon': 'trophy',
      'title': 'Judged from the top entries',
      'subtitle': 'Fans give Stars; judges pick the winner',
    },
  ],
};

// ---------------------------------------------------------------- Boards

const _boardTunde = '$_img/board_avatar_tunde.png';
const _boardMaya = '$_img/board_avatar_maya.png';
const _boardDavid = '$_img/board_avatar_david.png';
const _boardAmina = '$_img/board_avatar_amina.png';
const _boardYou = '$_img/board_avatar_you.png';

List<Json> _liveTail() => [
  _place(6, _nia(), 441, location: 'Ibadan, NG', entry: 'Ori'),
  _place(
    7,
    _creator(
      'yaw-boateng',
      'Yaw Boateng',
      'yaw_boateng',
      avatar: '$_img/board_avatar_yaw.png',
    ),
    418,
    location: 'Kumasi, GH',
    entry: 'Gold Coast',
  ),
  _place(
    8,
    _creator(
      'ayeni',
      'Ayeni Micheal',
      'ayeni',
      avatar: '$_img/board_avatar_ayeni.png',
    ),
    404,
    location: 'Lagos, NG',
    entry: 'Afro-fusion Strings',
  ),
];

/// The featured arena's board as the page opens.
Json _liveBoard(DateTime now) => {
  'view': 'live',
  'items': [
    _place(
      1,
      _tunde(_boardTunde),
      612,
      location: 'Lagos, NG',
      entry: 'Lamba Groove',
    ),
    _place(
      2,
      _maya(_boardMaya),
      540,
      location: 'Toronto, CA',
      entry: 'Midnight Pulse',
    ),
    _place(
      3,
      _david(_boardDavid),
      536,
      location: 'London, UK',
      entry: 'Westside Drill',
    ),
    _place(
      4,
      _amina(_boardAmina, tier: null),
      508,
      location: 'Abuja, NG',
      entry: 'Sahel Soul',
    ),
    _place(5, _kofi(), 501, location: 'Accra, GH', entry: 'Highlife 2.0'),
    ..._liveTail(),
  ],
  'nextCursor': null,
  'updatedAt': _at(now, const Duration(seconds: -12)),
  'me': {
    'entry': _place(16, _you(_boardYou), 296, entry: 'Late-night vocal run'),
    'starsToTopTen': 93,
  },
};

/// The same board once the next update has landed: places swap and you
/// climb two.
Json _liveBoardUpdated(DateTime now) => {
  'view': 'live',
  'items': [
    _place(
      1,
      _tunde(_boardTunde),
      612,
      location: 'Lagos, NG',
      entry: 'Lamba Groove',
    ),
    _place(
      2,
      _david(_boardDavid),
      552,
      location: 'London, UK',
      entry: 'Westside Drill',
      movement: 1,
    ),
    _place(
      3,
      _maya(_boardMaya),
      540,
      location: 'Toronto, CA',
      entry: 'Midnight Pulse',
      movement: -1,
    ),
    _place(
      4,
      _kofi(),
      514,
      location: 'Accra, GH',
      entry: 'Highlife 2.0',
      movement: 1,
    ),
    _place(
      5,
      _amina(_boardAmina, tier: null),
      508,
      location: 'Abuja, NG',
      entry: 'Sahel Soul',
      movement: -1,
    ),
    ..._liveTail(),
  ],
  'nextCursor': null,
  'updatedAt': _at(now, Duration.zero),
  'me': {
    'entry': _place(
      14,
      _you(_boardYou),
      331,
      entry: 'Late-night vocal run',
      movement: 2,
    ),
    'starsToTopTen': 58,
  },
};

/// Final standings of the finished challenge in the board picker.
Json _finalBoard(DateTime now) => {
  'view': 'live',
  'items': [
    _place(1, _amina(_boardAmina), 64300, location: 'Abuja, NG'),
    _place(
      2,
      _creator(
        'chidi',
        'Chidi Eze',
        'chidi_eze',
        avatar: '$_img/winners_chidi.png',
      ),
      31200,
      location: 'Lagos, NG',
    ),
    _place(3, _kofi(), 28400, location: 'Accra, GH'),
  ],
  'nextCursor': null,
  'updatedAt': _at(now, const Duration(days: -45)),
  'me': {'entry': _place(7, _you(_boardYou), 9840, entry: 'Gbedu dance cover')},
};

Json _hallOfFame(DateTime now) => {
  'view': 'allTime',
  'season': 2026,
  'items': [
    _place(1, _amina(_boardAmina), 1420000),
    _place(2, _tunde(_boardTunde), 1180000),
    _place(
      3,
      _creator(
        'chidi-visuals',
        'Chidi Visuals',
        'chidi_visuals',
        avatar: '$_img/board_avatar_chidi.png',
      ),
      986000,
    ),
    _place(
      4,
      _maya(_boardMaya, tier: 'universeIcon'),
      812000,
      location: 'Toronto, CA',
      talent: 'Music',
    ),
    _place(
      5,
      _david(_boardDavid, tier: 'universeIcon'),
      512000,
      location: 'London, UK',
      talent: 'Music',
    ),
    _place(
      6,
      _kofi(tier: 'universeIcon'),
      388000,
      location: 'Accra, GH',
      talent: 'Comedy',
    ),
    _place(
      7,
      _nia(tier: 'universeIcon'),
      241000,
      location: 'Ibadan, NG',
      talent: 'Dance',
    ),
    _place(
      8,
      _creator(
        'zainab-bello',
        'Zainab Bello',
        'zainab_bello',
        avatar: '$_img/board_avatar_zainab.png',
        tier: 'universeIcon',
      ),
      196000,
      location: 'Kano, NG',
      talent: 'Art',
    ),
    _place(
      9,
      _creator(
        'silver-sonik',
        'Silver Sonik',
        'silver_sonik',
        avatar: '$_img/board_avatar_silver.png',
        tier: 'superNova',
      ),
      154000,
      location: 'Port Harcourt, NG',
      talent: 'Music',
    ),
    _place(
      10,
      _creator(
        'sarah-angel',
        'Sarah Angel',
        'sarah_angel',
        avatar: '$_img/board_avatar_sarah.png',
        tier: 'superNova',
      ),
      141000,
      location: 'Lagos, NG',
      talent: 'Music',
    ),
  ],
  'nextCursor': null,
  'updatedAt': _at(now, Duration.zero),
  'me': {
    'entry': _place(1284, _you(_boardYou), 1280),
    'topPercent': 4,
    'region': 'Nigeria',
  },
};

// ---------------------------------------------------------------- Lists

Json _upcomingChallenge(
  DateTime now,
  String id,
  String title,
  String category,
  String arena,
  int opensInDays,
) => {
  'id': id,
  'title': title,
  'category': category,
  'arena': arena,
  'status': 'upcoming',
  'opensAt': _at(now, Duration(days: opensInDays)),
  'endsAt': _at(now, Duration(days: opensInDays + 14)),
};

Json _upcoming(DateTime now) => {
  'items': [
    _upcomingChallenge(
      now,
      'gospel-voices',
      'Gospel Voices Showcase',
      'Music & Audio',
      'music',
      1,
    ),
    _upcomingChallenge(
      now,
      'street-dance-battle',
      'Street Dance Battle',
      'Dance',
      'dance',
      5,
    ),
    _upcomingChallenge(
      now,
      'stand-up-saturday',
      'Stand-up Saturday',
      'Comedy',
      'comedy',
      8,
    ),
    _upcomingChallenge(
      now,
      'lagos-through-my-lens',
      'Lagos Through My Lens',
      'Photography',
      'photography',
      12,
    ),
  ],
};

Json _myEntries(DateTime now) => {
  'items': [
    {
      'id': 'late-night-vocal-run',
      'title': 'Late-night vocal run',
      'challenge': _featured(now),
      'rank': 14,
      'stars': 331,
    },
    {
      'id': 'gbedu-dance-cover',
      'title': 'Gbedu dance cover',
      'challenge': _past(now),
      'rank': 7,
      'stars': 9840,
      'prize': _usd(600),
    },
    {
      'id': 'welcome-video',
      'title': 'Hello Star App',
      'challenge': {
        'id': 'welcome-challenge',
        'title': 'Welcome Challenge',
        'category': 'Welcome',
        'arena': 'other',
        'status': 'ended',
        'endsAt': _at(now, const Duration(days: -230)),
      },
      'bonusStars': 50,
    },
  ],
  'nextCursor': null,
};

// ---------------------------------------------------------------- Results

Json _winners(DateTime now) {
  final amina = _amina('$_img/winners_amina.png');
  return {
    'challenge': _past(now),
    'winner': {
      'rank': 1,
      'creator': amina,
      'stars': 64300,
      'location': 'Abuja, Nigeria',
      'prize': _usd(5000),
    },
    'winningEntry': {
      'id': 'sahel-soul',
      'creator': amina,
      'title': 'Sahel Soul, the winning routine',
      'thumbnailUrl': '$_img/winners_entry_sahel_soul.jpg',
      'stars': 64300,
      'viewCount': 1200000,
    },
    'runnersUp': [
      {
        'rank': 2,
        'creator': _creator(
          'chidi',
          'Chidi Eze',
          'chidi_eze',
          avatar: '$_img/winners_chidi.png',
        ),
        'stars': 31200,
        'location': 'Lagos, NG',
        'prize': _usd(2000),
      },
      {
        'rank': 3,
        'creator': _kofi(),
        'stars': 28400,
        'location': 'Accra, GH',
        'prize': _usd(1000),
      },
    ],
  };
}

const Json _tierLevelUp = {
  'tier': 'stellar',
  'minStars': 2001,
  'maxStars': 10000,
  'stars': 2050,
  'blurb': 'Real influence is forming. Brands are starting to notice you.',
  'perks': [
    'Stellar badge on your profile and posts',
    'Priority placement in Rising Stars',
    'Eligible for Scout Requests from verified companies',
  ],
};
