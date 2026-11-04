import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/models/company.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';
import 'package:starapp/features/scout/data/models/open_call_filters.dart';
import 'package:starapp/features/scout/data/models/scout_request.dart';
import 'package:starapp/features/scout/data/models/talent_category.dart';
import 'package:starapp/features/scout/data/repositories/scout_repository.dart';

/// Serves JSON fixtures shaped like the API's responses through the real
/// `fromJson`, and remembers what the user does (applies, follows, request
/// answers) so mock mode stays consistent across screens. Mutations wait
/// [latency] to show their pending states.
class MockScoutRepository implements ScoutRepository {
  MockScoutRepository({this.latency = const Duration(milliseconds: 400)});

  final Duration latency;

  final _applied = <String, Json>{};
  final _following = <String, bool>{};
  final _requestStatus = <String, ScoutRequestStatus>{};
  final _requestConversation = <String, String>{};
  final _reported = <String>{};

  @override
  Future<Paged<OpenCallSummary>> listOpenCalls(
    OpenCallFilters filters, {
    String? cursor,
  }) async {
    final now = DateTime.now();
    final matches = _openCalls(now).where((c) => _matches(c, filters, now));
    return Paged.fromJson({
      'items': [
        for (final call in matches)
          if (call['isFeatured'] == true) call,
        for (final call in matches)
          if (call['isFeatured'] != true) call,
      ],
      'nextCursor': null,
    }, OpenCallSummary.fromJson);
  }

  @override
  Future<int> countOpenCalls(OpenCallFilters filters) async {
    final now = DateTime.now();
    return _openCalls(now).where((c) => _matches(c, filters, now)).length;
  }

  @override
  Future<OpenCall> getOpenCall(String id) async =>
      OpenCall.fromJson(_call(id, DateTime.now()));

  @override
  Future<Application> applyToOpenCall(String id) async {
    await Future<void>.delayed(latency);
    final now = DateTime.now();
    final call = _call(id, now);
    final application = {
      'id': 'app-$id',
      'title': call['title'],
      'company': call['company'],
      'appliedAt': now.toUtc().toIso8601String(),
      'status': ApplicationStatus.sent.name,
      'openCallId': id,
      'category': call['category'],
    };
    _applied[id] = application;
    return Application.fromJson(application);
  }

  @override
  Future<ApplicationsSummary> getApplicationsSummary() async {
    final active = [
      for (final a in _applications(DateTime.now()))
        if (_isActive(a)) a,
    ];
    int count(ApplicationStatus status) =>
        active.where((a) => a['status'] == status.name).length;
    return ApplicationsSummary.fromJson({
      'sent': count(ApplicationStatus.sent),
      'inReview': count(ApplicationStatus.inReview),
      'shortlisted': count(ApplicationStatus.shortlisted),
      'total': active.length,
    });
  }

  @override
  Future<Paged<Application>> listMyApplications({
    required bool active,
    String? cursor,
  }) async => Paged.fromJson({
    'items': [
      for (final a in _applications(DateTime.now()))
        if (_isActive(a) == active) a,
    ],
    'nextCursor': null,
  }, Application.fromJson);

  @override
  Future<Company> getCompany(String id) async {
    final summary = _companies[id];
    if (summary == null) throw const NotFoundException();
    final now = DateTime.now();
    final extras = _companyExtras(now)[id] ?? const <String, Object?>{};
    final followedNow = _following[id];
    final followedBefore = extras['isFollowing'] == true;
    final followers = readInt(extras['followersCount']);
    return Company.fromJson({
      ...summary,
      ...extras,
      'isFollowing': followedNow ?? followedBefore,
      'followersCount': switch ((followedNow, followedBefore)) {
        (true, false) => followers + 1,
        (false, true) => followers - 1,
        _ => followers,
      },
      'openRoles': [
        for (final call in _openCalls(now))
          if ((call['company'] as Json)['id'] == id) call,
      ],
    });
  }

  @override
  Future<void> followCompany(String id) async {
    await Future<void>.delayed(latency);
    _following[id] = true;
  }

  @override
  Future<void> unfollowCompany(String id) async {
    await Future<void>.delayed(latency);
    _following[id] = false;
  }

