import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/moderation/data/models/moderation_case.dart';
import 'package:starapp/features/moderation/data/repositories/moderation_repository.dart';

/// Serves [_case], shaped like `GET /moderation/cases/{id}`, through the real
/// `fromJson`, with dates relative to now. Appeals are accepted.
class MockModerationRepository implements ModerationRepository {
  const MockModerationRepository();

  @override
  Future<ModerationCase> fetchCase(String caseId) async =>
      ModerationCase.fromJson(_case(DateTime.now()));

  @override
  Future<void> submitAppeal(String caseId, AppealForm form) async {}
}

Json _case(DateTime now) => {
  'id': 'SA-48213',
  'post': {
    'id': 'studio-session-freestyle',
    'title': 'Studio session freestyle',
    'postedAt': now
        .subtract(const Duration(days: 24))
        .toUtc()
        .toIso8601String(),
    'thumbnailUrl': 'assets/images/moderation/paused_thumbnail.jpg',
    'viewCount': 2100,
  },
  'reason': 'Copyrighted audio detected',
  'guideline': '4.2 · Original content',
  'visibility': 'Hidden from feed & leaderboards',
  'nextSteps': [
    'Replace the audio with your own or a licensed sound',
    'Submit an appeal if you own the rights',
    'Read the community guidelines to avoid future pauses',
  ],
  'appealReasons': [
    {
      'id': 'own-rights',
      'title': 'I own the rights to this audio',
      'subtitle': 'I produced the beat myself',
    },
    {
      'id': 'licensed',
      'title': 'The audio is licensed',
      'subtitle': 'Royalty-free or used with permission',
    },
    {
      'id': 'mistake',
      'title': 'This was flagged by mistake',
      'subtitle': "There's no music in my post",
    },
  ],
};
