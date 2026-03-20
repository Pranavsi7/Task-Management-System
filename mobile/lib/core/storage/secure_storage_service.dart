import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> saveAccessToken(String token) async =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<void> saveRefreshToken(String token) async =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  Future<void> saveUserData(String json) async =>
      _storage.write(key: AppConstants.userKey, value: json);

  Future<String?> getUserData() =>
      _storage.read(key: AppConstants.userKey);

  Future<void> clearAll() async => _storage.deleteAll();
}
