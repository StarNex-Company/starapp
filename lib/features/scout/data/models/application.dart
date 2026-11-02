import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/scout/data/models/talent_category.dart';

/// Where an application stands. Serialized by name (`"inReview"`).
enum ApplicationStatus {
  sent,
  inReview,
  shortlisted,

  /// The company made an offer; it continues in a conversation.
  offer,
  declined,
  withdrawn,
  expired,

  /// The gig is done and paid; it links to the wallet transaction.
  completed;

  /// Still in progress: listed under "Active" rather than "Closed".
  bool get isActive => switch (this) {
    sent || inReview || shortlisted || offer => true,
    declined || withdrawn || expired || completed => false,
  };
}

/// One of the user's applications (`GET /scout/applications`): to an open
/// call, or the deal that followed a Scout request.
class Application {
  const Application({
    required this.id,
    required this.title,
    required this.company,
    required this.appliedAt,
    required this.status,
    this.openCallId,
    this.scoutRequestId,
    this.category,
    this.updatedAt,
    this.conversationId,
    this.transactionId,
  });

  factory Application.fromJson(Json json) => Application(
    id: json['id'] as String,
    title: json['title'] as String,
    company: CompanySummary.fromJson(json['company'] as Json),
    appliedAt: readDate(json['appliedAt']) ?? DateTime.now(),
    status: readEnum(
      ApplicationStatus.values,
      json['status'],
      ApplicationStatus.sent,
    ),
    openCallId: json['openCallId'] as String?,
    scoutRequestId: json['scoutRequestId'] as String?,
    category: readEnumOrNull(TalentCategory.values, json['category']),
    updatedAt: readDate(json['updatedAt']),
    conversationId: json['conversationId'] as String?,
    transactionId: json['transactionId'] as String?,
  );

  final String id;
  final String title;
  final CompanySummary company;
  final DateTime appliedAt;
  final ApplicationStatus status;

  /// The open call applied to; null when the deal came from a Scout request.
  final String? openCallId;
  final String? scoutRequestId;

  /// Picks the row's icon.
  final TalentCategory? category;

  /// When [status] last changed; closed rows show it.
  final DateTime? updatedAt;

  /// Set once there is an offer.
  final String? conversationId;

  /// Set once a completed gig is paid.
  final String? transactionId;

  bool get isActive => status.isActive;

  Json toJson() => {
    'id': id,
    'title': title,
    'company': company.toJson(),
    'appliedAt': appliedAt.toUtc().toIso8601String(),
    'status': status.name,
    'openCallId': openCallId,
    'scoutRequestId': scoutRequestId,
    'category': category?.name,
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
    'conversationId': conversationId,
    'transactionId': transactionId,
  };
}

/// The marketplace's "Your applications" counts
/// (`GET /scout/applications/summary`).
class ApplicationsSummary {
  const ApplicationsSummary({
    this.sent = 0,
    this.inReview = 0,
    this.shortlisted = 0,
    this.total = 0,
  });

  factory ApplicationsSummary.fromJson(Json json) => ApplicationsSummary(
    sent: readInt(json['sent']),
    inReview: readInt(json['inReview']),
    shortlisted: readInt(json['shortlisted']),
    total: readInt(json['total']),
  );

  /// Sent and not yet picked up for review.
  final int sent;
  final int inReview;
  final int shortlisted;

  /// Every active application, offers included; the "My Applications" pill.
  final int total;

  /// The counts after [delta] new applications were sent.
  ApplicationsSummary withSent(int delta) => ApplicationsSummary(
    sent: sent + delta,
    inReview: inReview,
    shortlisted: shortlisted,
    total: total + delta,
  );

  Json toJson() => {
    'sent': sent,
    'inReview': inReview,
    'shortlisted': shortlisted,
    'total': total,
  };
}
