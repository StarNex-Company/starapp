import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/create/data/models/challenge_summary.dart';

Duration _ms(Object? value) => Duration(milliseconds: readInt(value));

/// The kept part of a clip, as times into the recording.
class ClipTrim {
  const ClipTrim({
    required this.start,
    required this.end,
    required this.playhead,
  });

  factory ClipTrim.fromJson(Json json) => ClipTrim(
    start: _ms(json['startMs']),
    end: _ms(json['endMs']),
    playhead: _ms(json['playheadMs']),
  );

  final Duration start;
  final Duration end;

  /// Where the preview is paused.
  final Duration playhead;

  Duration get length => end - start;

  Json toJson() => {
    'startMs': start.inMilliseconds,
    'endMs': end.inMilliseconds,
    'playheadMs': playhead.inMilliseconds,
  };
}

/// The recorded or picked video behind an entry.
class EntryClip {
  const EntryClip({
    required this.filePath,
    required this.duration,
    required this.trim,
    required this.sizeBytes,
    required this.originalSizeBytes,
    this.frameUrl,
    this.filmstripUrls = const [],
    this.coverFrameUrls = const [],
  });

  factory EntryClip.fromJson(Json json) => EntryClip(
    filePath: json['filePath'] as String? ?? '',
    duration: _ms(json['durationMs']),
    trim: ClipTrim.fromJson(json['trim'] as Json? ?? const {}),
    sizeBytes: readInt(json['sizeBytes']),
    originalSizeBytes: readInt(json['originalSizeBytes']),
    frameUrl: json['frameUrl'] as String?,
    filmstripUrls: readStrings(json['filmstripUrls']),
    coverFrameUrls: readStrings(json['coverFrameUrls']),
  );

  /// The video file on the device; uploaded as the entry.
  final String filePath;

  /// Length of the whole recording.
  final Duration duration;
  final ClipTrim trim;

  /// Upload size after compression.
  final int sizeBytes;

  /// Size as recorded, before compression.
  final int originalSizeBytes;

  /// Poster frame, used as the entry thumbnail.
  final String? frameUrl;

  /// Frames along the trim strip.
  final List<String> filmstripUrls;

  /// Auto-generated cover options.
  final List<String> coverFrameUrls;

  Json toJson() => {
    'filePath': filePath,
    'durationMs': duration.inMilliseconds,
    'trim': trim.toJson(),
    'sizeBytes': sizeBytes,
    'originalSizeBytes': originalSizeBytes,
    'frameUrl': frameUrl,
    'filmstripUrls': filmstripUrls,
    'coverFrameUrls': coverFrameUrls,
  };
}

/// The entry being put together across Preview & Edit and Submit Entry
/// (`POST /me/drafts`, `PUT /me/drafts/{id}`).
class EntryDraft {
  const EntryDraft({
    required this.id,
    required this.title,
    required this.clip,
    required this.caption,
    required this.category,
    required this.location,
    required this.city,
    required this.challenge,
    this.coverIndex = 0,
    this.collaborator,
    this.allowComments = true,
    this.submitToChallenge = true,
    this.rulesAccepted = false,
  });

  factory EntryDraft.fromJson(Json json) => EntryDraft(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    clip: EntryClip.fromJson(json['clip'] as Json? ?? const {}),
    caption: json['caption'] as String? ?? '',
    category: json['category'] as String? ?? '',
    location: json['location'] as String? ?? '',
    city: json['city'] as String? ?? '',
    challenge: ChallengeSummary.fromJson(json['challenge'] as Json),
    coverIndex: readInt(json['coverIndex']),
    collaborator: json['collaborator'] == null
        ? null
        : CreatorSummary.fromJson(json['collaborator'] as Json),
    allowComments: json['allowComments'] as bool? ?? true,
    submitToChallenge: json['submitToChallenge'] as bool? ?? true,
    rulesAccepted: json['rulesAccepted'] as bool? ?? false,
  );

  final String id;
  final String title;
  final EntryClip clip;
  final String caption;

  /// Talent category, e.g. "Music".
  final String category;

  /// e.g. "Lagos, Nigeria".
  final String location;

  /// Short form of [location], e.g. "Lagos".
  final String city;

  /// The challenge the entry goes to.
  final ChallengeSummary challenge;

  /// Index into [EntryClip.coverFrameUrls].
  final int coverIndex;

  /// Someone tagged on the entry.
  final CreatorSummary? collaborator;
  final bool allowComments;
  final bool submitToChallenge;

  /// Whether the creator confirmed the entry follows the challenge rules.
  final bool rulesAccepted;

  Json toJson() => {
    'id': id,
    'title': title,
    'clip': clip.toJson(),
    'caption': caption,
    'category': category,
    'location': location,
    'city': city,
    'challenge': challenge.toJson(),
    'coverIndex': coverIndex,
    'collaborator': collaborator?.toJson(),
    'allowComments': allowComments,
    'submitToChallenge': submitToChallenge,
    'rulesAccepted': rulesAccepted,
  };

  EntryDraft copyWith({
    String? caption,
    String? category,
    ChallengeSummary? challenge,
    int? coverIndex,
    bool removeCollaborator = false,
    bool? allowComments,
    bool? submitToChallenge,
    bool? rulesAccepted,
  }) => EntryDraft(
    id: id,
    title: title,
    clip: clip,
    caption: caption ?? this.caption,
    category: category ?? this.category,
    location: location,
    city: city,
    challenge: challenge ?? this.challenge,
    coverIndex: coverIndex ?? this.coverIndex,
    collaborator: removeCollaborator ? null : collaborator,
    allowComments: allowComments ?? this.allowComments,
    submitToChallenge: submitToChallenge ?? this.submitToChallenge,
    rulesAccepted: rulesAccepted ?? this.rulesAccepted,
  );
}
