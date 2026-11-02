import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/models/budget_range.dart';
import 'package:starapp/features/scout/data/models/talent_category.dart';

/// An open call as lists show it: the marketplace (`GET /scout/calls`) and a
/// company's open roles.
class OpenCallSummary {
  const OpenCallSummary({
    required this.id,
    required this.company,
    required this.title,
    required this.category,
    required this.budget,
    required this.closesAt,
    required this.postedAt,
    this.tags = const [],
    this.cities = const [],
    this.isRemote = false,
    this.startDate,
    this.endDate,
    this.applicantsCount = 0,
    this.applicantAvatarUrls = const [],
    this.isFeatured = false,
    this.isEligible = true,
    this.myStatus,
  });

  factory OpenCallSummary.fromJson(Json json) => OpenCallSummary(
    id: json['id'] as String,
    company: CompanySummary.fromJson(json['company'] as Json),
    title: json['title'] as String,
    category: readEnum(
      TalentCategory.values,
      json['category'],
      TalentCategory.music,
    ),
    budget: BudgetRange.fromJson(json['budget'] as Json),
    closesAt: readDate(json['closesAt']) ?? DateTime.now(),
    postedAt: readDate(json['postedAt']) ?? DateTime.now(),
    tags: readStrings(json['tags']),
    cities: readStrings(json['cities']),
    isRemote: json['isRemote'] as bool? ?? false,
    startDate: readDate(json['startDate']),
    endDate: readDate(json['endDate']),
    applicantsCount: readInt(json['applicantsCount']),
    applicantAvatarUrls: readStrings(json['applicantAvatarUrls']),
    isFeatured: json['isFeatured'] as bool? ?? false,
    isEligible: json['isEligible'] as bool? ?? true,
    myStatus: readEnumOrNull(ApplicationStatus.values, json['myStatus']),
  );

  final String id;
  final CompanySummary company;
  final String title;
  final TalentCategory category;
  final BudgetRange budget;

  /// Applications close at this time.
  final DateTime closesAt;
  final DateTime postedAt;

  /// Extra pills on the featured card, e.g. "Paid tour".
  final List<String> tags;

  /// Where the work happens, main city first.
  final List<String> cities;
  final bool isRemote;

  /// When the gig runs, if scheduled.
  final DateTime? startDate;
  final DateTime? endDate;
  final int applicantsCount;

  /// A few recent applicants' photos for the featured card.
  final List<String> applicantAvatarUrls;
  final bool isFeatured;

  /// Whether the user may apply; the call page names what's missing.
  final bool isEligible;

  /// The user's application, if they applied.
  final ApplicationStatus? myStatus;

  /// No longer accepting applications.
  bool isClosedAt(DateTime now) => !closesAt.isAfter(now);

  Json toJson() => {
    'id': id,
    'company': company.toJson(),
    'title': title,
    'category': category.name,
    'budget': budget.toJson(),
    'closesAt': closesAt.toUtc().toIso8601String(),
    'postedAt': postedAt.toUtc().toIso8601String(),
    'tags': tags,
    'cities': cities,
    'isRemote': isRemote,
    'startDate': startDate?.toUtc().toIso8601String(),
    'endDate': endDate?.toUtc().toIso8601String(),
    'applicantsCount': applicantsCount,
    'applicantAvatarUrls': applicantAvatarUrls,
    'isFeatured': isFeatured,
    'isEligible': isEligible,
    'myStatus': myStatus?.name,
  };
}

/// One line of an open call's requirements, checked against the user.
class OpenCallRequirement {
  const OpenCallRequirement({required this.label, this.isMet = true});

  factory OpenCallRequirement.fromJson(Json json) => OpenCallRequirement(
    label: json['label'] as String,
    isMet: json['isMet'] as bool? ?? true,
  );

  /// e.g. "Rising Nova tier or above".
  final String label;

  /// False when the user falls short; an unmet requirement is what makes a
  /// call not eligible.
  final bool isMet;

  Json toJson() => {'label': label, 'isMet': isMet};
}

/// The full open call (`GET /scout/calls/{id}`): the list fields in
/// [summary] plus the page's details, in one flat JSON object.
class OpenCall {
  const OpenCall({
    required this.summary,
    this.locationLabel = '',
    this.scheduleNote = '',
    this.description = '',
    this.requirements = const [],
  });

  factory OpenCall.fromJson(Json json) => OpenCall(
    summary: OpenCallSummary.fromJson(json),
    locationLabel: json['locationLabel'] as String? ?? '',
    scheduleNote: json['scheduleNote'] as String? ?? '',
    description: json['description'] as String? ?? '',
    requirements: readList(json['requirements'], OpenCallRequirement.fromJson),
  );

  final OpenCallSummary summary;

  /// A note on where, e.g. "Rehearsals in Lagos".
  final String locationLabel;

  /// A note on when, e.g. "12 shows".
  final String scheduleNote;
  final String description;
  final List<OpenCallRequirement> requirements;

  String get id => summary.id;

  /// The first requirement the user doesn't meet, shown when they can't
  /// apply.
  OpenCallRequirement? get unmetRequirement =>
      requirements.where((r) => !r.isMet).firstOrNull;

  Json toJson() => {
    ...summary.toJson(),
    'locationLabel': locationLabel,
    'scheduleNote': scheduleNote,
    'description': description,
    'requirements': [for (final r in requirements) r.toJson()],
  };
}
