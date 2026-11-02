import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

/// How a photo fills the screen: cropped to cover it, or letterboxed on
/// black (posters and flyers).
enum StoryFit { cover, contain }

/// One full-screen story: a photo, or white text on the brand gradient.
class StoryItem {
  const StoryItem({
    required this.id,
    required this.createdAt,
    required this.expiresAt,
    this.mediaUrl,
    this.text,
    this.caption,
    this.fit = StoryFit.cover,
    this.isStarred = false,
    this.isLiked = false,
  });

  factory StoryItem.fromJson(Json json) {
    final createdAt = readDate(json['createdAt']) ?? DateTime.now();
    return StoryItem(
      id: json['id'] as String,
      createdAt: createdAt,
      expiresAt:
          readDate(json['expiresAt']) ??
          createdAt.add(const Duration(hours: 24)),
      mediaUrl: json['mediaUrl'] as String?,
      text: json['text'] as String?,
      caption: json['caption'] as String?,
      fit: readEnum(StoryFit.values, json['fit'], StoryFit.cover),
      isStarred: json['isStarred'] as bool? ?? false,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  final String id;

  /// The photo; null for a text story.
  final String? mediaUrl;

  /// Centered headline of a text story.
  final String? text;

  /// Line above the reply bar, e.g. "Sunday service highlights 🙏".
  final String? caption;
  final StoryFit fit;
  final DateTime createdAt;

  /// When it stops being shown.
  final DateTime expiresAt;

  /// The signed-in user's star (Home's viewer) and like (Discover's).
  final bool isStarred;
  final bool isLiked;

  bool isExpired([DateTime? now]) => !expiresAt.isAfter(now ?? DateTime.now());

  Json toJson() => {
    'id': id,
    'mediaUrl': mediaUrl,
    'text': text,
    'caption': caption,
    'fit': fit.name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'isStarred': isStarred,
    'isLiked': isLiked,
  };

  StoryItem copyWith({bool? isStarred, bool? isLiked}) => StoryItem(
    id: id,
    createdAt: createdAt,
    expiresAt: expiresAt,
    mediaUrl: mediaUrl,
    text: text,
    caption: caption,
    fit: fit,
    isStarred: isStarred ?? this.isStarred,
    isLiked: isLiked ?? this.isLiked,
  );
}

/// A story row: Home's (people the user follows) or Discover's. It also
/// picks the viewer's bottom bar: Home's star / comment / share buttons, or
/// Discover's single like button. The name is sent as `GET /stories?row=`.
enum StoryLayout { home, discover }

/// A creator's active stories (`GET /stories/{creatorId}`, and each entry of
/// `GET /stories`).
class StoryCreator {
  const StoryCreator({
    required this.storyKey,
    required this.creator,
    this.stories = const [],
  });

  factory StoryCreator.fromJson(Json json) => StoryCreator(
    storyKey: json['storyKey'] as String,
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    stories: readList(json['stories'], StoryItem.fromJson),
  );

  /// What story circles open the viewer with (`/story?creator=<storyKey>`);
  /// normally the creator's id.
  final String storyKey;

  /// Whose stories they are; the header opens their profile.
  final CreatorSummary creator;

  /// Oldest first, in playing order.
  final List<StoryItem> stories;

  Json toJson() => {
    'storyKey': storyKey,
    'creator': creator.toJson(),
    'stories': [for (final s in stories) s.toJson()],
  };

  StoryCreator copyWith({List<StoryItem>? stories}) => StoryCreator(
    storyKey: storyKey,
    creator: creator,
    stories: stories ?? this.stories,
  );
}

/// What the story viewer plays: a row of creators in order, starting at
/// [startIndex]. Finishing one creator's stories moves on to the next.
class StoryReel {
  const StoryReel({
    required this.creators,
    required this.startIndex,
    this.layout = StoryLayout.home,
  });

  final List<StoryCreator> creators;
  final int startIndex;
  final StoryLayout layout;

  /// Applies [change] to every copy of the story [storyId] in the reel.
  StoryReel updateStory(
    String storyId,
    StoryItem Function(StoryItem story) change,
  ) => StoryReel(
    creators: [
      for (final c in creators)
        c.stories.any((s) => s.id == storyId)
            ? c.copyWith(
                stories: [
                  for (final s in c.stories) s.id == storyId ? change(s) : s,
                ],
              )
            : c,
    ],
    startIndex: startIndex,
    layout: layout,
  );

  StoryItem? story(String storyId) {
    for (final c in creators) {
      for (final s in c.stories) {
        if (s.id == storyId) return s;
      }
    }
    return null;
  }
}
