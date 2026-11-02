import 'package:starapp/features/auth/data/models/interest_category.dart';
import 'package:starapp/features/auth/data/models/language_option.dart';
import 'package:starapp/features/auth/data/models/preset_avatar.dart';

/// Sign-in, registration and password reset, plus the content the auth
/// screens offer (interests, languages, preset avatars). Screens read the
/// providers in `auth_providers.dart`; `authRepositoryProvider` picks
/// `MockAuthRepository` or `ApiAuthRepository` from `AppConfig`.
abstract interface class AuthRepository {
  /// Interest categories for the "Choose Your Interests" step, in order.
  Future<List<InterestCategory>> fetchInterestCategories();

  /// Rows of the language picker.
  Future<List<LanguageOption>> fetchLanguages();

  /// Preset avatars of the "Add a Profile Photo" step.
  Future<List<PresetAvatar>> fetchPresetAvatars();

  /// Signs in and stores the session's access token.
  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  /// Starts a registration and sends the verification code to [email].
  Future<void> signUp({required String fullName, required String email});

  /// Checks the emailed verification code (registration or password reset)
  /// and stores the access token it returns.
  Future<void> verifyOtp(String code);

  /// Sends a new verification code.
  Future<void> resendCode();

  /// Sends a password-reset verification code to [email].
  Future<void> requestPasswordReset(String email);

  /// Sets the new password at the end of the password reset.
  Future<void> resetPassword(String newPassword);

  /// Whether [username] is free to register.
  Future<bool> checkUsername(String username);
}