  @override
  Future<List<ScoutRequest>> listScoutRequests() async => [
    for (final request in _requests(DateTime.now()))
      if (request['status'] == ScoutRequestStatus.pending.name)
        ScoutRequest.fromJson(request),
  ];

  @override
  Future<ScoutRequest> getScoutRequest(String id) async {
    final request = _requests(DateTime.now()).where((r) => r['id'] == id);
    if (request.isEmpty) throw const NotFoundException();
    return ScoutRequest.fromJson(request.first);
  }

  @override
  Future<String> acceptScoutRequest(String id) async {
    await Future<void>.delayed(latency);
    _requestStatus[id] = ScoutRequestStatus.accepted;
    return _requestConversation[id] ??= _threadOf(id, DateTime.now());
  }

  @override
  Future<String> askAboutScoutRequest(String id) async {
    await Future<void>.delayed(latency);
    return _requestConversation[id] ??= _threadOf(id, DateTime.now());
  }

  /// The inbox thread a request opens: Afrowave's is the mock inbox's
  /// scout thread (`c-afrowave`); any other is `c-<companyId>`, which the
  /// mock inbox opens as a new, empty thread with that company.
  String _threadOf(String requestId, DateTime now) {
    if (requestId == 'sr-gbedu') return 'c-afrowave';
    final request = _requestFixtures(
      now,
    ).firstWhere((r) => r['id'] == requestId);
    return 'c-${(request['company'] as Json)['id']}';
  }

  @override
  Future<void> declineScoutRequest(String id) async {
    await Future<void>.delayed(latency);
    _requestStatus[id] = ScoutRequestStatus.declined;
  }

  @override
  Future<void> reportScoutRequest(String id, {String? reason}) async {
    await Future<void>.delayed(latency);
    _reported.add(id);
  }

  Json _call(String id, DateTime now) {
    final call = _allCalls(now).where((c) => c['id'] == id);
    if (call.isEmpty) throw const NotFoundException();
    return call.first;
  }

  /// Calls still accepting applications.
  Iterable<Json> _openCalls(DateTime now) =>
      _allCalls(now).where((c) => readDate(c['closesAt'])!.isAfter(now));

  /// Every fixture call with the user's applications applied on top.
  List<Json> _allCalls(DateTime now) => [
    for (final call in _callFixtures(now))
      {
        ...call,
        if (_applied[call['id']] case final Json application)
          'myStatus': application['status'],
      },
  ];

  List<Json> _applications(DateTime now) => [
    ..._applied.values.toList().reversed,
    ..._applicationFixtures(now),
  ];

  List<Json> _requests(DateTime now) => [
    for (final request in _requestFixtures(now))
      {
        ...request,
        if (_requestStatus[request['id']] case final status?)
          'status': status.name,
        'conversationId':
            _requestConversation[request['id']] ?? request['conversationId'],
        if (_reported.contains(request['id'])) 'reportedByMe': true,
      },
  ];

  static bool _isActive(Json application) => readEnum(
    ApplicationStatus.values,
    application['status'],
    ApplicationStatus.sent,
  ).isActive;

  static bool _matches(Json call, OpenCallFilters f, DateTime now) {
    final cities = readStrings(call['cities']);
    final query = f.query?.trim().toLowerCase() ?? '';
    final haystack = [
      call['title'],
      (call['company'] as Json)['name'],
      ...cities,
    ].join(' ').toLowerCase();
    final closesAt = readDate(call['closesAt'])!;
    final postedAt = readDate(call['postedAt'])!;
    return (query.isEmpty || haystack.contains(query)) &&
        (f.category == null || call['category'] == f.category!.name) &&
        switch (f.window) {
          null || OpenCallWindow.openNow => true,
          OpenCallWindow.closingThisWeek =>
            closesAt.difference(now) <= const Duration(days: 7),
          OpenCallWindow.newlyPosted =>
            now.difference(postedAt) <= const Duration(hours: 48),
        } &&
        (f.city == null || cities.contains(f.city)) &&
        (!f.remoteOnly || call['isRemote'] == true) &&
        // The mock user sings, produces and writes songs.
        (!f.matchMyTalents || call['category'] == TalentCategory.music.name);
  }
}

const _avatars = [
  'assets/images/scout/scout_applicant_1.png',
  'assets/images/scout/scout_applicant_2.png',
  'assets/images/scout/scout_applicant_3.png',
];

