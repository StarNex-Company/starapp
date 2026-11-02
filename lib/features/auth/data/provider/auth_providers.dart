import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/config/app_config.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/token_store.dart';
import 'package:starapp/features/auth/data/models/interest_category.dart';
import 'package:starapp/features/auth/data/models/language_option.dart';
import 'package:starapp/features/auth/data/models/preset_avatar.dart';
import 'package:starapp/features/auth/data/models/registration.dart';
import 'package:starapp/features/auth/data/repositories/api_auth_repository.dart';
import 'package:starapp/features/auth/data/repositories/auth_repository.dart';
import 'package:starapp/features/auth/data/repositories/mock_auth_repository.dart';

/// Picks the implementation from [AppConfig.useMockData], like
/// `selectRepository`; written out because the API one also takes the
/// [TokenStore] that sign-in writes to.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.watch(appConfigProvider).useMockData
      ? const MockAuthRepository()
      : ApiAuthRepository(
          ref.watch(apiClientProvider),
          ref.watch(tokenStoreProvider),
        ),
);

/// Categories of the "Choose Your Interests" step.
final interestCategoriesProvider = FutureProvider<List<InterestCategory>>(
  (ref) => ref.watch(authRepositoryProvider).fetchInterestCategories(),
);

/// Rows of the language picker.
final languageOptionsProvider = FutureProvider<List<LanguageOption>>(
  (ref) => ref.watch(authRepositoryProvider).fetchLanguages(),
);

/// Preset avatars of the "Add a Profile Photo" step.
final presetAvatarsProvider = FutureProvider<List<PresetAvatar>>(
  (ref) => ref.watch(authRepositoryProvider).fetchPresetAvatars(),
);

/// The registration in progress: each sign-up step records its choices here
/// as the user continues past it.
final registrationProvider =
    NotifierProvider<RegistrationNotifier, Registration>(
      RegistrationNotifier.new,
    );

class RegistrationNotifier extends Notifier<Registration> {
  @override
  Registration build() => const Registration();

  /// Step 1: name and email.
  void setAccount({required String fullName, required String email}) =>
      state = state.copyWith(fullName: fullName, email: email);

  /// Step 3: username and date of birth.
  void setProfile({required String username, required DateTime dateOfBirth}) =>
      state = state.copyWith(username: username, dateOfBirth: dateOfBirth);

  /// Step 4: the chosen preset avatar's asset; null when the step is skipped.
  void setAvatar(String? avatar) => state = avatar == null
      ? state.copyWith(clearAvatar: true)
      : state.copyWith(avatar: avatar);

  /// Interests step; empty when skipped.
  void setInterests(Iterable<String> interests) =>
      state = state.copyWith(interests: Set.unmodifiable(interests));

  /// Discards the registration.
  void reset() => state = const Registration();
}
