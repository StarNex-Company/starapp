import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/features/verification/data/models/verification.dart';
import 'package:starapp/features/verification/data/repositories/mock_verification_repository.dart';

void main() {
  const repository = MockVerificationRepository();

  test('the fixture parses and covers every step state', () async {
    final overview = await repository.fetchVerification();

    expect(overview.total, 5);
    expect(overview.completed, 3);
    expect(overview.currentStepNumber, 4);
    final statuses = overview.steps.map((s) => s.status).toSet();
    expect(statuses, VerificationStepStatus.values.toSet());
    expect(
      overview.steps.any((s) => s.progress != null && s.target != null),
      isTrue,
      reason: 'a counted requirement',
    );
    expect(overview.idTypes, isNotEmpty);
  });

  test('toJson round-trips', () async {
    final overview = await repository.fetchVerification();
    expect(
      VerificationOverview.fromJson(overview.toJson()).toJson(),
      overview.toJson(),
    );

    final document = await repository.uploadDocument(
      idType: 'passport',
      filePath: '/tmp/passport.jpg',
    );
    expect(document.fileName, 'passport.jpg');
    expect(
      VerificationDocument.fromJson(document.toJson()).toJson(),
      document.toJson(),
    );
  });

  test('unknown requirements and statuses fall back', () {
    final step = VerificationStep.fromJson({
      'requirement': 'bankAccount',
      'title': 'Link a bank account',
      'status': 'paused',
    });
    expect(step.requirement, VerificationRequirement.other);
    expect(step.status, VerificationStepStatus.locked);
  });
}
