import 'package:starapp/core/utils/json.dart';

/// One of the signed-in user's own video posts (`GET /me/posts/{id}`), shown
/// full screen by `MyPostPage`. The creator row comes from the session's
/// current user.
///
/// There's no video plugin yet, so the page draws [posterUrl] and simulates
/// progress; [videoUrl] is what a player will stream.
class MyPost {
  const MyPost({
    required this.id,
    required this.title,
    required this.caption,
    required this.sound,
    required this.duration,
    required this.createdAt,
    this.videoUrl,
    this.posterUrl,
    this.hashtag,
    this.stars = 0,
    this.comments = 0,
    this.saves = 0,
    this.views = 0,
    this.starsEarned = 0,
    this.isStarred = false,
    this.isSaved = false,
  });

  factory MyPost.fromJson(Json json) => MyPost(
    id: json['id'] as String,
    title: json['title'] as String,
    caption: json['caption'] as String? ?? '',
    sound: json['sound'] as String? ?? '',
    duration: Duration(milliseconds: readInt(json['durationMs'])),
    createdAt: readDate(json['createdAt']) ?? DateTime.now(),
    videoUrl: json['videoUrl'] as String?,
    posterUrl: json['posterUrl'] as String?,
    hashtag: json['hashtag'] as String?,
    stars: readInt(json['stars']),
    comments: readInt(json['comments']),
    saves: readInt(json['saves']),
    views: readInt(json['views']),
    starsEarned: readInt(json['starsEarned']),
    isStarred: json['isStarred'] as bool? ?? false,
    isSaved: json['isSaved'] as bool? ?? false,
  );

  final String id;

  /// Short name used in lists and the post menu, e.g. "Late-night vocal run".
  final String title;
  final String caption;

  /// Sound chip label, e.g. "Original Sound · Emmanuel Ayanleye".
  final String sound;
  final Duration duration;
  final DateTime createdAt;
  final String? videoUrl;
  final String? posterUrl;

  /// Highlighted tag after [caption], e.g. "#AfroBeatsClash".
  final String? hashtag;

  /// Star reactions, comments and saves on the rail, including the user's
  /// own ([isStarred], [isSaved]).
  final int stars;
  final int comments;
  final int saves;

  /// Insights summary in the post menu: views and the Stars (points) the post
  /// has earned.
  final int views;
  final int starsEarned;
  final bool isStarred;
  final bool isSaved;

  Json toJson() => {
    'id': id,
    'title': title,
    'caption': caption,
    'sound': sound,
    'durationMs': duration.inMilliseconds,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'videoUrl': videoUrl,
    'posterUrl': posterUrl,
    'hashtag': hashtag,
    'stars': stars,
    'comments': comments,
    'saves': saves,
    'views': views,
    'starsEarned': starsEarned,
    'isStarred': isStarred,
    'isSaved': isSaved,
  };
}

/// What the user has done to their posts this session: starred, saved or
/// deleted. [starred] and [saved] override the server's [MyPost.isStarred] /
/// [MyPost.isSaved]; counts on the rail move with them.
class MyPostInteractions {
  const MyPostInteractions({
    this.starred = const {},
    this.saved = const {},
    this.deleted = const {},
  });

  final Map<String, bool> starred;
  final Map<String, bool> saved;
  final Set<String> deleted;

  bool isStarred(MyPost post) => starred[post.id] ?? post.isStarred;
  bool isSaved(MyPost post) => saved[post.id] ?? post.isSaved;
  bool isDeleted(String postId) => deleted.contains(postId);

  int starsOf(MyPost post) =>
      post.stars + _delta(isStarred(post), post.isStarred);
  int savesOf(MyPost post) => post.saves + _delta(isSaved(post), post.isSaved);

  static int _delta(bool now, bool before) => (now ? 1 : 0) - (before ? 1 : 0);

  MyPostInteractions copyWith({
    Map<String, bool>? starred,
    Map<String, bool>? saved,
    Set<String>? deleted,
  }) {
    return MyPostInteractions(
      starred: starred ?? this.starred,
      saved: saved ?? this.saved,
      deleted: deleted ?? this.deleted,
    );
  }
}
