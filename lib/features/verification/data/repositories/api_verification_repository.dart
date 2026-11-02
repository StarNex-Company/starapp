import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/verification/data/models/verification.dart';
import 'package:starapp/features/verification/data/repositories/verification_repository.dart';

class ApiVerificationRepository implements VerificationRepository {
  const ApiVerificationRepository(this._client);

  final ApiClient _client;

  @override
  Future<VerificationOverview> fetchVerification() => _client.get(
    '/me/verification',
    decode: (json) => VerificationOverview.fromJson(json as Json),
  );

  @override
  Future<VerificationDocument> uploadDocument({
    required String idType,
    required String filePath,
    void Function(int sent, int total)? onProgress,
  }) => _client.upload(
    '/me/verification/documents',
    filePath: filePath,
    fields: {'idType': idType},
    onProgress: onProgress,
    decode: (json) => VerificationDocument.fromJson(json as Json),
  );

  @override
  Future<void> submit({required String idType, required String documentId}) =>
      _client.post<void>(
        '/me/verification/submit',
        data: {'idType': idType, 'documentId': documentId},
      );
}
