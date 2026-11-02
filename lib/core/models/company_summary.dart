import 'package:starapp/core/utils/json.dart';

/// A verified company as lists show it: Scout calls and requests, inbox
/// threads, wallet deals. The full page is `Company` in the scout feature.
class CompanySummary {
  const CompanySummary({
    required this.id,
    required this.name,
    this.logoUrl,
    this.type = '',
    this.city = '',
    this.country = '',
    this.isVerified = false,
  });

  factory CompanySummary.fromJson(Json json) => CompanySummary(
    id: json['id'] as String,
    name: json['name'] as String,
    logoUrl: json['logoUrl'] as String?,
    type: json['type'] as String? ?? '',
    city: json['city'] as String? ?? '',
    country: json['country'] as String? ?? '',
    isVerified: json['isVerified'] as bool? ?? false,
  );

  final String id;
  final String name;

  /// Network URL (an asset path in mock data); null shows [initials].
  final String? logoUrl;

  /// e.g. "Record label".
  final String type;
  final String city;
  final String country;
  final bool isVerified;

  /// Up to two letters for a logo placeholder: "Afrowave Records" → "AR".
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(2).map((w) => w.isEmpty ? '' : w[0]).join().toUpperCase();
  }

  /// "Lagos, Nigeria"; whichever parts are known.
  String get locationLabel =>
      [city, country].where((part) => part.isNotEmpty).join(', ');

  Json toJson() => {
    'id': id,
    'name': name,
    'logoUrl': logoUrl,
    'type': type,
    'city': city,
    'country': country,
    'isVerified': isVerified,
  };
}
