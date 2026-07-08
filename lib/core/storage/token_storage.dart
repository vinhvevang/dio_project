import 'package:hive/hive.dart';

class TokenStorage {
  static const String _boxName = 'appBox';
  static const String _tokenKey = 'token';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';

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

  static Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _box.put(_usernameKey, username);
    await _box.put(_passwordKey, password);
  }

  static Map<String, String>? getCredentials() {
    final username = _box.get(_usernameKey) as String?;
    final password = _box.get(_passwordKey) as String?;
    if (username == null || password == null) return null;
    return {'username': username, 'password': password};
  }

  static Future<void> clearCredentials() async {
    await _box.delete(_usernameKey);
    await _box.delete(_passwordKey);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}