import 'package:starapp/features/create/data/models/challenge_summary.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';
import 'package:starapp/features/create/data/models/upload_status.dart';

/// Where the create & upload flow gets its content and sends entries.
/// Screens read the providers in `create_providers.dart`;
/// `createRepositoryProvider` picks the mock or API implementation.
abstract interface class CreateRepository {
  /// This month's challenge, promoted on the Create sheet and Submit Entry.
  Future<FeaturedChallenge> fetchFeaturedChallenge();

  /// Challenges offered on Submit Entry; ineligible ones are listed disabled.
  Future<List<ChallengeSummary>> fetchEligibleChallenges();

  Future<int> fetchDraftCount();

  /// The creator's talents, offered as the entry's category.
  Future<List<String>> fetchTalentCategories();

  /// A new draft for the clip just recorded or picked.
  Future<EntryDraft> createDraft();

  Future<void> saveDraft(EntryDraft draft);

  /// Sends [draft] to its challenge, reporting progress until an
  /// [UploadStage.complete] status carrying the submission, then closes.
  /// Fails with the request's error; cancelling the subscription cancels
  /// the upload.
  Stream<UploadStatus> uploadEntry(EntryDraft draft);
}
