import 'package:starapp/features/create/data/models/entry_submission.dart';

enum UploadStage { compressing, uploading, processing, complete }

/// Snapshot of an entry upload, as shown on the Uploading screen. App state,
/// not an API resource.
class UploadStatus {
  const UploadStatus({
    required this.stage,
    this.progress = 0,
    this.remaining,
    this.submission,
    this.error,
  });

  final UploadStage stage;

  /// 0–1 within the current [stage].
  final double progress;

  /// Estimated time left in the current stage, when known.
  final Duration? remaining;

  /// The server's answer, once [stage] is complete.
  final EntrySubmission? submission;

  /// Why the upload stopped, if it failed; it can be started again.
  final Object? error;

  UploadStatus failed(Object error) => UploadStatus(
    stage: stage,
    progress: progress,
    remaining: remaining,
    error: error,
  );
}
