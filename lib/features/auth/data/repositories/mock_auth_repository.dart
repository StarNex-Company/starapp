import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/auth/data/models/interest_category.dart';
import 'package:starapp/features/auth/data/models/language_option.dart';
import 'package:starapp/features/auth/data/models/preset_avatar.dart';
import 'package:starapp/features/auth/data/repositories/auth_repository.dart';

/// Serves the fixtures below, shaped like the `GET /interests`,
/// `GET /languages` and `GET /avatars/presets` responses, through the real
/// `fromJson`. Accepts every sign-in, code and password; only the usernames
/// in [_takenUsernames] are unavailable. Mock mode keeps no token.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<List<InterestCategory>> fetchInterestCategories() async =>
      readList(_interests, InterestCategory.fromJson);

  @override
  Future<List<LanguageOption>> fetchLanguages() async =>
      readList(_languages, LanguageOption.fromJson);

  @override
  Future<List<PresetAvatar>> fetchPresetAvatars() async =>
      readList(_presetAvatars, PresetAvatar.fromJson);

  @override
  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {}

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
  }) async {}

  @override
  Future<void> verifyOtp(String code) async {}

  @override
  Future<void> resendCode() async {}

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<void> resetPassword(String newPassword) async {}

  @override
  Future<bool> checkUsername(String username) async =>
      !_takenUsernames.contains(username.trim().toLowerCase());
}

/// The design's interest categories, in order.
const _interests = [
  {
    'title': 'Music',
    'interests': [
      'Singing',
      'Songwriting',
      'DJing',
      'Choir',
      'Live Performance',
      'Freestyle',
      'Gospel Music',
      'Beat Production',
      'Instrument Playing',
    ],
  },
  {
    'title': 'Creative Arts',
    'interests': [
      'Photography',
      'UI/UX Design',
      'Videography',
      'Graphic Design',
      'Fashion Design',
      'Digital Art',
      'Content Creation',
      'Makeup Art',
      'Animation',
      'Painting',
    ],
  },
  {
    'title': 'Entertainment & Lifestyle',
    'interests': [
      'Comedy',
      'Dance',
      'Acting',
      'Influencing',
      'Gaming',
      'Lifestyle',
      'Fitness',
      'Vlogging',
      'Public Speaking',
      'Sports',
    ],
  },
  {
    'title': 'Business & Career',
    'interests': [
      'Entrepreneurship',
      'Personal Branding',
      'Startup Ideas',
      'Marketing',
      'Tech Innovation',
      'Networking',
      'Freelancing',
      'Career Growth',
      'Leadership',
      'Business Coaching',
    ],
  },
];

Json _language(String name, String englishName, String region, String tag) => {
  'name': name,
  'englishName': englishName,
  'region': region,
  'locale': tag,
};

/// The design's language list first, then the app's other locales by English
/// name. Languages the app can't switch to yet (Pidgin, Hausa, Igbo, Yoruba,
/// Javanese…) are listed too; the screen shows them disabled.
final _languages = [
  // The design's list.
  _language('العربية', 'Arabic', 'Algeria', 'ar-DZ'),
  _language('English', 'English', 'USA', 'en-US'),
  _language('English', 'English', 'UK', 'en-GB'),
  _language('English', 'English', 'Canada', 'en-CA'),
  _language('Español', 'Spanish', 'Spanish', 'es'),
  _language('Français', 'French', 'France', 'fr-FR'),
  _language('Français', 'French', 'Canada', 'fr-CA'),
  _language('Français', 'French', 'USA', 'fr-US'),
  _language('हिन्दी', 'Hindi', 'India', 'hi-IN'),
  _language('Hausa', 'Hausa', 'Nigeria', 'ha-NG'),
  _language('Igbo', 'Igbo', 'Nigeria', 'ig-NG'),
  _language('Pidgin', 'Nigerian Pidgin', 'Nigeria', 'pcm-NG'),
  _language('Yorùbá', 'Yoruba', 'Nigeria', 'yo-NG'),
  // The app's other locales, by English name.
  _language('বাংলা', 'Bengali', 'Bangladesh', 'bn'),
  _language('中文', 'Chinese', 'China', 'zh'),
  _language('Deutsch', 'German', 'Germany', 'de'),
  _language('Bahasa Indonesia', 'Indonesian', 'Indonesia', 'id'),
  _language('Italiano', 'Italian', 'Italy', 'it'),
  _language('日本語', 'Japanese', 'Japan', 'ja'),
  _language('Basa Jawa', 'Javanese', 'Indonesia', 'jv'),
  _language('한국어', 'Korean', 'South Korea', 'ko'),
  _language('Bahasa Melayu', 'Malay', 'Malaysia', 'ms'),
  _language('Português', 'Portuguese', 'Portugal', 'pt'),
  _language('ਪੰਜਾਬੀ', 'Punjabi', 'India', 'pa'),
  _language('Русский', 'Russian', 'Russia', 'ru'),
  _language('ไทย', 'Thai', 'Thailand', 'th'),
  _language('Türkçe', 'Turkish', 'Türkiye', 'tr'),
  _language('Tiếng Việt', 'Vietnamese', 'Vietnam', 'vi'),
];

Json _avatar(int n, String label, List<double> thumb, List<double> photo) {
  Json rect(List<double> r) => {
    'left': r[0],
    'top': r[1],
    'width': r[2],
    'height': r[3],
  };
  return {
    'imageUrl': 'assets/images/auth_avatar_$n.png',
    'label': label,
    'thumb': rect(thumb),
    'photo': rect(photo),
  };
}

/// The nine preset avatars of "Add a Profile Photo"; the first is the
/// "No photo" placeholder. Crops are `[left, top, width, height]`.
final _presetAvatars = [
  _avatar(
    1,
    'No photo',
    [-0.2569, -0.2523, 1.5112, 1.5112],
    [-0.2070, -0.1987, 1.4032, 1.4032],
  ),
  _avatar(
    2,
    'Avatar 1',
    [-0.1165, -0.1363, 1.2354, 1.2829],
    [-0.0768, -0.0989, 1.1536, 1.1979],
  ),
  _avatar(3, 'Avatar 2', [0, 0, 1, 1], [-0.0343, 0.0027, 1.0569, 1.0569]),
  _avatar(
    4,
    'Avatar 3',
    [-0.3811, -0.1141, 1.7455, 1.2302],
    [-0.3081, -0.0703, 1.6118, 1.1360],
  ),
  _avatar(
    5,
    'Avatar 4',
    [-0.4309, -0.0700, 1.8612, 1.2415],
    [-0.3756, -0.0291, 1.7483, 1.1662],
  ),
  _avatar(6, 'Avatar 5', [0, 0, 1, 1], [-0.0405, -0.0375, 1.0804, 1.0804]),
  _avatar(7, 'Avatar 6', [0, 0, 1, 1], [-0.0048, -0.0068, 1.0046, 1.0046]),
  _avatar(
    8,
    'Avatar 7',
    [-0.4744, -0.1025, 1.9707, 1.2985],
    [-0.3726, -0.0718, 1.7423, 1.1480],
  ),
  _avatar(
    9,
    'Avatar 8',
    [-0.0841, -0.0023, 1.1756, 1.1756],
    [-0.0309, 0.0015, 1.0509, 1.0509],
  ),
];

/// Usernames the mock availability check treats as taken (lowercase).
const _takenUsernames = {
  'admin',
  'star',
  'starapp',
  'support',
  'help',
  'test',
  'user',
  'micheal',
};
