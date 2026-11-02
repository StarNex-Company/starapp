import 'package:starapp/core/utils/json.dart';

/// What comes back once an entry is in
/// (`POST /challenges/{id}/entries`): the entry bonus and what happens next.
class EntrySubmission {
  const EntrySubmission({
    required this.entryId,
    this.bonusStars = 0,
    this.nextSteps = const [],
  });

  factory EntrySubmission.fromJson(Json json) => EntrySubmission(
    entryId: json['entryId'] as String,
    bonusStars: readInt(json['bonusStars']),
    nextSteps: readStrings(json['nextSteps']),
  );

  final String entryId;
  final int bonusStars;
  final List<String> nextSteps;

  Json toJson() => {
    'entryId': entryId,
    'bonusStars': bonusStars,
    'nextSteps': nextSteps,
  };
}