const _companies = <String, Json>{
  'afrowave-records': {
    'id': 'afrowave-records',
    'name': 'Afrowave Records',
    'logoUrl': null,
    'type': 'Record label',
    'city': 'Lagos',
    'country': 'Nigeria',
    'isVerified': true,
  },
  'lagos-film-collective': {
    'id': 'lagos-film-collective',
    'name': 'Lagos Film Collective',
    'type': 'Film studio',
    'city': 'Lagos',
    'country': 'Nigeria',
    'isVerified': true,
  },
  'kora-studios': {
    'id': 'kora-studios',
    'name': 'Kora Studios',
    'type': 'Creative agency',
    'city': 'Nairobi',
    'country': 'Kenya',
    'isVerified': true,
  },
  'pulse-tv': {
    'id': 'pulse-tv',
    'name': 'Pulse TV',
    'type': 'Broadcaster',
    'city': 'Accra',
    'country': 'Ghana',
    'isVerified': true,
  },
  'nova-sports': {
    'id': 'nova-sports',
    'name': 'Nova Sports',
    'type': 'Sports media',
    'city': 'Johannesburg',
    'country': 'South Africa',
    'isVerified': true,
  },
};

const _verificationNote =
    'Business registration, website and payment method checked by Star App.';

String _iso(DateTime time) => time.toUtc().toIso8601String();

Json _money(int amountMinor, String currency) => {
  'amountMinor': amountMinor,
  'currency': currency,
};

/// `GET /companies/{id}` beyond the summary. Afrowave fills every section;
/// Kora has no rating or testimonials, so those sections hide.
Map<String, Json> _companyExtras(DateTime now) => {
  'afrowave-records': {
    'coverUrl': 'assets/images/shared/arena_studio.jpg',
    'followersCount': 24600,
    'foundedYear': 2014,
    'verificationNote': _verificationNote,
    'rating': 4.8,
    'reviewsCount': 36,
    'artistsSignedCount': 48,
    'creatorsHiredCount': 12,
    'testimonials': [
      {
        'quote':
            'Paid on time and treated us like professionals. The tour '
            'changed my career.',
        'authorName': 'Kofi M.',
        'authorTier': 'superNova',
        'createdAt': _iso(now.subtract(const Duration(days: 40))),
      },
    ],
  },
  'kora-studios': {
    'followersCount': 8900,
    'foundedYear': 2019,
    'verificationNote': _verificationNote,
    'creatorsHiredCount': 5,
  },
};

