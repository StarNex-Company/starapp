import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/features/verification/data/models/verification.dart';
import 'package:starapp/features/verification/data/repositories/api_verification_repository.dart';
import 'package:starapp/features/verification/data/repositories/mock_verification_repository.dart';
import 'package:starapp/features/verification/data/repositories/verification_repository.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => selectRepository(
    ref,
    mock: MockVerificationRepository.new,
    api: ApiVerificationRepository.new,
  ),
);

/// The requirements checklist and the accepted ID types.
final verificationOverviewProvider = FutureProvider<VerificationOverview>(
  (ref) => ref.watch(verificationRepositoryProvider).fetchVerification(),
);

/// The identity step being filled in: the chosen ID type, the uploaded
/// document and whether it's being submitted. Resets when the user leaves
/// the verification flow.
final verificationFormProvider =
    NotifierProvider.autoDispose<VerificationFormNotifier, VerificationForm>(
      VerificationFormNotifier.new,
    );

class VerificationFormNotifier extends Notifier<VerificationForm> {
  VerificationRepository get _repository =>
      ref.read(verificationRepositoryProvider);

  @override
  VerificationForm build() => const VerificationForm();

  /// Choosing another document type drops a photo taken of the previous one.
  void selectIdType(String idTypeId) {
    if (idTypeId == state.idTypeId) return;
    state = VerificationForm(idTypeId: idTypeId);
  }

  /// Uploads the photo at [filePath] as [type]'s document and attaches it.
  /// Errors are rethrown for the screen to show.
  Future<VerificationDocument?> upload(
    VerificationIdType type,
    String filePath,
  ) async {
    if (state.submitting) return null;
    final document = await _repository.uploadDocument(
      idType: type.id,
      filePath: filePath,
    );
    if (!ref.mounted) return null;
    state = state.copyWith(idTypeId: type.id, document: document);
    return document;
  }

  void removeDocument() => state = state.copyWith(clearDocument: true);

  /// Sends the attached photo for review, uploading the one at [filePath]
  /// first if none is attached yet. Returns whether it was submitted; errors
  /// are rethrown for the screen to show.
  Future<bool> submit(VerificationIdType type, {String? filePath}) async {
    if (state.submitting) return false;
    state = state.copyWith(idTypeId: type.id, submitting: true);
    try {
      var document = state.document;
      if (document == null && filePath != null) {
        document = await _repository.uploadDocument(
          idType: type.id,
          filePath: filePath,
        );
        if (!ref.mounted) return false;
        state = state.copyWith(document: document);
      }
      if (document == null) {
        state = state.copyWith(submitting: false);
        return false;
      }
      await _repository.submit(idType: type.id, documentId: document.id);
      if (!ref.mounted) return false;
      state = state.copyWith(submitting: false);
      return true;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(submitting: false);
      rethrow;
    }
  }
}
