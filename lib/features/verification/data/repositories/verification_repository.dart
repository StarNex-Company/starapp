import 'package:starapp/features/verification/data/models/verification.dart';

/// Creator verification: the requirements checklist, the ID documents the
/// identity step accepts, uploading the ID photo and submitting it. Screens
/// read the providers in `verification_providers.dart`;
/// `verificationRepositoryProvider` picks the mock or API implementation.
abstract interface class VerificationRepository {
  /// The steps in order (the identity step is the one in progress) and the
  /// accepted ID types.
  Future<VerificationOverview> fetchVerification();

  /// Uploads the photo of an [idType] document from [filePath] on the
  /// device. [onProgress] reports bytes sent of the total.
  Future<VerificationDocument> uploadDocument({
    required String idType,
    required String filePath,
    void Function(int sent, int total)? onProgress,
  });

  /// Sends the uploaded document for review.
  Future<void> submit({required String idType, required String documentId});
}
