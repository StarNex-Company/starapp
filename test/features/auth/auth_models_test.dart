import 'dart:ui' show Locale;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starapp/core/config/app_config.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/network/token_store.dart';
import 'package:starapp/features/auth/data/models/interest_category.dart';
import 'package:starapp/features/auth/data/models/language_option.dart';
import 'package:starapp/features/auth/data/models/preset_avatar.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/data/repositories/api_auth_repository.dart';
import 'package:starapp/features/auth/data/repositories/mock_auth_repository.dart';

/// Answers every request with [body] and records what was sent.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final String body;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const mock = MockAuthRepository();

  test('the mock content parses and covers what the steps show', () async {
    final interests = await mock.fetchInterestCategories();
    final languages = await mock.fetchLanguages();
    final avatars = await mock.fetchPresetAvatars();

    expect(interests.map((c) => c.title), contains('Music'));
    expect(interests.every((c) => c.interests.isNotEmpty), isTrue);
    expect(languages.map((l) => l.locale), contains(const Locale('es')));
    expect(languages.map((l) => l.locale), contains(const Locale('en', 'US')));
    expect(avatars, hasLength(9));
    expect(avatars.first.label, 'No photo');
    expect(avatars[2].imageUrl, 'assets/images/auth_avatar_3.png');
  });

  test('toJson round-trips', () async {
    for (final c in await mock.fetchInterestCategories()) {
      expect(InterestCategory.fromJson(c.toJson()).toJson(), c.toJson());
    }
    for (final l in await mock.fetchLanguages()) {
      final copy = LanguageOption.fromJson(l.toJson());
      expect(copy.toJson(), l.toJson());
      expect(copy.locale, l.locale);
    }
    for (final a in await mock.fetchPresetAvatars()) {
      final copy = PresetAvatar.fromJson(a.toJson());
      expect(copy.imageUrl, a.imageUrl);
      expect(copy.label, a.label);
      for (final (x, y) in [(copy.thumb, a.thumb), (copy.photo, a.photo)]) {
        expect(x.left, closeTo(y.left, 1e-9));
        expect(x.top, closeTo(y.top, 1e-9));
        expect(x.width, closeTo(y.width, 1e-9));
        expect(x.height, closeTo(y.height, 1e-9));
      }
    }
  });

  test('locale tags and missing crops parse', () {
    LanguageOption lang(String tag) =>
        LanguageOption.fromJson({'name': 'x', 'locale': tag});

    expect(lang('fr_CA').locale, const Locale('fr', 'CA'));
    expect(
      lang('zh-Hans-CN').locale,
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      ),
    );
    final avatar = PresetAvatar.fromJson({'imageUrl': 'https://x/a.png'});
    expect(avatar.thumb.width, 1);
    expect(avatar.photo.left, 0);
  });

  test('the mock username check flags taken names', () async {
    expect(await mock.checkUsername('Admin '), isFalse);
    expect(await mock.checkUsername('ada_l'), isTrue);
  });

  test('the provider follows the mock switch', () {
    ProviderContainer container(bool mockData) {
      final c = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(apiBaseUrl: 'https://x', useMockData: mockData),
          ),
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    expect(
      container(true).read(authRepositoryProvider),
      isA<MockAuthRepository>(),
    );
    expect(
      container(false).read(authRepositoryProvider),
      isA<ApiAuthRepository>(),
    );
  });

  test('signing in and verifying a code store the access token', () async {
    final adapter = _FakeAdapter('{"accessToken": "t-123"}');
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    final tokens = InMemoryTokenStore();
    final repository = ApiAuthRepository(ApiClient(dio), tokens);

    await repository.signIn(email: 'ada@example.com', password: 'secret');
    expect(await tokens.read(), 't-123');
    expect(adapter.requests.last.path, '/auth/login');

    await tokens.clear();
    await repository.requestPasswordReset('ada@example.com');
    await repository.verifyOtp('1234');
    expect(await tokens.read(), 't-123');
    expect(adapter.requests.last.path, '/auth/otp/verify');
    expect(adapter.requests.last.data, {
      'email': 'ada@example.com',
      'code': '1234',
    });
  });
}
