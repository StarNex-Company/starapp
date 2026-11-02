import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/create/data/models/challenge_summary.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';
import 'package:starapp/features/create/data/models/upload_status.dart';
import 'package:starapp/features/create/data/repositories/api_create_repository.dart';
import 'package:starapp/features/create/data/repositories/create_repository.dart';
import 'package:starapp/features/create/data/repositories/mock_create_repository.dart';

final createRepositoryProvider = Provider<CreateRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockCreateRepository.new,
    api: ApiCreateRepository.new,
  ),
);

final featuredChallengeProvider = FutureProvider<FeaturedChallenge>(
  (ref) => ref.watch(createRepositoryProvider).fetchFeaturedChallenge(),
);

final eligibleChallengesProvider = FutureProvider<List<ChallengeSummary>>(
  (ref) => ref.watch(createRepositoryProvider).fetchEligibleChallenges(),
);

final draftCountProvider = FutureProvider<int>(
  (ref) => ref.watch(createRepositoryProvider).fetchDraftCount(),
);

final talentCategoriesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(createRepositoryProvider).fetchTalentCategories(),
);

/// The entry being created, shared by Preview & Edit, Submit Entry,
/// Uploading and Entry Submitted. It lives while any of those screens is
/// open, so leaving the flow and starting again begins a fresh draft.
final entryDraftProvider =
    AsyncNotifierProvider.autoDispose<EntryDraftNotifier, EntryDraft>(
      EntryDraftNotifier.new,
    );

class EntryDraftNotifier extends AsyncNotifier<EntryDraft> {
  @override
  Future<EntryDraft> build() =>
      ref.watch(createRepositoryProvider).createDraft();

  void _update(EntryDraft Function(EntryDraft draft) change) {
    final draft = state.value;
    if (draft == null) return;
    state = AsyncData(change(draft));
  }

  void setCaption(String caption) {
    if (state.value?.caption == caption) return;
    _update((d) => d.copyWith(caption: caption));
  }

  void selectCover(int index) => _update((d) => d.copyWith(coverIndex: index));

  void selectCategory(String category) =>
      _update((d) => d.copyWith(category: category));

  void setAllowComments(bool value) =>
      _update((d) => d.copyWith(allowComments: value));

  void setSubmitToChallenge(bool value) =>
      _update((d) => d.copyWith(submitToChallenge: value));

  void selectChallenge(ChallengeSummary challenge) =>
      _update((d) => d.copyWith(challenge: challenge));

  void removeCollaborator() =>
      _update((d) => d.copyWith(removeCollaborator: true));

  void setRulesAccepted(bool value) =>
      _update((d) => d.copyWith(rulesAccepted: value));

  /// Saves the draft to the server; rethrows if that fails.
  Future<void> save() async {
    final draft = state.value;
    if (draft == null) return;
    await ref.read(createRepositoryProvider).saveDraft(draft);
  }
}

/// Progress of the entry upload, read by Uploading, and its result, read by
/// Entry Submitted. Call [EntryUploadNotifier.start] to send the current
/// draft; leaving the flow cancels it.
final entryUploadProvider =
    NotifierProvider.autoDispose<EntryUploadNotifier, UploadStatus>(
      EntryUploadNotifier.new,
    );

class EntryUploadNotifier extends Notifier<UploadStatus> {
  StreamSubscription<UploadStatus>? _subscription;
  bool _started = false;

  @override
  UploadStatus build() {
    ref.onDispose(() => _subscription?.cancel());
    return const UploadStatus(stage: UploadStage.compressing);
  }

  /// Sends the current draft. Does nothing while an upload is running; can
  /// be called again after the draft failed to load or the upload failed,
  /// which leaves [UploadStatus.error] set.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    final EntryDraft draft;
    try {
      draft = await ref.read(entryDraftProvider.future);
    } catch (_) {
      _started = false;
      return;
    }
    if (!ref.mounted) return;
    state = const UploadStatus(stage: UploadStage.compressing);
    await _subscription?.cancel();
    _subscription = ref
        .read(createRepositoryProvider)
        .uploadEntry(draft)
        .listen(
          (status) => state = status,
          onError: (Object error) {
            _started = false;
            state = state.failed(error);
          },
        );
  }
}
