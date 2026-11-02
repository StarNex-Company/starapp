import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

/// A post in the home feed (`GET /feed`).
class Post {
  const Post({
    required this.id,
    required this.author,
    required this.createdAt,
    required this.text,
    this.authorHasStory = false,
    this.mediaUrls = const [],
    this.mediaCount = 0,
    this.stars = 0,
    this.comments = 0,
    this.reposts = 0,
    this.starredBy = const [],
    this.isStarred = false,
    this.isBookmarked = false,
    this.isReported = false,
  });

  factory Post.fromJson(Json json) {
    final mediaUrls = readStrings(json['mediaUrls']);
    return Post(
      id: json['id'] as String,
      author: CreatorSummary.fromJson(json['author'] as Json),
      authorHasStory: json['authorHasStory'] as bool? ?? false,
      createdAt: readDate(json['createdAt']) ?? DateTime.now(),
      text: json['text'] as String? ?? '',
      mediaUrls: mediaUrls,
      mediaCount: readInt(json['mediaCount'], mediaUrls.length),
      stars: readInt(json['stars']),
      comments: readInt(json['comments']),
      reposts: readInt(json['reposts']),
      starredBy: readList(json['starredBy'], CreatorSummary.fromJson),
      isStarred: json['isStarred'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isReported: json['isReported'] as bool? ?? false,
    );
  }

  /// What stars, bookmarks and reports are keyed by.
  final String id;
  final CreatorSummary author;

  /// Rings the author's avatar.
  final bool authorHasStory;
  final DateTime createdAt;
  final String text;

  /// Preview images; [mediaCount] is the total attached to the post. A single
  /// image is shown large, several as a thumbnail strip.
  final List<String> mediaUrls;
  final int mediaCount;
  final int stars;
  final int comments;
  final int reposts;

  /// A few of the people who starred it, for the "Starred by" avatars.
  final List<CreatorSummary> starredBy;

  /// The signed-in user's own star, bookmark and report.
  final bool isStarred;
  final bool isBookmarked;
  final bool isReported;

  Json toJson() => {
    'id': id,
    'author': author.toJson(),
    'authorHasStory': authorHasStory,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'text': text,
    'mediaUrls': mediaUrls,
    'mediaCount': mediaCount,
    'stars': stars,
    'comments': comments,
    'reposts': reposts,
    'starredBy': [for (final c in starredBy) c.toJson()],
    'isStarred': isStarred,
    'isBookmarked': isBookmarked,
    'isReported': isReported,
  };

  Post copyWith({
    bool? isStarred,
    int? stars,
    bool? isBookmarked,
    bool? isReported,
  }) => Post(
    id: id,
    author: author,
    authorHasStory: authorHasStory,
    createdAt: createdAt,
    text: text,
    mediaUrls: mediaUrls,
    mediaCount: mediaCount,
    stars: stars ?? this.stars,
    comments: comments,
    reposts: reposts,
    starredBy: starredBy,
    isStarred: isStarred ?? this.isStarred,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    isReported: isReported ?? this.isReported,
  );
}
