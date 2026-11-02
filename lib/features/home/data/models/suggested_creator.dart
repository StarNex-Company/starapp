import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

/// A card in the "Suggested Creators" row (`GET /home` →
/// `suggestedCreators`).
class SuggestedCreator {
  const SuggestedCreator({required this.creator, this.followedBy = const []});

  factory SuggestedCreator.fromJson(Json json) => SuggestedCreator(
    creator: CreatorSummary.fromJson(json['creator'] as Json),
    followedBy: readList(json['followedBy'], CreatorSummary.fromJson),
  );

  final CreatorSummary creator;

  /// People the user follows who follow [creator], for the "Followed by"
  /// avatars.
  final List<CreatorSummary> followedBy;

  Json toJson() => {
    'creator': creator.toJson(),
    'followedBy': [for (final c in followedBy) c.toJson()],
  };
}
