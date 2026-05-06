import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _androidOptions = AndroidOptions(
    resetOnError: false,
  );

  final _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() async =>
      await _storage.read(key: 'access_token');

  Future<String?> getRefreshToken() async =>
      await _storage.read(key: 'refresh_token');

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}