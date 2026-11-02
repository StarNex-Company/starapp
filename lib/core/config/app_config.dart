import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build-time settings, passed with `--dart-define`:
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=https://api.starapp.io/v1 \
///             --dart-define=USE_MOCK_DATA=false
/// ```
///
/// While [useMockData] is true (the default until the backend is live),
/// every repository provider hands out its `Mock…Repository`; set it to false
/// and they switch to the `Api…Repository` implementations.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.useMockData,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.starapp.io/v1',
    ),
    useMockData: bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true),
  );

  final String apiBaseUrl;
  final bool useMockData;
  final Duration connectTimeout;
  final Duration receiveTimeout;
}

/// Override in tests or flavors with `appConfigProvider.overrideWithValue`.
final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);
