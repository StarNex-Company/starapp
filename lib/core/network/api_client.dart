import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/core/config/app_config.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/network/token_store.dart';

/// Turns a decoded JSON body into a model.
typedef Decoder<T> = T Function(Object? json);

/// The app's only HTTP entry point. Adds the bearer token, maps every failure
/// to an [ApiException], and decodes bodies with the caller's [Decoder].
///
/// ```dart
/// final user = await client.get('/me', decode: (j) => CurrentUser.fromJson(j as Json));
/// await client.post<void>('/creators/$id/follow');
/// ```
///
/// Bodies are JSON with camelCase keys, and a response body is the resource
/// itself. If the backend wraps responses (e.g. `{"data": …}`), unwrap them
/// in [_unwrap], once, for every endpoint.
class ApiClient {
  ApiClient(this._dio);

  factory ApiClient.create({
    required AppConfig config,
    required TokenStore tokens,
    void Function()? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {'Accept': 'application/json'},
        contentType: Headers.jsonContentType,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokens.read();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await tokens.clear();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
    return ApiClient(dio);
  }

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, Object?>? query,
    Decoder<T>? decode,
  }) => _send(
    () => _dio.get<Object?>(path, queryParameters: _clean(query)),
    decode,
  );

  /// [headers] adds per-request headers, e.g. `Idempotency-Key`.
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Decoder<T>? decode,
  }) => _send(
    () => _dio.post<Object?>(
      path,
      data: data,
      queryParameters: _clean(query),
      options: headers == null ? null : Options(headers: headers),
    ),
    decode,
  );

  Future<T> put<T>(String path, {Object? data, Decoder<T>? decode}) =>
      _send(() => _dio.put<Object?>(path, data: data), decode);

  Future<T> patch<T>(String path, {Object? data, Decoder<T>? decode}) =>
      _send(() => _dio.patch<Object?>(path, data: data), decode);

  Future<T> delete<T>(String path, {Object? data, Decoder<T>? decode}) =>
      _send(() => _dio.delete<Object?>(path, data: data), decode);

  /// Multipart upload of the file at [filePath] under [field], with optional
  /// extra form [fields]. [onProgress] reports bytes sent of the total.
  Future<T> upload<T>(
    String path, {
    required String filePath,
    String field = 'file',
    Map<String, Object?> fields = const {},
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
    Decoder<T>? decode,
  }) async {
    final form = FormData.fromMap({
      ..._clean(fields)!,
      field: await MultipartFile.fromFile(filePath),
    });
    return _send(
      () => _dio.post<Object?>(
        path,
        data: form,
        onSendProgress: onProgress,
        cancelToken: cancelToken,
      ),
      decode,
    );
  }

  Future<T> _send<T>(
    Future<Response<Object?>> Function() request,
    Decoder<T>? decode,
  ) async {
    try {
      final response = await request();
      final body = _unwrap(response.data);
      return decode == null ? null as T : decode(body);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  static Object? _unwrap(Object? body) => body;

  /// Drops null query values so optional filters can be passed as-is.
  static Map<String, Object?>? _clean(Map<String, Object?>? query) =>
      query == null
      ? null
      : {for (final MapEntry(:key, :value) in query.entries) key: ?value};
}

/// Bumped whenever a request comes back 401: the stored token has already
/// been cleared, and the app listens to send the user to sign in.
final sessionExpiredProvider = NotifierProvider<SessionExpiredNotifier, int>(
  SessionExpiredNotifier.new,
);

class SessionExpiredNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void expire() => state++;
}

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient.create(
    config: ref.watch(appConfigProvider),
    tokens: ref.watch(tokenStoreProvider),
    onUnauthorized: () => ref.read(sessionExpiredProvider.notifier).expire(),
  ),
);

/// Picks a repository implementation from [AppConfig.useMockData]:
///
/// ```dart
/// final xRepositoryProvider = Provider<XRepository>(
///   (ref) => selectRepository(ref, mock: MockXRepository.new, api: ApiXRepository.new),
/// );
/// ```
T selectRepository<T>(
  Ref ref, {
  required T Function() mock,
  required T Function(ApiClient client) api,
}) => ref.watch(appConfigProvider).useMockData
    ? mock()
    : api(ref.watch(apiClientProvider));
