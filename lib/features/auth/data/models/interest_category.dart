import 'package:starapp/core/utils/json.dart';

/// A group of interests offered at the registration "Choose Your Interests"
/// step (`GET /interests`).
class InterestCategory {
  const InterestCategory(this.title, this.interests);

  factory InterestCategory.fromJson(Json json) =>
      InterestCategory(json['title'] as String, readStrings(json['interests']));

  final String title;
  final List<String> interests;

  Json toJson() => {'title': title, 'interests': interests};
}
