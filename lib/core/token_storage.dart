import 'package:hive/hive.dart';

class TokenStorage {
  static const String boxName = 'appBox';
  static const String tokenKey = 'token';

  static Box get _box => Hive.box(boxName);

  static Future<void> saveToken(String token) async {
    await _box.put(tokenKey, token);
  }

  static String? getToken() {
    return _box.get(tokenKey) as String?;
  }

  static Future<void> clearToken() async {
    await _box.delete(tokenKey);
  }
}