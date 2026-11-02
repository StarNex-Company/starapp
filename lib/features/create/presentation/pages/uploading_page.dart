import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';
import 'package:starapp/features/create/data/models/upload_status.dart';
import 'package:starapp/features/create/data/provider/create_providers.dart';
import 'package:starapp/features/create/presentation/widgets/create_format.dart';
import 'package:starapp/features/create/presentation/widgets/uploading_card.dart';
import 'package:starapp/features/create/presentation/widgets/uploading_notice.dart';
import 'package:starapp/features/create/presentation/widgets/uploading_steps.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Shows the entry upload from [entryUploadProvider] and replaces itself with
/// Entry Submitted once it completes.
class UploadingPage extends ConsumerStatefulWidget {
  const UploadingPage({super.key, this.autoStart = true});

  /// Starts uploading the current draft as soon as the screen opens.
  final bool autoStart;

  @override
  ConsumerState<UploadingPage> createState() => _UploadingPageState();
}

class _UploadingPageState extends ConsumerState<UploadingPage> {
  @override
  void initState() {
    super.initState();
    if (widget.autoStart) ref.read(entryUploadProvider.notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      entryUploadProvider.select(
        (status) => status.stage == UploadStage.complete,
      ),
      (_, complete) {
        if (complete) context.go(AppRoutes.createSubmitted);
      },
    );
    ref.listen(entryUploadProvider.select((status) => status.error), (
      _,
      error,
    ) {
      if (error != null) showStarToast(context, describeError(error));
    });
    final draft = ref.watch(entryDraftProvider);
    final status = ref.watch(entryUploadProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const StarScreenHeader(title: 'Uploading'),
      // Design text uses Inter's normal line height and no tracking.
      body: DefaultTextStyle.merge(
        style: const TextStyle(height: 1.21, letterSpacing: 0),
        child: StarAsyncView(
          value: draft,
          onRetry: () {
            ref.invalidate(entryDraftProvider);
            if (widget.autoStart) {
              ref.read(entryUploadProvider.notifier).start();
            }
          },
          builder: (draft) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              spacing: 20,
              children: [
                UploadingCard(
                  thumbnail: draft.clip.frameUrl,
                  title: draft.title,
                  challenge: draft.challenge.title,
                  progress: status.stage == UploadStage.complete
                      ? 1
                      : status.progress,
                  statusText: _statusText(status, draft.clip),
                ),
                UploadingSteps(steps: _steps(status.stage, draft.clip)),
                const UploadingReviewNotice(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: StarBottomBar(
        child: StarOutlinedButton(
          label: 'Keep browsing',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
    );
  }
}

String _mb(double value) {
  final text = value.toStringAsFixed(1);
  return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text} MB';
}

String _timeLeft(Duration remaining) {
  final seconds = (remaining.inMilliseconds / 1000).ceil();
  if (seconds < 60) return '${seconds}s left';
  return '${seconds ~/ 60}m ${seconds % 60}s left';
}

String _statusText(UploadStatus status, EntryClip clip) {
  final total = megabytes(clip.sizeBytes);
  return switch (status.stage) {
    UploadStage.compressing => 'Compressing · ${_mb(total)}',
    UploadStage.uploading => [
      '${_mb(total * status.progress)} of ${_mb(total)}',
      if (status.remaining != null) _timeLeft(status.remaining!),
    ].join(' · '),
    UploadStage.processing => 'Processing · almost done',
    UploadStage.complete => 'Done',
  };
}

List<UploadStepData> _steps(UploadStage stage, EntryClip clip) {
  UploadStepState stateOf(UploadStage step) => step.index < stage.index
      ? UploadStepState.done
      : step == stage
      ? UploadStepState.active
      : UploadStepState.pending;

  String subtitle(
    UploadStage step, {
    required String done,
    required String active,
    required String pending,
  }) => switch (stateOf(step)) {
    UploadStepState.done => done,
    UploadStepState.active => active,
    UploadStepState.pending => pending,
  };

  final size = _mb(megabytes(clip.sizeBytes));
  return [
    UploadStepData(
      title: 'Compressing video',
      subtitle: subtitle(
        UploadStage.compressing,
        done: 'Done · ${_mb(megabytes(clip.originalSizeBytes))} → $size',
        active: 'Optimising for fast playback',
        pending: 'Waiting',
      ),
      state: stateOf(UploadStage.compressing),
    ),
    UploadStepData(
      title: 'Uploading',
      subtitle: subtitle(
        UploadStage.uploading,
        done: 'Done · $size sent',
        active: 'Keep the app open or switch to background',
        pending: 'Waiting',
      ),
      state: stateOf(UploadStage.uploading),
    ),
    UploadStepData(
      title: 'Processing & thumbnails',
      subtitle: subtitle(
        UploadStage.processing,
        done: 'Done',
        active: 'Getting your entry ready',
        pending: 'Up next',
      ),
      state: stateOf(UploadStage.processing),
    ),
    const UploadStepData(
      title: 'Challenge review',
      subtitle: 'Usually under 2 hours',
      state: UploadStepState.pending,
    ),
  ];
}
