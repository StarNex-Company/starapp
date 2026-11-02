import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/home/data/models/feed_category.dart';
import 'package:starapp/features/home/data/models/post.dart';
import 'package:starapp/features/home/data/models/story.dart';
import 'package:starapp/features/home/data/models/suggested_creator.dart';
import 'package:starapp/features/home/data/models/trending_talent.dart';

/// Everything around the posts on the home tab (`GET /home`).
class HomeSections {
  const HomeSections({
    this.stories = const [],
    this.trendingTalents = const [],
    this.suggestedCreators = const [],
  });

  factory HomeSections.fromJson(Json json) => HomeSections(
    stories: readList(json['stories'], Story.fromJson),
    trendingTalents: readList(json['trendingTalents'], TrendingTalent.fromJson),
    suggestedCreators: readList(
      json['suggestedCreators'],
      SuggestedCreator.fromJson,
    ),
  );

  final List<Story> stories;
  final List<TrendingTalent> trendingTalents;
  final List<SuggestedCreator> suggestedCreators;

  Json toJson() => {
    'stories': [for (final s in stories) s.toJson()],
    'trendingTalents': [for (final t in trendingTalents) t.toJson()],
    'suggestedCreators': [for (final c in suggestedCreators) c.toJson()],
  };

  HomeSections copyWith({List<SuggestedCreator>? suggestedCreators}) =>
      HomeSections(
        stories: stories,
        trendingTalents: trendingTalents,
        suggestedCreators: suggestedCreators ?? this.suggestedCreators,
      );
}

/// What the home tab shows: the [sections] plus the posts loaded so far for
/// the selected [category].
class HomeFeed {
  const HomeFeed({
    required this.sections,
    required this.posts,
    this.category = FeedCategory.following,
  });

  final HomeSections sections;

  /// Newest first. The page places "Trending Talents" and "Suggested
  /// Creators" between them.
  final List<Post> posts;
  final FeedCategory category;

  HomeFeed copyWith({
    HomeSections? sections,
    List<Post>? posts,
    FeedCategory? category,
  }) => HomeFeed(
    sections: sections ?? this.sections,
    posts: posts ?? this.posts,
    category: category ?? this.category,
  );
}
