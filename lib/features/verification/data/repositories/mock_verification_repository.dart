import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/verification/data/models/verification.dart';
import 'package:starapp/features/verification/data/repositories/verification_repository.dart';

/// Serves [_verification], shaped like `GET /me/verification`, through the
/// real `fromJson`. Uploads answer like the API without reading the file.
class MockVerificationRepository implements VerificationRepository {
  const MockVerificationRepository();

  @override
  Future<VerificationOverview> fetchVerification() async =>
      VerificationOverview.fromJson(_verification(DateTime.now()));

  @override
  Future<VerificationDocument> uploadDocument({
    required String idType,
    required String filePath,
    void Function(int sent, int total)? onProgress,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return VerificationDocument.fromJson({
      'id': 'doc-$idType',
      'fileName': filePath.replaceAll(r'\', '/').split('/').last,
      'sizeBytes': 2516582,
    });
  }

  @override
  Future<void> submit({
    required String idType,
    required String documentId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}

Json _verification(DateTime now) => {
  'steps': [
    {
      'requirement': 'posts',
      'title': 'Post 5 pieces of content',
      'status': 'done',
      'progress': 5,
      'target': 5,
    },
    {
      'requirement': 'followers',
      'title': 'Reach 50 followers',
      'status': 'done',
      'progress': 64,
      'target': 50,
    },
    {
      'requirement': 'conduct',
      'title': 'Accept the code of conduct',
      'status': 'done',
      'completedAt': now
          .subtract(const Duration(days: 30))
          .toUtc()
          .toIso8601String(),
    },
    {
      'requirement': 'identity',
      'title': 'Verify your identity',
      'status': 'current',
    },
    {
      'requirement': 'selfie',
      'title': 'Take a quick selfie',
      'status': 'locked',
    },
  ],
  'idTypes': [
    {
      'id': 'passport',
      'label': 'Passport',
      'uploadPrompt': 'Upload the photo page',
    },
    {
      'id': 'national-id',
      'label': 'National ID',
      'uploadPrompt': 'Upload the front of your ID',
    },
    {
      'id': 'drivers-licence',
      'label': "Driver's licence",
      'uploadPrompt': 'Upload the front of your licence',
    },
  ],
};
