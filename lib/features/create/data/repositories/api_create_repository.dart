import 'dart:async';

import 'package:dio/dio.dart' show CancelToken;
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/create/data/models/challenge_summary.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';
import 'package:starapp/features/create/data/models/entry_submission.dart';
import 'package:starapp/features/create/data/models/upload_status.dart';
import 'package:starapp/features/create/data/repositories/create_repository.dart';

/// Collections come back as `{"items": [...]}`. There is no on-device
/// compression yet, so uploads start at [UploadStage.uploading].
class ApiCreateRepository implements CreateRepository {
  const ApiCreateRepository(this._client);

  final ApiClient _client;

  @override
  Future<FeaturedChallenge> fetchFeaturedChallenge() => _client.get(
    '/challenges/featured',
    decode: (json) => FeaturedChallenge.fromJson(json as Json),
  );

  @override
  Future<List<ChallengeSummary>> fetchEligibleChallenges() => _client.get(
    '/challenges/eligible',
    decode: (json) =>
        readList((json as Json)['items'], ChallengeSummary.fromJson),
  );

  @override
  Future<int> fetchDraftCount() => _client.get(
    '/me/drafts/count',
    decode: (json) => readInt((json as Json)['count']),
  );

  @override
  Future<List<String>> fetchTalentCategories() => _client.get(
    '/me/talents',
    decode: (json) => readStrings((json as Json)['items']),
  );

  @override
  Future<EntryDraft> createDraft() => _client.post(
    '/me/drafts',
    decode: (json) => EntryDraft.fromJson(json as Json),
  );

  @override
  Future<void> saveDraft(EntryDraft draft) =>
      _client.put<void>('/me/drafts/${draft.id}', data: draft.toJson());

  @override
  Stream<UploadStatus> uploadEntry(EntryDraft draft) {
    final cancel = CancelToken();
    late final StreamController<UploadStatus> out;
    out = StreamController<UploadStatus>(
      onListen: () => _upload(draft, out, cancel),
      onCancel: () => cancel.cancel(),
    );
    return out.stream;
  }

  /// `POST /challenges/{id}/entries` as multipart: the video under `video`
  /// plus the draft's fields. Once every byte is sent the server is
  /// processing until it answers with the [EntrySubmission].
  Future<void> _upload(
    EntryDraft draft,
    StreamController<UploadStatus> out,
    CancelToken cancel,
  ) async {
    final clock = Stopwatch()..start();
    var processing = false;
    out.add(const UploadStatus(stage: UploadStage.uploading));
    try {
      final submission = await _client.upload(
        '/challenges/${draft.challenge.id}/entries',
        filePath: draft.clip.filePath,
        field: 'video',
        fields: {
          'draftId': draft.id,
          'title': draft.title,
          'caption': draft.caption,
          'category': draft.category,
          'location': draft.location,
          'coverIndex': draft.coverIndex,
          'collaboratorId': draft.collaborator?.id,
          'allowComments': draft.allowComments,
          'rulesAccepted': draft.rulesAccepted,
          'trimStartMs': draft.clip.trim.start.inMilliseconds,
          'trimEndMs': draft.clip.trim.end.inMilliseconds,
        },
        cancelToken: cancel,
        onProgress: (sent, total) {
          if (out.isClosed || total <= 0 || processing) return;
          if (sent >= total) {
            processing = true;
            out.add(const UploadStatus(stage: UploadStage.processing));
            return;
          }
          out.add(
            UploadStatus(
              stage: UploadStage.uploading,
              progress: sent / total,
              remaining: sent == 0
                  ? null
                  : clock.elapsed * ((total - sent) / sent),
            ),
          );
        },
        decode: (json) => EntrySubmission.fromJson(json as Json),
      );
      if (!out.isClosed) {
        out.add(
          UploadStatus(
            stage: UploadStage.complete,
            progress: 1,
            submission: submission,
          ),
        );
      }
    } catch (error, stack) {
      if (!out.isClosed) out.addError(error, stack);
    } finally {
      await out.close();
    }
  }
}
