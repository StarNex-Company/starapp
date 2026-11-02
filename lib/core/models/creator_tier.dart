/// Creator tiers, lowest first. Serialized by name (`"risingNova"`).
enum CreatorTier {
  shootingStar('Shooting Star'),
  risingNova('Rising Nova'),
  stellar('Stellar'),
  superNova('Super Nova'),
  universeIcon('Universe Icon');

  const CreatorTier(this.label);

  final String label;

  /// 1-based, as the design's "Tier 2" labels count.
  int get level => index + 1;

  /// The tier after this one; null at the top.
  CreatorTier? get next => index + 1 < values.length ? values[index + 1] : null;
}
