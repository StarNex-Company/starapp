import 'package:starapp/features/moderation/data/models/moderation_case.dart';

/// Moderation decisions on the creator's posts and their appeals. Screens
/// read the providers in `moderation_providers.dart`;
/// `moderationRepositoryProvider` picks the mock or API implementation.
abstract interface class ModerationRepository {
  Future<ModerationCase> fetchCase(String caseId);

  /// Files the appeal. A rejected form throws a `ValidationException` whose
  /// `fieldErrors` are keyed `reason` and `details`.
  Future<void> submitAppeal(String caseId, AppealForm form);
}
