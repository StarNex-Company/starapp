import 'package:starapp/features/stories/data/models/new_story.dart';

/// Stands in for the device camera roll in "Add to story": there's no
/// gallery or camera plugin yet, so the picker offers these bundled photos
/// and clips from the design.
const sampleStoryGallery = [
  StoryMedia.photo('assets/images/shared/creator_amina.jpg'),
  StoryMedia.video('assets/images/shared/arena_studio.jpg', Duration(seconds: 24)),
  StoryMedia.photo('assets/images/shared/avatar_you.jpg'),
  StoryMedia.photo('$_img/story_gabriel_1.jpg'),
  StoryMedia.video('$_img/story_sarah_1.jpg', Duration(seconds: 12)),
  StoryMedia.photo('$_img/story_sarah_2.jpg'),
  StoryMedia.video('$_img/story_funmilayo_1.jpg', Duration(seconds: 30)),
  StoryMedia.photo('assets/images/shared/hub_banner_concept_art.jpg'),
  StoryMedia.video('$_img/gallery_portrait.jpg', Duration(seconds: 18)),
  StoryMedia.photo('assets/images/shared/entry_video_frame.jpg'),
  StoryMedia.photo('$_img/story_freestyle.jpg'),
  StoryMedia.video('$_img/gallery_photo_wall.jpg', Duration(seconds: 9)),
];

const _img = 'assets/images/stories';
