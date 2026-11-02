import 'package:starapp/core/utils/json.dart';

enum ParticipantKind { creator, company, system }

/// The other side of a conversation, or a recipient in New Message: a
/// creator, a company, or the Star App team.
class Participant {
  const Participant({
    required this.id,
    required this.displayName,
    required this.kind,
    this.handle,
    this.avatarUrl,
    this.isVerified = false,
    this.roleLabel,
  });

  factory Participant.fromJson(Json json) => Participant(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    kind: readEnum(
      ParticipantKind.values,
      json['kind'],
      ParticipantKind.creator,
    ),
    handle: json['handle'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    isVerified: json['isVerified'] as bool? ?? false,
    roleLabel: json['roleLabel'] as String?,
  );

  /// Creator id, company id, or the system account's id.
  final String id;
  final String displayName;
  final ParticipantKind kind;

  /// Creators only, without the leading `@`.
  final String? handle;

  /// Photo or company logo; null draws [initials] (companies) or a glyph.
  final String? avatarUrl;
  final bool isVerified;

  /// e.g. "Producer", "Dancer", "Record label".
  final String? roleLabel;

  /// Up to two letters for a logo placeholder: "Afrowave Records" → "AR".
  String get initials {
    final words = displayName.trim().split(RegExp(r'\s+'));
    return words.take(2).map((w) => w.isEmpty ? '' : w[0]).join().toUpperCase();
  }

  /// First word of the name, as short copy uses it: "Message Afrowave…".
  String get shortName => displayName.trim().split(RegExp(r'\s+')).first;

  Json toJson() => {
    'id': id,
    'displayName': displayName,
    'kind': kind.name,
    'handle': handle,
    'avatarUrl': avatarUrl,
    'isVerified': isVerified,
    'roleLabel': roleLabel,
  };
}
