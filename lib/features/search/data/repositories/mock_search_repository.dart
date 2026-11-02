import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/search/data/models/search_models.dart';
import 'package:starapp/features/search/data/repositories/search_repository.dart';

/// Answers queries from the fixtures below, shaped like the API's JSON and
/// parsed through the real `fromJson`. Each fixture carries the extra words
/// it should be found by (talents, genres, cities), standing in for the
/// server's search index.
class MockSearchRepository implements SearchRepository {
  const MockSearchRepository();

  @override
  Future<SearchResults> search(String query) async {
    final now = DateTime.now();
    return SearchResults.fromJson({
      'creators': [
        for (final (json, words) in _creators)
          if (_matches(query, [
            json['name']! as String,
            json['handle']! as String,
            'creator talent',
            ...words,
          ]))
            json,
      ],
      'challenges': [
        for (final (json, words) in _challenges(now))
          if (_matches(query, [json['title']! as String, 'challenge', ...words]))
            json,
      ],
    });
  }

  @override
  Future<List<String>> fetchTrendingSearches() async => readStrings(_trending);

  @override
  Future<List<String>> fetchRecentSearches() async => readStrings(_recent);

  @override
  Future<void> addRecentSearch(String term) async {}

  @override
  Future<void> removeRecentSearch(String term) async {}

  @override
  Future<void> clearRecentSearches() async {}
}

/// Lower-case letters and digits only, so "Afro-beats" finds "afrobeats" and
/// "#AfroBeatsClash" finds "afrobeatsclash".
String _normalize(String s) =>
    s.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

/// True when every word of [query] appears in [fields].
bool _matches(String query, List<String> fields) {
  final haystack = fields.map(_normalize).join(' ');
  final words = query
      .split(RegExp(r'\s+'))
      .map(_normalize)
      .where((w) => w.isNotEmpty);
  return words.isNotEmpty && words.every(haystack.contains);
}

const _images = 'assets/images/search';

/// `GET /search/recent`.
const _recent = ['Afro-beats producer', 'Amina K.', 'Lagos dance challenge'];

/// `GET /search/trending`.
const _trending = [
  '#AfroBeatsClash',
  'Gospel Voices',
  'Street Dance Battle',
  'Comedy skits',
  'Tunde Beats',
];

/// `creators` of `GET /search?q=`, each with its index words.
const _creators = <(Json, List<String>)>[
  (
    {
      'id': 'tunde-beats',
      'name': 'Tunde Beats',
      'handle': 'tunde_beats',
      'avatarUrl': '$_images/creator_tunde_beats.png',
      'tier': 'universeIcon',
    },
    ['universe icon', 'afrobeats', 'producer', 'music', 'production', 'lagos'],
  ),
  (
    {
      'id': 'amina',
      'name': 'Amina K.',
      'handle': 'amina_k',
      'avatarUrl': '$_images/creator_amina_k.png',
      'tier': 'universeIcon',
    },
    [
      'universe icon',
      'afrobeats',
      'singer',
      'singing',
      'vocals',
      'gospel',
      'voices',
      'music',
    ],
  ),
  (
    {
      'id': 'kofi-mensah',
      'name': 'Kofi Mensah',
      'handle': 'kofi_mensah',
      'avatarUrl': '$_images/creator_kofi_mensah.png',
      'tier': 'superNova',
    },
    ['super nova', 'afrodance', 'dance', 'dancer', 'street', 'comedy', 'skits'],
  ),
];

/// `challenges` of `GET /search?q=`: live, upcoming and ended ones, each
/// with its index words.
List<(Json, List<String>)> _challenges(DateTime now) {
  String at(Duration fromNow) => now.add(fromNow).toUtc().toIso8601String();

  return [
    (
      {
        'id': 'afro-beats-clash',
        'title': 'Afro-Beats Producer & Vocal Clash',
        'status': 'live',
        'entries': 890,
        'endsAt': at(const Duration(days: 4, hours: 18)),
      },
      ['AfroBeatsClash', 'music', 'production', 'singing'],
    ),
    (
      {
        'id': 'afro-dance-takeover',
        'title': 'Afro-Dance Takeover',
        'status': 'ended',
        'entries': 2380,
        'endsAt': at(const Duration(days: -50)),
      },
      ['dance', 'lagos'],
    ),
    (
      {
        'id': 'lagos-dance-challenge',
        'title': 'Lagos Dance Challenge',
        'status': 'live',
        'entries': 1200,
        'endsAt': at(const Duration(days: 2, hours: 6)),
      },
      ['dance', 'street'],
    ),
    (
      {
        'id': 'gospel-voices',
        'title': 'Gospel Voices',
        'status': 'live',
        'entries': 640,
        'endsAt': at(const Duration(days: 6, hours: 2)),
      },
      ['singing', 'vocals', 'music'],
    ),
    (
      {
        'id': 'street-dance-battle',
        'title': 'Street Dance Battle',
        'status': 'upcoming',
        'entries': 412,
        'startsAt': at(const Duration(days: 3)),
      },
      ['dance', 'battle'],
    ),
    (
      {
        'id': 'comedy-skits-showdown',
        'title': 'Comedy Skits Showdown',
        'status': 'live',
        'entries': 2100,
        'endsAt': at(const Duration(days: 1, hours: 4)),
      },
      ['comedy', 'skits', 'acting'],
    ),
  ];
}
