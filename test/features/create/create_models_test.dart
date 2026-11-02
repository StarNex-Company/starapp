import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/features/create/data/models/challenge_summary.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';
import 'package:starapp/features/create/data/models/entry_submission.dart';
import 'package:starapp/features/create/data/models/upload_status.dart';
import 'package:starapp/features/create/data/repositories/mock_create_repository.dart';
import 'package:starapp/features/create/presentation/widgets/create_format.dart';

void main() {
  const repository = MockCreateRepository(
    upload: UploadSimulation(
      compressDuration: Duration(milliseconds: 20),
      uploadDuration: Duration(milliseconds: 20),
      processDuration: Duration(milliseconds: 20),
      tick: Duration(milliseconds: 10),
    ),
  );

  test('the fixtures parse and cover every designed state', () async {
    final featured = await repository.fetchFeaturedChallenge();
    final challenges = await repository.fetchEligibleChallenges();
    final draft = await repository.createDraft();

    expect(featured.prize, const Money(1000000, Currency.usd));
    expect(featured.entryCount, lessThan(featured.capacity));
    expect(challenges.where((c) => c.isEligible), hasLength(2));
    expect(
      challenges.where((c) => !c.isEligible).single.ineligibleReason,
      isNotNull,
    );
    expect(challengeStatus(challenges[0]), 'ends in 4d 18h');
    expect(challengeStatus(challenges[1]), 'ends in 12d');

    expect(draft.clip.trim.length, const Duration(seconds: 44));
    expect(formatTrim(draft.clip.trim), '0:04 – 0:48 · 44s');
    expect(draft.clip.filmstripUrls, isNotEmpty);
    expect(draft.clip.coverFrameUrls.length, greaterThan(draft.coverIndex));
    expect(draft.collaborator?.name, 'Nia Adebayo');
    expect(await repository.fetchTalentCategories(), contains(draft.category));
    expect(await repository.fetchDraftCount(), 2);
  });

  test(
    'the mock upload runs every stage and ends with the submission',
    () async {
      final draft = await repository.createDraft();
      final statuses = await repository.uploadEntry(draft).toList();

      expect(statuses.map((s) => s.stage).toSet(), UploadStage.values.toSet());
      final done = statuses.last;
      expect(done.stage, UploadStage.complete);
      expect(done.submission!.bonusStars, 50);
      expect(done.submission!.nextSteps, hasLength(3));
    },
  );

  test('toJson round-trips', () async {
    final featured = await repository.fetchFeaturedChallenge();
    expect(
      FeaturedChallenge.fromJson(featured.toJson()).toJson(),
      featured.toJson(),
    );
    for (final c in await repository.fetchEligibleChallenges()) {
      expect(ChallengeSummary.fromJson(c.toJson()).toJson(), c.toJson());
    }
    final draft = await repository.createDraft();
    expect(EntryDraft.fromJson(draft.toJson()).toJson(), draft.toJson());

    const submission = EntrySubmission(
      entryId: 'e1',
      bonusStars: 50,
      nextSteps: ['a'],
    );
    expect(
      EntrySubmission.fromJson(submission.toJson()).toJson(),
      submission.toJson(),
    );
  });

  test('copyWith keeps the rest of the draft', () async {
    final draft = await repository.createDraft();
    final edited = draft.copyWith(category: 'Dance', removeCollaborator: true);

    expect(edited.category, 'Dance');
    expect(edited.collaborator, isNull);
    expect(edited.caption, draft.caption);
    expect(edited.clip, same(draft.clip));
  });
}
