import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/utils/json.dart';

/// A shared file with what the viewer shows about it (`GET /attachments/{id}`):
/// the [Attachment] fields, plus who shared it and the document's text,
/// extracted by the server so it can be read without a PDF renderer.
class AttachmentPreview {
  const AttachmentPreview({
    required this.attachment,
    this.ownerName,
    this.title,
    this.sections = const [],
  });

  /// The response is one flat object: the attachment's own keys plus
  /// `ownerName`, `title` and `sections`.
  factory AttachmentPreview.fromJson(Json json) => AttachmentPreview(
    attachment: Attachment.fromJson(json),
    ownerName: json['ownerName'] as String?,
    title: json['title'] as String?,
    sections: readList(json['sections'], PreviewSection.fromJson),
  );

  final Attachment attachment;

  /// e.g. "Afrowave Records".
  final String? ownerName;

  /// The document's own title, e.g. "Gbedu" Music Video Brief.
  final String? title;
  final List<PreviewSection> sections;

  Json toJson() => {
    ...attachment.toJson(),
    'ownerName': ownerName,
    'title': title,
    'sections': [for (final s in sections) s.toJson()],
  };
}

/// A heading and its paragraph from a document preview.
class PreviewSection {
  const PreviewSection({required this.heading, required this.body});

  factory PreviewSection.fromJson(Json json) => PreviewSection(
    heading: json['heading'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );

  final String heading;
  final String body;

  Json toJson() => {'heading': heading, 'body': body};
}
