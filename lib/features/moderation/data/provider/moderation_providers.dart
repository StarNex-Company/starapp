import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/moderation/data/models/moderation_case.dart';
import 'package:starapp/features/moderation/data/repositories/api_moderation_repository.dart';
import 'package:starapp/features/moderation/data/repositories/mock_moderation_repository.dart';
import 'package:starapp/features/moderation/data/repositories/moderation_repository.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockModerationRepository.new,
    api: ApiModerationRepository.new,
  ),
);

/// The case the moderation pages show when their route carries no id.
const defaultModerationCaseId = 'SA-48213';

/// A moderation decision, by case id: Content Paused and the appeal form.
final moderationCaseProvider = FutureProvider.autoDispose
    .family<ModerationCase, String>(
      (ref, caseId) =>
          ref.watch(moderationRepositoryProvider).fetchCase(caseId),
    );

/// The appeal being filed against a case. Starts on the case's first ground
/// with no details, and lives while the form is open.
final appealFormProvider = AsyncNotifierProvider.autoDispose
    .family<AppealFormNotifier, AppealForm, String>(AppealFormNotifier.new);

class AppealFormNotifier extends AsyncNotifier<AppealForm> {
  AppealFormNotifier(this.caseId);

  final String caseId;

  @override
  Future<AppealForm> build() async {
    final moderationCase = await ref.watch(
      moderationCaseProvider(caseId).future,
    );
    return AppealForm(reasonId: moderationCase.appealReasons.firstOrNull?.id);
  }

  void _update(AppealForm Function(AppealForm form) change) {
    final form = state.value;
    if (form == null) return;
    state = AsyncData(change(form));
  }

  void selectReason(String reasonId) =>
      _update((f) => f.copyWith(reasonId: reasonId));

  void setDetails(String details) {
    if (state.value?.details == details) return;
    _update((f) => f.copyWith(details: details));
  }

  /// Files the appeal; rethrows a rejection (a `ValidationException` carries
  /// the field errors).
  Future<void> submit() async {
    final form = state.value;
    if (form == null) return;
    await ref.read(moderationRepositoryProvider).submitAppeal(caseId, form);
  }
}
