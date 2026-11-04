import 'dart:async';

import 'package:intl/intl.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/create/data/models/challenge_summary.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';
import 'package:starapp/features/create/data/models/entry_submission.dart';
import 'package:starapp/features/create/data/models/upload_status.dart';
import 'package:starapp/features/create/data/repositories/create_repository.dart';

/// Serves JSON fixtures shaped like the API's responses through the real
/// `fromJson`, with dates relative to now, and fakes the upload with
/// [upload].
class MockCreateRepository implements CreateRepository {
  const MockCreateRepository({this.upload = const UploadSimulation()});

  /// How fast [uploadEntry] pretends to go.
  final UploadSimulation upload;

  @override
  Future<FeaturedChallenge> fetchFeaturedChallenge() async =>
      FeaturedChallenge.fromJson(_featured(DateTime.now()));

  @override
  Future<List<ChallengeSummary>> fetchEligibleChallenges() async =>
      readList(_eligible(DateTime.now())['items'], ChallengeSummary.fromJson);

  @override
  Future<int> fetchDraftCount() async => readInt(_draftCount['count']);

  @override
  Future<List<String>> fetchTalentCategories() async =>
      readStrings(_talents['items']);

  @override
  Future<EntryDraft> createDraft() async =>
      EntryDraft.fromJson(_draft(DateTime.now()));

  @override
  Future<void> saveDraft(EntryDraft draft) async {}

  @override
  Stream<UploadStatus> uploadEntry(EntryDraft draft) => upload.run(
    result: EntrySubmission.fromJson(_submission(draft.challenge.endsAt)),
  );
}

/// Fakes compress → upload → process at a steady rate, then completes with
/// [run]'s result.
class UploadSimulation {
  const UploadSimulation({
    this.compressDuration = const Duration(seconds: 3),
    this.uploadDuration = const Duration(seconds: 6),
    this.processDuration = const Duration(seconds: 2),
    this.tick = const Duration(milliseconds: 100),
  });

  final Duration compressDuration;
  final Duration uploadDuration;
  final Duration processDuration;
  final Duration tick;

  Stream<UploadStatus> run({EntrySubmission? result}) {
    var status = const UploadStatus(stage: UploadStage.compressing);
    Timer? timer;
    late final StreamController<UploadStatus> controller;
    controller = StreamController<UploadStatus>(
      onListen: () {
        controller.add(status);
        timer = Timer.periodic(tick, (_) {
          status = _advance(status, result);
          controller.add(status);
          if (status.stage == UploadStage.complete) {
            timer?.cancel();
            controller.close();
          }
        });
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }

  Duration _durationOf(UploadStage stage) => switch (stage) {
    UploadStage.compressing => compressDuration,
    UploadStage.uploading => uploadDuration,
    UploadStage.processing => processDuration,
    UploadStage.complete => Duration.zero,
  };

  UploadStatus _advance(UploadStatus current, EntrySubmission? result) {
    final total = _durationOf(current.stage);
    final progress = total == Duration.zero
        ? 1.0
        : current.progress + tick.inMicroseconds / total.inMicroseconds;

    if (progress < 1) {
      return UploadStatus(
        stage: current.stage,
        progress: progress,
        remaining: total * (1 - progress),
      );
    }

    final next = UploadStage.values[current.stage.index + 1];
    return next == UploadStage.complete
        ? UploadStatus(stage: next, progress: 1, submission: result)
        : UploadStatus(stage: next, remaining: _durationOf(next));
  }
}

const _videoFrame = 'assets/images/shared/entry_video_frame.jpg';
const _studioFrame = 'assets/images/shared/arena_studio.jpg';

/// The featured arena's time left, as the design shows it ("4d 18h").
const _featuredLeft = Duration(days: 4, hours: 18, minutes: 22, seconds: 9);

String _at(DateTime now, Duration offset) =>
    now.add(offset).toUtc().toIso8601String();

const _rules = [
  "Original performances only. No re-uploads of other creators' work",
  'Maximum length of 3 minutes',
  'One entry per creator for each challenge',
  'Follows the Star App community guidelines',
];

Json _afroBeatsClash(DateTime now) => {
  'id': 'afro-beats-clash',
  'title': 'Afro-Beats Producer & Vocal Clash',
  'category': 'Music & Production',
  'endsAt': _at(now, _featuredLeft),
  'rules': _rules,
};

Json _featured(DateTime now) => {
  'challenge': _afroBeatsClash(now),
  'prize': {'amountMinor': 1000000, 'currency': 'USD'},
  'coverUrl': _studioFrame,
  'entryCount': 890,
  'capacity': 1000,
};

Json _eligible(DateTime now) => {
  'items': [
    _afroBeatsClash(now),
    {
      'id': 'gospel-voices',
      'title': 'Gospel Voices Showcase',
      'category': 'Music & Audio',
      // A whole number of days, with room for the time to the screen.
      'endsAt': _at(now, const Duration(days: 12, minutes: 30)),
      'rules': _rules,
    },
    {
      'id': 'afro-dance-takeover',
      'title': 'Afro-Dance Takeover',
      'category': 'Dance & Choreo',
      'endsAt': _at(now, const Duration(days: 9)),
      'rules': _rules,
      'isEligible': false,
      'ineligibleReason': "doesn't match this entry",
    },
  ],
};

const Json _draftCount = {'count': 2};

const Json _talents = {
  'items': ['Music', 'Singing', 'Production', 'Dance'],
};

Json _draft(DateTime now) => {
  'id': 'draft-late-night-vocal-run',
  'title': 'Late-night vocal run',
  'clip': {
    'filePath': 'late-night-vocal-run.mp4',
    'durationMs': 56431,
    'trim': {'startMs': 4907, 'endMs': 48907, 'playheadMs': 20937},
    'sizeBytes': 59600000,
    'originalSizeBytes': 112000000,
    'frameUrl': _videoFrame,
    'filmstripUrls': List.filled(8, _videoFrame),
    'coverFrameUrls': [_videoFrame, _studioFrame, _studioFrame, _videoFrame],
  },
  'caption':
      'Late-night vocal run over my own beat. Who is ready for the '
      'Afro-Beats Clash? #OwnTheSpotlight #StarApp',
  'category': 'Music',
  'location': 'Lagos, Nigeria',
  'city': 'Lagos',
  'challenge': _afroBeatsClash(now),
  'coverIndex': 1,
  'collaborator': {
    'id': 'nia',
    'name': 'Nia Adebayo',
    'handle': 'nia_adebayo',
    'avatarUrl': 'assets/images/create/submit_collaborator_nia.png',
  },
  'allowComments': true,
  'submitToChallenge': true,
  'rulesAccepted': true,
};

Json _submission(DateTime challengeEndsAt) => {
  'entryId': 'late-night-vocal-run',
  'bonusStars': 50,
  'nextSteps': [
    'We review your entry (usually under 2 hours)',
    'It goes live on the challenge leaderboard',
    'Fans give Stars. Climb the ranks before '
        '${DateFormat('MMM d').format(challengeEndsAt)}',
  ],
};
