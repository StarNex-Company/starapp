import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

/// A short video in the "Trending Talents" row (`GET /home` →
/// `trendingTalents`).
class TrendingTalent {
  const TrendingTalent({
    required this.id,
    required this.author,
    required this.createdAt,
    required this.tag,
    this.coverUrl,
  });

  factory TrendingTalent.fromJson(Json json) => TrendingTalent(
    id: json['id'] as String,
    author: CreatorSummary.fromJson(json['author'] as Json),
    createdAt: readDate(json['createdAt']) ?? DateTime.now(),
    tag: json['tag'] as String? ?? '',
    coverUrl: json['coverUrl'] as String?,
  );

  /// The video's id.
  final String id;
  final CreatorSummary author;
  final DateTime createdAt;

  /// Category pill, e.g. "🎬 Acting Audition"; empty hides it.
  final String tag;

  /// Poster frame.
  final String? coverUrl;

  Json toJson() => {
    'id': id,
    'author': author.toJson(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'tag': tag,
    'coverUrl': coverUrl,
  };
}
