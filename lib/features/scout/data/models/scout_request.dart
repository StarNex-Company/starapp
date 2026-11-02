import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/core/models/money.dart';
import 'package:starapp/core/utils/json.dart';

/// Where a Scout request stands. Serialized by name.
enum ScoutRequestStatus { pending, accepted, declined, expired }

/// A verified company inviting the user to a role (`GET /scout/requests/{id}`).
class ScoutRequest {
  const ScoutRequest({
    required this.id,
    required this.company,
    required this.roleTitle,
    required this.budget,
    required this.shootStart,
    required this.shootEnd,
    required this.location,
    required this.senderName,
    required this.message,
    required this.sentAt,
    this.isPaid = true,
    this.contractDays = 0,
    this.senderTitle = '',
    this.senderAvatarUrl,
    this.attachments = const [],
    this.starsBonus = 0,
    this.status = ScoutRequestStatus.pending,
    this.isNew = false,
    this.reportedByMe = false,
    this.conversationId,
  });

  factory ScoutRequest.fromJson(Json json) => ScoutRequest(
    id: json['id'] as String,
    company: CompanySummary.fromJson(json['company'] as Json),
    roleTitle: json['roleTitle'] as String,
    budget: Money.fromJson(json['budget'] as Json),
    shootStart: readDate(json['shootStart']) ?? DateTime.now(),
    shootEnd: readDate(json['shootEnd']) ?? DateTime.now(),
    location: json['location'] as String? ?? '',
    senderName: json['senderName'] as String,
    message: json['message'] as String? ?? '',
    sentAt: readDate(json['sentAt']) ?? DateTime.now(),
    isPaid: json['isPaid'] as bool? ?? true,
    contractDays: readInt(json['contractDays']),
    senderTitle: json['senderTitle'] as String? ?? '',
    senderAvatarUrl: json['senderAvatarUrl'] as String?,
    attachments: readList(json['attachments'], Attachment.fromJson),
    starsBonus: readInt(json['starsBonus']),
    status: readEnum(
      ScoutRequestStatus.values,
      json['status'],
      ScoutRequestStatus.pending,
    ),
    isNew: json['isNew'] as bool? ?? false,
    reportedByMe: json['reportedByMe'] as bool? ?? false,
    conversationId: json['conversationId'] as String?,
  );

  final String id;
  final CompanySummary company;
  final String roleTitle;
  final Money budget;
  final DateTime shootStart;
  final DateTime shootEnd;

  /// e.g. "Lekki, Lagos".
  final String location;
  final bool isPaid;
  final int contractDays;

  /// The recruiter who wrote [message].
  final String senderName;

  /// e.g. "Talent Lead".
  final String senderTitle;
  final String? senderAvatarUrl;
  final String message;
  final DateTime sentAt;
  final List<Attachment> attachments;

  /// Stars added to the user's count for being scouted; 0 hides the notice.
  final int starsBonus;
  final ScoutRequestStatus status;

  /// Not opened yet; the requests list badges it "New".
  final bool isNew;
  final bool reportedByMe;

  /// Set once the request is accepted or the user asked about it.
  final String? conversationId;

  bool get isPending => status == ScoutRequestStatus.pending;

  ScoutRequest copyWith({
    ScoutRequestStatus? status,
    bool? isNew,
    bool? reportedByMe,
    String? conversationId,
  }) => ScoutRequest(
    id: id,
    company: company,
    roleTitle: roleTitle,
    budget: budget,
    shootStart: shootStart,
    shootEnd: shootEnd,
    location: location,
    senderName: senderName,
    message: message,
    sentAt: sentAt,
    isPaid: isPaid,
    contractDays: contractDays,
    senderTitle: senderTitle,
    senderAvatarUrl: senderAvatarUrl,
    attachments: attachments,
    starsBonus: starsBonus,
    status: status ?? this.status,
    isNew: isNew ?? this.isNew,
    reportedByMe: reportedByMe ?? this.reportedByMe,
    conversationId: conversationId ?? this.conversationId,
  );

  Json toJson() => {
    'id': id,
    'company': company.toJson(),
    'roleTitle': roleTitle,
    'budget': budget.toJson(),
    'shootStart': shootStart.toUtc().toIso8601String(),
    'shootEnd': shootEnd.toUtc().toIso8601String(),
    'location': location,
    'isPaid': isPaid,
    'contractDays': contractDays,
    'senderName': senderName,
    'senderTitle': senderTitle,
    'senderAvatarUrl': senderAvatarUrl,
    'message': message,
    'sentAt': sentAt.toUtc().toIso8601String(),
    'attachments': [for (final a in attachments) a.toJson()],
    'starsBonus': starsBonus,
    'status': status.name,
    'isNew': isNew,
    'reportedByMe': reportedByMe,
    'conversationId': conversationId,
  };
}
