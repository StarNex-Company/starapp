import 'package:starapp/core/utils/json.dart';

/// The creator's post that a moderation decision is about.
class ModeratedPost {
  const ModeratedPost({
    required this.id,
    required this.title,
    required this.postedAt,
    this.thumbnailUrl,
    this.viewCount = 0,
  });

  factory ModeratedPost.fromJson(Json json) => ModeratedPost(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    postedAt: readDate(json['postedAt']) ?? DateTime.now(),
    thumbnailUrl: json['thumbnailUrl'] as String?,
    viewCount: readInt(json['viewCount']),
  );

  final String id;
  final String title;
  final DateTime postedAt;
  final String? thumbnailUrl;
  final int viewCount;

  Json toJson() => {
    'id': id,
    'title': title,
    'postedAt': postedAt.toUtc().toIso8601String(),
    'thumbnailUrl': thumbnailUrl,
    'viewCount': viewCount,
  };
}

/// A ground the creator can appeal on.
class AppealReason {
  const AppealReason({
    required this.id,
    required this.title,
    this.subtitle = '',
  });

  factory AppealReason.fromJson(Json json) => AppealReason(
    id: json['id'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
  );

  final String id;
  final String title;
  final String subtitle;

  Json toJson() => {'id': id, 'title': title, 'subtitle': subtitle};
}

/// A moderation decision on one of the creator's posts
/// (`GET /moderation/cases/{id}`): shown on Content Paused and appealed
/// from the appeal form.
class ModerationCase {
  const ModerationCase({
    required this.id,
    required this.post,
    required this.reason,
    this.guideline = '',
    this.visibility = '',
    this.nextSteps = const [],
    this.appealReasons = const [],
  });

  factory ModerationCase.fromJson(Json json) => ModerationCase(
    id: json['id'] as String,
    post: ModeratedPost.fromJson(json['post'] as Json),
    reason: json['reason'] as String? ?? '',
    guideline: json['guideline'] as String? ?? '',
    visibility: json['visibility'] as String? ?? '',
    nextSteps: readStrings(json['nextSteps']),
    appealReasons: readList(json['appealReasons'], AppealReason.fromJson),
  );

  /// The case number, e.g. "SA-48213".
  final String id;
  final ModeratedPost post;

  /// Why the post was paused, e.g. "Copyrighted audio detected".
  final String reason;

  /// The guideline it breaks, e.g. "4.2 · Original content".
  final String guideline;

  /// Where it's hidden, e.g. "Hidden from feed & leaderboards".
  final String visibility;

  /// What the creator can do about it.
  final List<String> nextSteps;

  /// The grounds that apply to this kind of decision.
  final List<AppealReason> appealReasons;

  Json toJson() => {
    'id': id,
    'post': post.toJson(),
    'reason': reason,
    'guideline': guideline,
    'visibility': visibility,
    'nextSteps': nextSteps,
    'appealReasons': [for (final r in appealReasons) r.toJson()],
  };
}

/// What the creator has filled in on the appeal form; [toJson] is the body
/// of `POST /moderation/cases/{id}/appeal`.
class AppealForm {
  const AppealForm({this.reasonId, this.details = ''});

  /// [AppealReason.id] of the chosen ground.
  final String? reasonId;
  final String details;

  Json toJson() => {'reason': reasonId, 'details': details};

  AppealForm copyWith({String? reasonId, String? details}) => AppealForm(
    reasonId: reasonId ?? this.reasonId,
    details: details ?? this.details,
  );
}
