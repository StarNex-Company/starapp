import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the signed-in session's access token. Sign-in writes it, the API
/// client reads it for every request, and sign-out or a 401 clears it.
abstract interface class TokenStore {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

/// Keychain / Keystore backed; the token survives app restarts.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth_access_token';

  final FlutterSecureStorage _storage;

  /// Reads hit the platform channel, so keep the latest value in memory.
  String? _cached;
  bool _loaded = false;

  @override
  Future<String?> read() async {
    if (_loaded) return _cached;
    _cached = await _storage.read(key: _key);
    _loaded = true;
    return _cached;
  }

  @override
  Future<void> write(String token) async {
    _cached = token;
    _loaded = true;
    await _storage.write(key: _key, value: token);
  }

  @override
  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    await _storage.delete(key: _key);
  }
}

/// For tests and mock mode: nothing touches the platform.
class InMemoryTokenStore implements TokenStore {
  InMemoryTokenStore([this._token]);

  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());
