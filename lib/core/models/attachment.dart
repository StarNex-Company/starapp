import 'package:starapp/core/utils/json.dart';

enum AttachmentKind { image, video, document, talentPassport }

/// A file shared in a message or attached to a Scout request.
class Attachment {
  const Attachment({
    required this.id,
    required this.kind,
    required this.fileName,
    required this.url,
    this.mimeType = '',
    this.sizeBytes = 0,
    this.pageCount,
    this.thumbnailUrl,
  });

  factory Attachment.fromJson(Json json) => Attachment(
    id: json['id'] as String,
    kind: readEnum(
      AttachmentKind.values,
      json['kind'],
      AttachmentKind.document,
    ),
    fileName: json['fileName'] as String,
    url: json['url'] as String,
    mimeType: json['mimeType'] as String? ?? '',
    sizeBytes: readInt(json['sizeBytes']),
    pageCount: json['pageCount'] == null ? null : readInt(json['pageCount']),
    thumbnailUrl: json['thumbnailUrl'] as String?,
  );

  final String id;
  final AttachmentKind kind;
  final String fileName;
  final String url;
  final String mimeType;
  final int sizeBytes;

  /// Documents only.
  final int? pageCount;
  final String? thumbnailUrl;

  /// "PDF", "PNG"… from the file name.
  String get extension {
    final dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot + 1).toUpperCase();
  }

  /// "2.4 MB", "820 KB".
  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / 1024).ceil()} KB';
  }

  Json toJson() => {
    'id': id,
    'kind': kind.name,
    'fileName': fileName,
    'url': url,
    'mimeType': mimeType,
    'sizeBytes': sizeBytes,
    'pageCount': pageCount,
    'thumbnailUrl': thumbnailUrl,
  };
}