/// Every call the screens can reach, as `GET /scout/calls/{id}` returns it;
/// lists read the same maps through `OpenCallSummary.fromJson`.
List<Json> _callFixtures(DateTime now) {
  String days(int d) => _iso(now.add(Duration(days: d)));

  return [
    {
      'id': 'gold-coast-tour',
      'company': _companies['afrowave-records'],
      'title': 'Lead Vocalist, "Gold Coast" Summer Tour 2027',
      'category': 'music',
      'tags': ['Paid tour'],
      'cities': [
        'Lagos',
        'Accra',
        'Abuja',
        'Kumasi',
        'Ibadan',
        'Cape Coast',
        'Port Harcourt',
      ],
      'isRemote': false,
      'budget': {
        'min': _money(250000000, 'NGN'),
        'max': _money(400000000, 'NGN'),
        'unit': 'perShow',
      },
      'startDate': _iso(DateTime(now.year + 1, 6, 6)),
      'endDate': _iso(DateTime(now.year + 1, 8, 29)),
      'applicantsCount': 142,
      'applicantAvatarUrls': _avatars,
      'closesAt': days(6),
      'postedAt': days(-5),
      'isFeatured': true,
      'isEligible': true,
      'locationLabel': 'Rehearsals in Lagos',
      'scheduleNote': '12 shows',
      'description':
          "We're looking for a lead vocalist with stage presence and "
          'Afro-soul range to headline our West Africa summer tour, backed '
          'by a 7-piece band.',
      'requirements': [
        {'label': 'Verified Star App creator', 'isMet': true},
        {'label': 'Rising Nova tier or above', 'isMet': true},
        {'label': '2+ live performance videos', 'isMet': true},
        {
          'label': 'Available for rehearsals in May ${now.year + 1}',
          'isMet': true,
        },
      ],
    },
    {
      'id': 'eko-nights-dancers',
      'company': _companies['lagos-film-collective'],
      'title': 'Background dancers for the "Eko Nights" feature film',
      'category': 'dance',
      'cities': ['Lagos'],
      'budget': {'min': _money(18000000, 'NGN'), 'unit': 'perDay'},
      'applicantsCount': 38,
      'closesAt': days(19),
      'postedAt': days(-1),
      'locationLabel': 'On set in Lekki',
      'scheduleNote': '5 shoot days',
      'description':
          'Eight dancers for two club scenes in a Nollywood feature. '
          'Afrobeats and amapiano styles; choreography taught on set.',
      'requirements': [
        {'label': 'Verified Star App creator', 'isMet': true},
        {'label': 'A dance video on your profile', 'isMet': true},
      ],
    },
    {
      'id': 'kora-choreographer',
      'company': _companies['kora-studios'],
      'title': 'Choreographer for a music video',
      'category': 'dance',
      'cities': ['Nairobi'],
      'isRemote': true,
      'budget': {'min': _money(120000, 'USD'), 'unit': 'flat'},
      'applicantsCount': 21,
      'closesAt': days(2),
      'postedAt': days(-8),
      'myStatus': 'inReview',
      'locationLabel': 'Remote planning, shoot in Nairobi',
      'description':
          'Create and teach the routine for an Afro-house single. Remote '
          'sessions with the artist, then two days on set.',
      'requirements': [
        {'label': 'Choreography reel', 'isMet': true},
      ],
    },
    {
      'id': 'pulse-comedy-cohost',
      'company': _companies['pulse-tv'],
      'title': 'Comedy sketch co-host (8 episodes)',
      'category': 'comedy',
      'cities': ['Accra'],
      'budget': {'min': _money(900000, 'GHS'), 'unit': 'flat'},
      'applicantsCount': 57,
      'closesAt': days(11),
      'postedAt': days(-4),
      'locationLabel': 'Studio in Osu, Accra',
      'scheduleNote': '8 episodes',
      'description':
          'Co-host a weekly sketch show with improv segments and street '
          'interviews.',
      'requirements': [
        {'label': 'A comedy video on your profile', 'isMet': true},
      ],
    },
    {
      'id': 'nova-halftime',
      'company': _companies['nova-sports'],
      'title': 'Halftime show performers',
      'category': 'dance',
      'cities': ['Johannesburg'],
      'budget': {'min': _money(1800000, 'ZAR'), 'unit': 'flat'},
      'applicantsCount': 12,
      'closesAt': days(30),
      'postedAt': days(-2),
      'isEligible': false,
      'locationLabel': 'FNB Stadium',
      'description':
          'A troupe of twelve for a cup-final halftime show, with two '
          'weeks of rehearsals.',
      'requirements': [
        {'label': 'Verified Star App creator', 'isMet': true},
        {'label': 'Stellar tier or above', 'isMet': false},
      ],
    },
    {
      'id': 'gbedu-backup-dancers',
      'company': _companies['afrowave-records'],
      'title': 'Backup dancers, "Gbedu" video',
      'category': 'dance',
      'cities': ['Lagos'],
      'budget': {'min': _money(85000000, 'NGN'), 'unit': 'flat'},
      'startDate': days(13),
      'endDate': days(15),
      'applicantsCount': 64,
      'closesAt': days(9),
      'postedAt': days(-1),
      'locationLabel': 'Lekki, Lagos',
      'scheduleNote': '3 shoot days',
      'description': 'Four backup dancers for the "Gbedu" music video.',
      'requirements': [
        {'label': 'Verified Star App creator', 'isMet': true},
      ],
    },
    {
      // Closed: reached from My Applications only.
      'id': 'pulse-brand-voice',
      'company': _companies['pulse-tv'],
      'title': 'Brand voice, Pulse TV ad',
      'category': 'acting',
      'cities': ['Accra'],
      'isRemote': true,
      'budget': {'min': _money(450000, 'GHS'), 'unit': 'flat'},
      'applicantsCount': 88,
      'closesAt': days(-20),
      'postedAt': days(-45),
      'myStatus': 'shortlisted',
      'locationLabel': 'Record from home',
      'description': 'The voice of our new season campaign on TV and radio.',
      'requirements': [
        {'label': 'A voice sample', 'isMet': true},
      ],
    },
  ];
}

