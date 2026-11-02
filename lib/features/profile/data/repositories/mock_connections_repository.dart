import 'package:starapp/core/network/paged.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/connections.dart';
import 'package:starapp/features/profile/data/repositories/connections_repository.dart';

/// Serves [_people], shaped like a `GET /creators/{id}/followers` page,
/// through the real `fromJson`. Every list holds the same people, filtered
/// by the query; a creator never lists themself. They're all in the
/// session's mock following set, so the rows start as "Following".
class MockConnectionsRepository implements ConnectionsRepository {
  const MockConnectionsRepository();

  @override
  Future<Paged<Connection>> fetchConnections(
    String? creatorId,
    ConnectionsTab tab, {
    String query = '',
    String? cursor,
  }) async {
    final q = query.trim().toLowerCase();
    bool matches(Json p) =>
        q.isEmpty ||
        '${p['name']}'.toLowerCase().contains(q) ||
        '${p['handle']}'.toLowerCase().contains(q);

    return Paged.fromJson({
      'items': [
        for (final p in _people)
          if (p['id'] != creatorId && matches(p)) p,
      ],
      'nextCursor': null,
    }, Connection.fromJson);
  }
}

const _img = 'assets/images/profile';
const _challenges = 'assets/images/challenges';

const _people = <Json>[
  {
    'id': 'amina',
    'name': 'Amina K.',
    'handle': 'amina_k',
    'avatarUrl': 'assets/images/search/creator_amina_k.png',
    'tier': 'universeIcon',
    'isVerified': true,
    'followsYou': true,
  },
  {
    'id': 'efe-okafor',
    'name': 'Efe Okafor',
    'handle': 'efe_okafor',
    'avatarUrl': '$_img/connections_efe_okafor.png',
    'tier': 'stellar',
    'followsYou': true,
  },
  {
    'id': 'ayeni',
    'name': 'Ayeni Micheal',
    'handle': 'ayeni_micheal',
    'avatarUrl': '$_img/connections_ayeni_micheal.png',
    'tier': 'shootingStar',
    'isVerified': true,
    'followsYou': true,
  },
  {
    'id': 'silver-sonik',
    'name': 'Silver Sonik',
    'handle': 'silver_sonik',
    'avatarUrl': '$_img/connections_silver_sonik.png',
    'tier': 'superNova',
  },
  {
    'id': 'kola-bankole',
    'name': 'Kola Bankole',
    'handle': 'kola_visuals',
    'avatarUrl': '$_img/connections_kola_bankole.png',
    'tier': 'risingNova',
    'followsYou': true,
  },
  {
    'id': 'tunde-beats',
    'name': 'Tunde Beats',
    'handle': 'tunde_beats',
    'avatarUrl': '$_challenges/detail_avatar_tunde.png',
    'tier': 'stellar',
  },
  {
    'id': 'maya-lin',
    'name': 'Maya Lin',
    'handle': 'maya_lin',
    'avatarUrl': '$_challenges/detail_avatar_maya.png',
    'tier': 'universeIcon',
  },
  {
    'id': 'david-cole',
    'name': 'David Cole',
    'handle': 'david_cole',
    'avatarUrl': '$_challenges/detail_avatar_david.png',
    'tier': 'risingNova',
    'followsYou': true,
  },
  {
    'id': 'sarah-angel',
    'name': 'Sarah Angel',
    'handle': 'sarah_angel',
    'avatarUrl': '$_img/connections_sarah_angel.png',
    'tier': 'shootingStar',
  },
];
