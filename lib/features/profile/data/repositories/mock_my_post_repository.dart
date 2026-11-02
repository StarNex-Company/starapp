import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/profile/data/models/my_post.dart';
import 'package:starapp/features/profile/data/repositories/my_post_repository.dart';

/// Serves the posts below, shaped like the `GET /me/posts/{id}` response,
/// through the real `fromJson`. Unknown ids fall back to the first post so
/// links from other mock fixtures always open something.
class MockMyPostRepository implements MyPostRepository {
  const MockMyPostRepository();

  @override
  Future<MyPost> fetchPost(String id) async {
    final posts = _posts(DateTime.now());
    return MyPost.fromJson(
      posts.firstWhere((p) => p['id'] == id, orElse: () => posts.first),
    );
  }

  @override
  Future<void> setStarred(String postId, {required bool starred}) async {}

  @override
  Future<void> setSaved(String postId, {required bool saved}) async {}

  @override
  Future<void> deletePost(String postId) async {}
}

const _studio = 'assets/images/create/preview_cover_studio.jpg';

/// The posts behind the profile grid, Top posts and Star Insights.
List<Json> _posts(DateTime now) {
  Json post(
    String id,
    String title, {
    required String poster,
    required String caption,
    required String hashtag,
    required int stars,
    required int comments,
    required int saves,
    required int views,
    required int starsEarned,
    required int daysAgo,
  }) => {
    'id': id,
    'title': title,
    'posterUrl': poster,
    'videoUrl': null,
    'caption': caption,
    'hashtag': hashtag,
    'sound': 'Original Sound · Emmanuel Ayanleye',
    'durationMs': 12000,
    'createdAt': now
        .subtract(Duration(days: daysAgo))
        .toUtc()
        .toIso8601String(),
    'stars': stars,
    'comments': comments,
    'saves': saves,
    'views': views,
    'starsEarned': starsEarned,
    'isStarred': false,
    'isSaved': false,
  };

  return [
    post(
      'late-night-vocal-run',
      'Late-night vocal run',
      poster: _studio,
      caption: 'Late-night vocal run over my own beat 🎤 ',
      hashtag: '#AfroBeatsClash',
      stars: 1098,
      comments: 30100,
      saves: 123,
      views: 4200,
      starsEarned: 312,
      daysAgo: 3,
    ),
    post(
      'studio-session-freestyle',
      'Studio session freestyle',
      poster: 'assets/images/home/avatar_you.jpg',
      caption: 'Freestyling between takes, no edits 🎙️ ',
      hashtag: '#OwnTheSpotlight',
      stars: 742,
      comments: 1800,
      saves: 96,
      views: 2800,
      starsEarned: 204,
      daysAgo: 9,
    ),
    post(
      'gbedu-dance-cover',
      'Gbedu dance cover',
      poster: _studio,
      caption: 'Gbedu dance cover, one take 💃 ',
      hashtag: '#AfroDanceTakeover',
      stars: 701,
      comments: 1500,
      saves: 88,
      views: 2800,
      starsEarned: 204,
      daysAgo: 16,
    ),
    post(
      'sunday-choir-rehearsal',
      'Sunday choir rehearsal',
      poster: 'assets/images/home/post_adeboye_portrait.jpg',
      caption: 'Sunday choir rehearsal, harmonies on point 🙌 ',
      hashtag: '#GospelVibes',
      stars: 518,
      comments: 940,
      saves: 61,
      views: 1900,
      starsEarned: 141,
      daysAgo: 24,
    ),
    post(
      'afro-beats-cover-burna-boy',
      'Afro-beats cover · Burna Boy',
      poster: 'assets/images/profile/post_afrobeats_cover.jpg',
      caption: 'My take on a Burna Boy classic 🔥 ',
      hashtag: '#AfroBeatsClash',
      stars: 389,
      comments: 620,
      saves: 44,
      views: 1400,
      starsEarned: 96,
      daysAgo: 38,
    ),
    post(
      'behind-the-beat',
      'Behind the beat',
      poster: 'assets/images/stories/gallery_concept_city.jpg',
      caption: 'How this beat came together, layer by layer 🎛️ ',
      hashtag: '#BehindTheBeat',
      stars: 214,
      comments: 310,
      saves: 27,
      views: 940,
      starsEarned: 61,
      daysAgo: 52,
    ),
  ];
}
