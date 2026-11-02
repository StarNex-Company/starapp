import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/utils/json.dart';

/// The signed-in creator (`GET /me`). Lives in core because Home, Discover,
/// the shell, Profile and Settings all show it.
class CurrentUser {
  const CurrentUser({
    required this.id,
    required this.fullName,
    required this.handle,
    required this.tier,
    this.avatarUrl,
    this.coverUrl,
    this.location = '',
    this.bio = '',
    this.talents = const [],
    this.stars = 0,
    this.followers = 0,
    this.following = 0,
    this.posts = 0,
    this.isVerified = false,
    this.isCreator = true,
  });

  factory CurrentUser.fromJson(Json json) => CurrentUser(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    handle: json['handle'] as String,
    tier: readEnum(CreatorTier.values, json['tier'], CreatorTier.shootingStar),
    avatarUrl: json['avatarUrl'] as String?,
    coverUrl: json['coverUrl'] as String?,
    location: json['location'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
    talents: readStrings(json['talents']),
    stars: readInt(json['stars']),
    followers: readInt(json['followers']),
    following: readInt(json['following']),
    posts: readInt(json['posts']),
    isVerified: json['isVerified'] as bool? ?? false,
    isCreator: json['isCreator'] as bool? ?? true,
  );

  final String id;
  final String fullName;

  /// Without the leading `@`.
  final String handle;
  final CreatorTier tier;

  /// Network URL (an asset path in mock data); null until one is set.
  final String? avatarUrl;
  final String? coverUrl;
  final String location;
  final String bio;
  final List<String> talents;
  final int stars;
  final int followers;
  final int following;
  final int posts;
  final bool isVerified;
  final bool isCreator;

  String get firstName => fullName.split(' ').first;

  /// How lists show the user, e.g. their own comments.
  CreatorSummary get summary => CreatorSummary(
    id: id,
    name: fullName,
    handle: handle,
    avatarUrl: avatarUrl,
    tier: tier,
    isVerified: isVerified,
  );

  Json toJson() => {
    'id': id,
    'fullName': fullName,
    'handle': handle,
    'tier': tier.name,
    'avatarUrl': avatarUrl,
    'coverUrl': coverUrl,
    'location': location,
    'bio': bio,
    'talents': talents,
    'stars': stars,
    'followers': followers,
    'following': following,
    'posts': posts,
    'isVerified': isVerified,
    'isCreator': isCreator,
  };

  /// [clearCover] removes the cover, which a null [coverUrl] can't express.
  CurrentUser copyWith({
    String? fullName,
    String? handle,
    String? avatarUrl,
    String? coverUrl,
    bool clearCover = false,
    String? location,
    String? bio,
    List<String>? talents,
    int? following,
  }) {
    return CurrentUser(
      id: id,
      fullName: fullName ?? this.fullName,
      handle: handle ?? this.handle,
      tier: tier,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: clearCover ? null : coverUrl ?? this.coverUrl,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      talents: talents ?? this.talents,
      stars: stars,
      followers: followers,
      following: following ?? this.following,
      posts: posts,
      isVerified: isVerified,
      isCreator: isCreator,
    );
  }
}
