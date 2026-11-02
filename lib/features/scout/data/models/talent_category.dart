/// The talent an open call is for. Serialized by name (`"visualArts"`).
enum TalentCategory {
  music('Music'),
  dance('Dance'),
  acting('Acting'),
  comedy('Comedy'),
  visualArts('Visual arts');

  const TalentCategory(this.label);

  final String label;
}
