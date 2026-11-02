import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

/// The two vertical feeds behind the top tabs.
enum VideosFeed { following, forYou }

/// One clip in a vertical feed (`GET /feed/for-you`, `GET /feed/following`).
/// There is no video player yet, so the feed shows [posterUrl] and
/// simulates playback.
class FeedVideo {
  const FeedVideo({
    required this.id,
    required this.creator,
    required this.caption,
    required this.sound,
    required this.duration,
    required this.createdAt,
    this.location,
    this.videoUrl,
    this.posterUrl,
    this.stars = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.views = 0,
    this.isStarred = false,
    this.isSaved = false,
  });

  factory FeedVideo.fromJson(Json json) => FeedVideo(
    id: json['id'] as String,
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    caption: json['caption'] as String? ?? '',
    sound: json['sound'] as String? ?? '',
    duration: Duration(milliseconds: readInt(json['durationMs'])),
    createdAt: readDate(json['createdAt']) ?? DateTime.now(),
    location: json['location'] as String?,
    videoUrl: json['videoUrl'] as String?,
    posterUrl: json['posterUrl'] as String?,
    stars: readInt(json['stars']),
    comments: readInt(json['comments']),
    shares: readInt(json['shares']),
    saves: readInt(json['saves']),
    views: readInt(json['views']),
    isStarred: json['isStarred'] as bool? ?? false,
    isSaved: json['isSaved'] as bool? ?? false,
  );

  final String id;
  final CreatorSummary creator;

  /// Free text; `#hashtags` in it are highlighted, and a line break starts
  /// a second line.
  final String caption;

  /// Sound chip label, e.g. "Original Sound · Chidi Eze".
  final String sound;

  /// Clip length; sent as `durationMs`.
  final Duration duration;
  final DateTime createdAt;

  /// Where it was posted, shown after the creator's tier, e.g. "Lagos".
  final String? location;

  /// The clip itself, for a player.
  final String? videoUrl;

  /// Frame shown full screen in place of playback.
  final String? posterUrl;

  final int stars;
  final int comments;
  final int shares;
  final int saves;
  final int views;

  /// Whether the signed-in user starred or saved it.
  final bool isStarred;
  final bool isSaved;

  Json toJson() => {
    'id': id,
    'creator': creator.toJson(),
    'caption': caption,
    'sound': sound,
    'durationMs': duration.inMilliseconds,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'location': location,
    'videoUrl': videoUrl,
    'posterUrl': posterUrl,
    'stars': stars,
    'comments': comments,
    'shares': shares,
    'saves': saves,
    'views': views,
    'isStarred': isStarred,
    'isSaved': isSaved,
  };

  FeedVideo copyWith({
    int? stars,
    bool? isStarred,
    int? saves,
    bool? isSaved,
    int? shares,
  }) => FeedVideo(
    id: id,
    creator: creator,
    caption: caption,
    sound: sound,
    duration: duration,
    createdAt: createdAt,
    location: location,
    videoUrl: videoUrl,
    posterUrl: posterUrl,
    stars: stars ?? this.stars,
    comments: comments,
    shares: shares ?? this.shares,
    saves: saves ?? this.saves,
    views: views,
    isStarred: isStarred ?? this.isStarred,
    isSaved: isSaved ?? this.isSaved,
  );
}
