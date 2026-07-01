import 'package:hive/hive.dart';

class TokenStorage {
  static const String _boxName = 'appBox';
  static const String _tokenKey = 'token';

  static Box get _box => Hive.box(_boxName);

  static Future<void> saveToken(String token) async {
    await _box.put(_tokenKey, token);
  }

  static String? getToken() {
    return _box.get(_tokenKey) as String?;
  }

  static Future<void> clearToken() async {
    await _box.delete(_tokenKey);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}