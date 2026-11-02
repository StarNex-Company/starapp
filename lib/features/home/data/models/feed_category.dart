/// The tabs above the feed. The name is sent as `GET /feed?tab=`.
enum FeedCategory {
  following('Following'),
  discover('Discover'),
  featuredCreators('Featured Creators');

  const FeedCategory(this.label);
  final String label;
}
