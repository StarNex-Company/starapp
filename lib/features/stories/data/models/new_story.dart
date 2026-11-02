/// A photo or video in the "Add to story" picker.
class StoryMedia {
  const StoryMedia.photo(this.path) : duration = null;
  const StoryMedia.video(this.path, Duration this.duration);

  /// Local path of the picked file; a bundled sample in the placeholder
  /// camera roll.
  final String path;

  /// Clip length, for videos.
  final Duration? duration;

  bool get isVideo => duration != null;
}

/// Who can see a new story. The name is what `POST /stories` sends.
enum StoryAudience {
  everyone('Everyone', 'Public (anyone on Star App)'),
  followers('Followers', 'Only people who follow you'),
  closeFriends('Close friends', 'A list you choose · 12 people');

  const StoryAudience(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

/// How long a new story stays up.
enum StoryDuration {
  h3(3),
  h6(6),
  h12(12),
  h24(24),
  h48(48);

  const StoryDuration(this.hours);

  final int hours;

  String get label => '${hours}h';
}

/// Audience and duration chosen in the Story settings sheet.
class StorySettings {
  const StorySettings({
    this.audience = StoryAudience.followers,
    this.duration = StoryDuration.h24,
  });

  final StoryAudience audience;
  final StoryDuration duration;

  StorySettings copyWith({StoryAudience? audience, StoryDuration? duration}) =>
      StorySettings(
        audience: audience ?? this.audience,
        duration: duration ?? this.duration,
      );

  @override
  bool operator ==(Object other) =>
      other is StorySettings &&
      other.audience == audience &&
      other.duration == duration;

  @override
  int get hashCode => Object.hash(audience, duration);
}
