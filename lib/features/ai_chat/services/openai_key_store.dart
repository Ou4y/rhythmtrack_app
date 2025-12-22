import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OpenAIKeyStore {
  static const _storage = FlutterSecureStorage();
  static const _keyName = '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';

  static Future<void> saveKey(String key) async {
    await _storage.write(key: _keyName, value: key);
  }

  static Future<String?> getKey() async {
    return await _storage.read(key: _keyName);
  }
}