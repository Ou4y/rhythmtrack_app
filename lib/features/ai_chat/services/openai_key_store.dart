import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OpenAIKeyStore {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'OPENAI_API_KEY';

  static Future<void> saveKey(String key) async {
    await _storage.write(key: _keyName, value: key);
  }

  static Future<String?> getKey() async {
    return await _storage.read(key: _keyName);
  }
}