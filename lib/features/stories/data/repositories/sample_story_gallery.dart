import 'package:starapp/features/stories/data/models/new_story.dart';

/// Stands in for the device camera roll in "Add to story": there's no
/// gallery or camera plugin yet, so the picker offers these bundled photos
/// and clips from the design.
const sampleStoryGallery = [
  StoryMedia.photo('$_img/gallery_braids.jpg'),
  StoryMedia.video('$_img/gallery_studio.jpg', Duration(seconds: 24)),
  StoryMedia.photo('$_img/gallery_glasses.jpg'),
  StoryMedia.photo('$_img/story_gabriel_1.jpg'),
  StoryMedia.video('$_img/story_sarah_1.jpg', Duration(seconds: 12)),
  StoryMedia.photo('$_img/story_sarah_2.jpg'),
  StoryMedia.video('$_img/story_funmilayo_1.jpg', Duration(seconds: 30)),
  StoryMedia.photo('$_img/gallery_concept_city.jpg'),
  StoryMedia.video('$_img/gallery_portrait.jpg', Duration(seconds: 18)),
  StoryMedia.photo('$_img/gallery_curly.jpg'),
  StoryMedia.photo('$_img/story_freestyle.jpg'),
  StoryMedia.video('$_img/gallery_photo_wall.jpg', Duration(seconds: 9)),
];

const _img = 'assets/images/stories';
