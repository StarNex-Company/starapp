import 'package:starapp/core/utils/json.dart';

/// Where a creator-verification requirement stands.
enum VerificationStepStatus {
  /// Met; shows a green check and a green detail line.
  done,

  /// The step the user is on (identity upload); shows its number.
  current,

  /// Waits on an earlier step; shows a lock and greys out.
  locked,
}

/// What a requirement asks for; decides how its progress line reads.
enum VerificationRequirement {
  posts,
  followers,
  conduct,
  identity,
  selfie,

  /// A requirement this version of the app doesn't know yet.
  other,
}

/// One requirement on the road to the verified badge, e.g. "Reach 50
/// followers".
class VerificationStep {
  const VerificationStep({
    required this.requirement,
    required this.title,
    required this.status,
    this.progress,
    this.target,
    this.completedAt,
  });

  factory VerificationStep.fromJson(Json json) => VerificationStep(
    requirement: readEnum(
      VerificationRequirement.values,
      json['requirement'],
      VerificationRequirement.other,
    ),
    title: json['title'] as String,
    status: readEnum(
      VerificationStepStatus.values,
      json['status'],
      VerificationStepStatus.locked,
    ),
    progress: json['progress'] == null ? null : readInt(json['progress']),
    target: json['target'] == null ? null : readInt(json['target']),
    completedAt: readDate(json['completedAt']),
  );

  final VerificationRequirement requirement;
  final String title;
  final VerificationStepStatus status;

  /// Counted requirements: how far along, e.g. 64 of a [target] of 50.
  final int? progress;
  final int? target;
  final DateTime? completedAt;

  Json toJson() => {
    'requirement': requirement.name,
    'title': title,
    'status': status.name,
    'progress': progress,
    'target': target,
    'completedAt': completedAt?.toUtc().toIso8601String(),
  };
}

/// A document the identity step accepts.
class VerificationIdType {
  const VerificationIdType({
    required this.id,
    required this.label,
    required this.uploadPrompt,
  });

  factory VerificationIdType.fromJson(Json json) => VerificationIdType(
    id: json['id'] as String,
    label: json['label'] as String,
    uploadPrompt: json['uploadPrompt'] as String? ?? 'Upload a photo',
  );

  /// Sent back as `idType`, e.g. "passport".
  final String id;

  /// Chip label, e.g. "Passport".
  final String label;

  /// Upload-box title, e.g. "Upload the photo page".
  final String uploadPrompt;

  Json toJson() => {'id': id, 'label': label, 'uploadPrompt': uploadPrompt};
}

/// The requirements checklist plus the ID types its identity step accepts
/// (`GET /me/verification`).
class VerificationOverview {
  const VerificationOverview({required this.steps, required this.idTypes});

  factory VerificationOverview.fromJson(Json json) => VerificationOverview(
    steps: readList(json['steps'], VerificationStep.fromJson),
    idTypes: readList(json['idTypes'], VerificationIdType.fromJson),
  );

  final List<VerificationStep> steps;
  final List<VerificationIdType> idTypes;

  int get completed =>
      steps.where((s) => s.status == VerificationStepStatus.done).length;

  int get total => steps.length;

  /// 1-based number of the step in progress (the identity step).
  int get currentStepNumber {
    final i = steps.indexWhere(
      (s) => s.status == VerificationStepStatus.current,
    );
    return i < 0 ? completed : i + 1;
  }

  Json toJson() => {
    'steps': [for (final s in steps) s.toJson()],
    'idTypes': [for (final t in idTypes) t.toJson()],
  };
}

/// An uploaded ID photo (`POST /me/verification/documents`).
class VerificationDocument {
  const VerificationDocument({
    required this.id,
    required this.fileName,
    required this.sizeBytes,
  });

  factory VerificationDocument.fromJson(Json json) => VerificationDocument(
    id: json['id'] as String,
    fileName: json['fileName'] as String? ?? '',
    sizeBytes: readInt(json['sizeBytes']),
  );

  /// Sent back with the submission.
  final String id;
  final String fileName;
  final int sizeBytes;

  Json toJson() => {'id': id, 'fileName': fileName, 'sizeBytes': sizeBytes};
}

/// What the user has filled in on the verification screen (screen state,
/// not an API model).
class VerificationForm {
  const VerificationForm({
    this.idTypeId,
    this.document,
    this.submitting = false,
  });

  /// Chosen ID type; null until the overview loads (then the first type).
  final String? idTypeId;
  final VerificationDocument? document;
  final bool submitting;

  VerificationForm copyWith({
    String? idTypeId,
    VerificationDocument? document,
    bool clearDocument = false,
    bool? submitting,
  }) {
    return VerificationForm(
      idTypeId: idTypeId ?? this.idTypeId,
      document: clearDocument ? null : (document ?? this.document),
      submitting: submitting ?? this.submitting,
    );
  }
}