/// `GET /scout/applications`: every state the list shows.
List<Json> _applicationFixtures(DateTime now) {
  String ago(int days) => _iso(now.subtract(Duration(days: days)));

  return [
    {
      'id': 'app-gbedu-backup',
      'title': 'Backup dancers, "Gbedu" video',
      'company': _companies['afrowave-records'],
      'category': 'dance',
      'appliedAt': _iso(now.subtract(const Duration(hours: 6))),
      'status': 'sent',
      'openCallId': 'gbedu-backup-dancers',
    },
    {
      'id': 'app-kora-choreographer',
      'title': 'Choreographer for a music video',
      'company': _companies['kora-studios'],
      'category': 'dance',
      'appliedAt': ago(23),
      'status': 'inReview',
      'openCallId': 'kora-choreographer',
    },
    {
      'id': 'app-pulse-brand-voice',
      'title': 'Brand voice, Pulse TV ad',
      'company': _companies['pulse-tv'],
      'category': 'acting',
      'appliedAt': ago(28),
      'status': 'shortlisted',
      'openCallId': 'pulse-brand-voice',
    },
    {
      'id': 'app-lagos-love',
      'title': 'Backing dancer, "Lagos Love" video',
      'company': _companies['afrowave-records'],
      'category': 'dance',
      'appliedAt': ago(12),
      'updatedAt': ago(1),
      'status': 'offer',
      'scoutRequestId': 'sr-lagos-love',
      'conversationId': 'c-afrowave',
    },
    {
      'id': 'app-kora-live',
      'title': 'Backing vocals, Kora Live',
      'company': _companies['kora-studios'],
      'category': 'music',
      'appliedAt': ago(110),
      'updatedAt': ago(72),
      'status': 'completed',
      'transactionId': 'tx-scout-kora',
    },
  ];
}

/// `GET /scout/requests/{id}`: two pending requests, one new with a brief
/// and a Stars bonus.
List<Json> _requestFixtures(DateTime now) => [
  {
    'id': 'sr-gbedu',
    'company': _companies['afrowave-records'],
    'roleTitle': 'Featured Dancer, "Gbedu" Music Video',
    'budget': _money(85000000, 'NGN'),
    'shootStart': _iso(now.add(const Duration(days: 13))),
    'shootEnd': _iso(now.add(const Duration(days: 15))),
    'location': 'Lekki, Lagos',
    'isPaid': true,
    'contractDays': 3,
    'senderName': 'Tobi Adeyemi',
    'senderTitle': 'Talent Lead',
    'senderAvatarUrl': 'assets/images/scout/scout_sender_tobi.png',
    'message':
        'Hi Emmanuel! Our team loved your Afro-Beats Clash entry and your '
        "stage presence. We'd love you as the featured dancer in our next "
        "video. The full brief is attached, and we're happy to answer any "
        'questions.',
    'sentAt': _iso(now.subtract(const Duration(hours: 2))),
    'attachments': [
      {
        'id': 'att-gbedu-brief',
        'kind': 'document',
        'fileName': 'Gbedu_brief.pdf',
        'url': 'https://cdn.starapp.io/scout/sr-gbedu/Gbedu_brief.pdf',
        'mimeType': 'application/pdf',
        'sizeBytes': 1258291,
        'pageCount': 4,
      },
    ],
    'starsBonus': 200,
    'status': 'pending',
    'isNew': true,
    'reportedByMe': false,
  },
  {
    'id': 'sr-kora-live',
    'company': _companies['kora-studios'],
    'roleTitle': 'Backing vocals, Kora Live 2027',
    'budget': _money(12000000, 'KES'),
    'shootStart': _iso(now.add(const Duration(days: 40))),
    'shootEnd': _iso(now.add(const Duration(days: 41))),
    'location': 'Westlands, Nairobi',
    'isPaid': true,
    'contractDays': 2,
    'senderName': 'Wanjiru Kamau',
    'senderTitle': 'Casting Director',
    'message':
        'We need two backing vocalists for our live session series. Your '
        'harmonies on "Late night vocal run" were exactly the sound.',
    'sentAt': _iso(now.subtract(const Duration(days: 2))),
    'status': 'pending',
    'isNew': false,
  },
];
