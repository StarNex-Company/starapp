import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/features/profile/data/models/connections.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';
import 'package:starapp/features/profile/data/repositories/mock_connections_repository.dart';
import 'package:starapp/features/profile/data/repositories/mock_creator_repository.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_style.dart';

void main() {
  const creators = MockCreatorRepository();
  const connections = MockConnectionsRepository();

  test('Chidi is the fully designed profile', () async {
    final chidi = await creators.fetchCreator('chidi');

    expect(chidi.name, 'Chidi Eze');
    expect(chidi.tier, CreatorTier.superNova);
    expect(chidi.hasStory, isTrue);
    expect(chidi.isFollowing, isFalse, reason: 'shows the Follow row');
    expect(
      chidi.featuredChallenge?.headline,
      'Ranked #4 in Afro-Dance Takeover',
    );
    expect(chidi.challenges.map((c) => c.badge), ['Top 10', 'Winner', 'Top 3']);
    expect(chidi.challenges[1].subtitle, endsWith(r'winner · $1,500 prize'));
    expect(chidi.stats, isNotNull);

    final posts = await creators.fetchPosts('chidi');
    expect(posts.items, hasLength(6));
    expect(posts.items.first.isEntry, isTrue);
    expect(posts.hasMore, isFalse);
  });

  test('Ayeni is already followed and shows the co-founder badge', () async {
    final ayeni = await creators.fetchCreator('ayeni');

    expect(ayeni.isFollowing, isTrue);
    expect(ayeni.isCoFounder, isTrue);
    expect(ayeni.followersWhen(following: true), ayeni.followers);
    expect(ayeni.followersWhen(following: false), ayeni.followers - 1);
    expect(ayeni.challenges.map((c) => c.badge), ['Entered', 'Done']);
  });

  test('unknown ids get a bare profile built from the id', () async {
    final p = await creators.fetchCreator('sarah-angel');

    expect(p.name, 'Sarah Angel');
    expect(p.handle, 'sarah-angel');
    expect(p.avatarUrl, isNull);
    expect(p.tier, CreatorTier.shootingStar);
    expect(p.stats, isNull);
    expect((await creators.fetchPosts('sarah-angel')).items, isEmpty);
  });

  test('profiles and posts round-trip through toJson', () async {
    for (final id in ['chidi', 'ayeni', 'someone-new']) {
      final p = await creators.fetchCreator(id);
      expect(CreatorProfile.fromJson(p.toJson()).toJson(), p.toJson());
      for (final post in (await creators.fetchPosts(id)).items) {
        expect(CreatorPost.fromJson(post.toJson()).toJson(), post.toJson());
      }
    }
  });

  test('connections parse, search and round-trip', () async {
    final all = await connections.fetchConnections(
      null,
      ConnectionsTab.followers,
    );
    expect(all.items, isNotEmpty);
    expect(all.items.any((c) => c.followsYou), isTrue);
    expect(all.items.any((c) => !c.followsYou), isTrue);
    for (final c in all.items) {
      expect(Connection.fromJson(c.toJson()).toJson(), c.toJson());
    }

    final ownList = await connections.fetchConnections(
      'ayeni',
      ConnectionsTab.following,
    );
    expect(ownList.items.any((c) => c.id == 'ayeni'), isFalse);

    final search = await connections.fetchConnections(
      null,
      ConnectionsTab.following,
      query: 'kola',
    );
    expect(search.items.map((c) => c.id), ['kola-bankole']);
  });
}
