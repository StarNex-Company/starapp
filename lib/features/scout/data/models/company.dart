import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/core/models/creator_tier.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';

/// What a creator said about working with a company.
class Testimonial {
  const Testimonial({
    required this.quote,
    required this.createdAt,
    this.authorName,
    this.authorTier,
  });

  factory Testimonial.fromJson(Json json) => Testimonial(
    quote: json['quote'] as String,
    createdAt: readDate(json['createdAt']) ?? DateTime.now(),
    authorName: json['authorName'] as String?,
    authorTier: readEnumOrNull(CreatorTier.values, json['authorTier']),
  );

  final String quote;
  final DateTime createdAt;

  /// Short public name, e.g. "Kofi M."; null when anonymous.
  final String? authorName;
  final CreatorTier? authorTier;

  Json toJson() => {
    'quote': quote,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'authorName': authorName,
    'authorTier': authorTier?.name,
  };
}

/// A company's page (`GET /companies/{id}`): the [CompanySummary] fields
/// plus its facts, open roles and testimonials, in one flat JSON object.
class Company {
  const Company({
    required this.summary,
    this.coverUrl,
    this.followersCount = 0,
    this.foundedYear,
    this.verificationNote = '',
    this.rating,
    this.reviewsCount = 0,
    this.artistsSignedCount = 0,
    this.creatorsHiredCount = 0,
    this.isFollowing = false,
    this.openRoles = const [],
    this.testimonials = const [],
  });

  factory Company.fromJson(Json json) => Company(
    summary: CompanySummary.fromJson(json),
    coverUrl: json['coverUrl'] as String?,
    followersCount: readInt(json['followersCount']),
    foundedYear: json['foundedYear'] == null
        ? null
        : readInt(json['foundedYear']),
    verificationNote: json['verificationNote'] as String? ?? '',
    rating: json['rating'] == null ? null : readDouble(json['rating']),
    reviewsCount: readInt(json['reviewsCount']),
    artistsSignedCount: readInt(json['artistsSignedCount']),
    creatorsHiredCount: readInt(json['creatorsHiredCount']),
    isFollowing: json['isFollowing'] as bool? ?? false,
    openRoles: readList(json['openRoles'], OpenCallSummary.fromJson),
    testimonials: readList(json['testimonials'], Testimonial.fromJson),
  );

  final CompanySummary summary;

  /// Banner photo; null shows the brand gradient.
  final String? coverUrl;
  final int followersCount;
  final int? foundedYear;

  /// What Star App checked, e.g. "Business registration, website and
  /// payment method checked by Star App."
  final String verificationNote;

  /// Average creator rating out of 5; null until it has reviews.
  final double? rating;
  final int reviewsCount;
  final int artistsSignedCount;
  final int creatorsHiredCount;
  final bool isFollowing;
  final List<OpenCallSummary> openRoles;
  final List<Testimonial> testimonials;

  String get id => summary.id;

  Company copyWith({bool? isFollowing, int? followersCount}) => Company(
    summary: summary,
    coverUrl: coverUrl,
    followersCount: followersCount ?? this.followersCount,
    foundedYear: foundedYear,
    verificationNote: verificationNote,
    rating: rating,
    reviewsCount: reviewsCount,
    artistsSignedCount: artistsSignedCount,
    creatorsHiredCount: creatorsHiredCount,
    isFollowing: isFollowing ?? this.isFollowing,
    openRoles: openRoles,
    testimonials: testimonials,
  );

  Json toJson() => {
    ...summary.toJson(),
    'coverUrl': coverUrl,
    'followersCount': followersCount,
    'foundedYear': foundedYear,
    'verificationNote': verificationNote,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'artistsSignedCount': artistsSignedCount,
    'creatorsHiredCount': creatorsHiredCount,
    'isFollowing': isFollowing,
    'openRoles': [for (final r in openRoles) r.toJson()],
    'testimonials': [for (final t in testimonials) t.toJson()],
  };
}
