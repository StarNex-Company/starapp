import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/moderation/data/models/moderation_case.dart';
import 'package:starapp/features/moderation/data/repositories/moderation_repository.dart';

class ApiModerationRepository implements ModerationRepository {
  const ApiModerationRepository(this._client);

  final ApiClient _client;

  @override
  Future<ModerationCase> fetchCase(String caseId) => _client.get(
    '/moderation/cases/$caseId',
    decode: (json) => ModerationCase.fromJson(json as Json),
  );

  @override
  Future<void> submitAppeal(String caseId, AppealForm form) => _client
      .post<void>('/moderation/cases/$caseId/appeal', data: form.toJson());
}
