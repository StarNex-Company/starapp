import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

/// A card in the home story row (`GET /home` → `stories`).
class Story {
  const Story({
    required this.storyKey,
    required this.creator,
    this.coverUrl,
    this.followers = 0,
  });

  factory Story.fromJson(Json json) => Story(
    storyKey: json['storyKey'] as String,
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    coverUrl: json['coverUrl'] as String?,
    followers: readInt(json['followers']),
  );

  /// Opens the story viewer at `/story?creator=<storyKey>`.
  final String storyKey;
  final CreatorSummary creator;

  /// The card's picture, usually the latest story's photo.
  final String? coverUrl;

  /// The creator's follower count.
  final int followers;

  Json toJson() => {
    'storyKey': storyKey,
    'creator': creator.toJson(),
    'coverUrl': coverUrl,
    'followers': followers,
  };
}
