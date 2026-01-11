import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OpenRouterKeyStore {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'openrouter_api_key';

  static Future<void> saveKey(String key) async {
    await _storage.write(key: _keyName, value: key);
  }

  static Future<String?> getKey() async {
    return await _storage.read(key: _keyName);
  }

  static Future<void> deleteKey() async {
    await _storage.delete(key: _keyName);
  }
}