/// Asset paths for the auth screens (exported from the STAR-APP Figma file).
///
/// All live directly under the already-bundled `assets/vectors/` and
/// `assets/images/` roots, prefixed `auth_`.
abstract final class AuthAssets {
  // Header
  static const logo = 'assets/vectors/auth_logo.svg'; // 33×29 navy "S"
  static const globe = 'assets/vectors/auth_globe.svg'; // 16.5 (in a 20 box)

  // Field icons (22×22, #000207)
  static const person =
      'assets/vectors/auth_person.svg'; // boxicons:user-filled
  static const mail = 'assets/vectors/auth_mail.svg'; // ic:round-email
  static const lock = 'assets/vectors/auth_lock.svg'; // mdi:password
  static const eyeOff =
      'assets/vectors/auth_eye_off.svg'; // mdi:hide-outline (obscured)
  static const eye = 'assets/vectors/auth_eye.svg'; // mdi:eye-outline (visible)
  static const fieldCheck =
      'assets/vectors/auth_field_check.svg'; // green tick (valid)

  // Checkbox (checked state of the Check component)
  static const checkOn = 'assets/vectors/auth_check_on.svg';

  // Social (24×24)
  static const google = 'assets/vectors/auth_google.svg';
  static const apple = 'assets/vectors/auth_apple.svg';

  // Decoration
  static const wave = 'assets/vectors/auth_wave.svg'; // bottom wave (Group 46)
  static const starIcon = 'assets/vectors/auth_star_icon.svg'; // 94×94 app icon
  static const welcomeBackground = 'assets/images/auth_welcome_bg.jpg';
}
