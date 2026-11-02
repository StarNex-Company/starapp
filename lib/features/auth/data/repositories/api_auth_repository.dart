import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/token_store.dart';
import 'package:starapp/core/utils/json.dart';
import 'package:starapp/features/auth/data/models/interest_category.dart';
import 'package:starapp/features/auth/data/models/language_option.dart';
import 'package:starapp/features/auth/data/models/preset_avatar.dart';
import 'package:starapp/features/auth/data/repositories/auth_repository.dart';

/// [AuthRepository] over the API. Sign-in and code verification answer
/// `{"accessToken": "…"}`, which goes into [TokenStore]; `ApiClient` then
/// sends it with every request, including the password reset.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client, this._tokens);

  final ApiClient _client;
  final TokenStore _tokens;

  /// Where the current verification code was sent (sign-up or password
  /// reset); the verify and resend calls send it back.
  String? _email;

  @override
  Future<List<InterestCategory>> fetchInterestCategories() => _client.get(
    '/interests',
    decode: (json) => readList(json, InterestCategory.fromJson),
  );

  @override
  Future<List<LanguageOption>> fetchLanguages() => _client.get(
    '/languages',
    decode: (json) => readList(json, LanguageOption.fromJson),
  );

  @override
  Future<List<PresetAvatar>> fetchPresetAvatars() => _client.get(
    '/avatars/presets',
    decode: (json) => readList(json, PresetAvatar.fromJson),
  );

  @override
  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) => _signIn(
    '/auth/login',
    data: {'email': email, 'password': password, 'rememberMe': rememberMe},
  );

  @override
  Future<void> signUp({required String fullName, required String email}) {
    _email = email;
    return _client.post<void>(
      '/auth/register',
      data: {'fullName': fullName, 'email': email},
    );
  }

  @override
  Future<void> verifyOtp(String code) =>
      _signIn('/auth/otp/verify', data: {'email': _email, 'code': code});

  @override
  Future<void> resendCode() =>
      _client.post<void>('/auth/otp/resend', data: {'email': _email});

  @override
  Future<void> requestPasswordReset(String email) {
    _email = email;
    return _client.post<void>('/auth/password/forgot', data: {'email': email});
  }

  @override
  Future<void> resetPassword(String newPassword) => _client.post<void>(
    '/auth/password/reset',
    data: {'password': newPassword},
  );

  @override
  Future<bool> checkUsername(String username) => _client.get(
    '/auth/username-available',
    query: {'username': username},
    decode: (json) => (json as Json)['available'] as bool? ?? false,
  );

  /// Posts [data] to [path] and keeps the access token it answers with.
  Future<void> _signIn(String path, {required Json data}) async {
    final token = await _client.post(
      path,
      data: data,
      decode: (json) => (json as Json)['accessToken'] as String,
    );
    await _tokens.write(token);
  }
}
