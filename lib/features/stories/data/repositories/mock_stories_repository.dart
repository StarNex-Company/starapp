import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/stories/data/models/new_story.dart';
import 'package:starapp/features/stories/data/models/story_creator.dart';
import 'package:starapp/features/stories/data/repositories/stories_repository.dart';

/// Serves the fixtures below, shaped like the `GET /stories` and
/// `GET /stories/{creatorId}` responses, through the real `fromJson`.
/// Changes are accepted and forgotten.
class MockStoriesRepository implements StoriesRepository {
  const MockStoriesRepository();

  @override
  Future<List<StoryCreator>> fetchRow(StoryLayout row) async =>
      readList(_rows(DateTime.now())[row], StoryCreator.fromJson);

  @override
  Future<StoryCreator?> fetchCreator(String storyKey) async {
    for (final row in StoryLayout.values) {
      for (final creator in await fetchRow(row)) {
        if (creator.storyKey == storyKey) return creator;
      }
    }
    return null;
  }

  @override
  Future<void> markViewed(String storyId) async {}

  @override
  Future<void> setStarred(String storyId, {required bool starred}) async {}

  @override
  Future<void> setLiked(String storyId, {required bool liked}) async {}

  @override
  Future<void> reply(String storyId, String text) async {}

  @override
  Future<void> createStory(
    String filePath, {
    String caption = '',
    StorySettings settings = const StorySettings(),
  }) async {}
}

const _img = 'assets/images/stories';

/// A fixture image: a bare name in [_img], or a full asset path.
String _asset(String name) => name.startsWith('assets/') ? name : '$_img/$name';

/// `GET /stories?row=home` and `?row=discover`. Photos, avatars and copy
/// come from the STAR-APP design.
Map<StoryLayout, List<Json>> _rows(DateTime now) {
  Json story(
    String id, {
    required int hoursAgo,
    String? photo,
    String? text,
    String? caption,
    String fit = 'cover',
  }) {
    final createdAt = now.subtract(Duration(hours: hoursAgo));
    return {
      'id': id,
      'mediaUrl': photo == null ? null : _asset(photo),
      'text': text,
      'caption': caption,
      'fit': fit,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'expiresAt': createdAt
          .add(const Duration(hours: 24))
          .toUtc()
          .toIso8601String(),
    };
  }

  Json creator(
    String key,
    String id,
    String name,
    String handle,
    List<Json> stories,
  ) => {
    'storyKey': key,
    'creator': {
      'id': id,
      'name': name,
      'handle': handle,
      // avatar_sarah.png for "sarah-angel".
      'avatarUrl': '$_img/avatar_${id.split('-').first}.png',
      'isVerified': true,
    },
    'stories': stories,
  };

  // Discover's story circles (Amina K., Carlos Silva) both open the design's
  // single "Story — Viewer" frame, so they share its content, and its header
  // (Chidi Eze) opens his profile.
  final discover = [
    story(
      'discover-1',
      hoursAgo: 2,
      photo: 'story_freestyle.jpg',
      caption: "Freestyle session tonight at 8 💃🏾 Who's pulling up?",
    ),
    story(
      'discover-2',
      hoursAgo: 2,
      text: 'Freestyle session tonight at 8 💃🏾',
    ),
    story('discover-3', hoursAgo: 1, text: "Who's pulling up? 👀"),
  ];
  Json chidi(String key) =>
      creator(key, 'chidi', 'Chidi Eze', 'chidi_eze', discover);

  return {
    StoryLayout.home: [
      creator('adeboye', 'adeboye', 'Pastor E.A Adeboye', 'pastor_adeboye', [
        story(
          'adeboye-1',
          hoursAgo: 2,
          photo: 'assets/images/shared/post_adeboye_portrait.jpg',
          caption: 'Sunday service highlights 🙏',
        ),
        story(
          'adeboye-2',
          hoursAgo: 2,
          photo: 'story_adeboye_2.jpg',
          caption: 'Join us this Sunday at Testimony Parish',
          fit: 'contain',
        ),
        story(
          'adeboye-3',
          hoursAgo: 1,
          text: '“Every talent is a gift. Use yours to serve.” 🙏',
        ),
      ]),
      creator('tinubu', 'tinubu', 'President Bola A. Tinubu', 'officialbat', [
        story(
          'tinubu-1',
          hoursAgo: 5,
          photo: 'story_tinubu_1.jpg',
          caption: 'At the youth creative summit today',
        ),
        story(
          'tinubu-2',
          hoursAgo: 4,
          text: 'Proud of our young creatives 🇳🇬\n#EveryTalentDeservesAStage',
        ),
      ]),
      creator('sarah', 'sarah-angel', 'Sarah Angel', 'sarahangel', [
        story(
          'sarah-1',
          hoursAgo: 3,
          photo: 'story_sarah_1.jpg',
          caption: 'Match day energy ⚽',
        ),
        story(
          'sarah-2',
          hoursAgo: 2,
          photo: 'story_sarah_2.jpg',
          caption: 'Post-match smiles 😄',
        ),
      ]),
      creator('funmilayo', 'funmilayo', 'Funmilayo Ade', 'funmilayo_ade', [
        story(
          'funmilayo-1',
          hoursAgo: 6,
          photo: 'story_funmilayo_1.jpg',
          caption: 'Jollof Friday! Recipe video coming soon 🍲',
        ),
      ]),
      creator('gabriel', 'gabriel', 'Gabriel Anyakumen', 'gabriel_anya', [
        story(
          'gabriel-1',
          hoursAgo: 8,
          photo: 'story_gabriel_1.jpg',
          caption: 'New canvas in progress 🎨',
        ),
      ]),
    ],
    StoryLayout.discover: [chidi('amina'), chidi('carlos')],
  };
}
